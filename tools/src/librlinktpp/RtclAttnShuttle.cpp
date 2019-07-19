// $Id: RtclAttnShuttle.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-02-23  1114   1.1.4  use std::bind instead of lambda
// 2018-12-18  1089   1.1.3  use c++ style casts
// 2018-12-15  1082   1.1.2  use lambda instead of boost::bind
// 2018-10-27  1059   1.1.1  coverity fixup (uncaught exception in dtor)
// 2014-12-30   625   1.1    adopt to Rlink V4 attn logic
// 2014-11-08   602   1.0.3  cast int first to ptrdiff_t, than to ClientData
// 2014-08-22   584   1.0.2  use nullptr
// 2013-05-20   521   1.0.1  Setup proper Tcl channel options
// 2013-03-01   493   1.0    Initial version
// 2013-01-12   475   0.5    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of class RtclAttnShuttle.
 */

#include <unistd.h>
#include <errno.h>

#include <functional>

#include "librtools/Rexception.hpp"
#include "librtools/Rtools.hpp"

#include "RtclAttnShuttle.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::RtclAttnShuttle
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! constructor

RtclAttnShuttle::RtclAttnShuttle(uint16_t mask, Tcl_Obj* pobj)
  : fpServ(nullptr),
    fpInterp(nullptr),
    fFdPipeRead(-1),
    fFdPipeWrite(-1),
    fShuttleChn(0),
    fMask(mask),
    fpScript(pobj)
{
  int pipefd[2];
  int irc = ::pipe(pipefd);
  if (irc < 0) 
    throw Rexception("RtclAttnShuttle::<ctor>", "pipe() failed: ", errno);
  fFdPipeRead  = pipefd[0];
  fFdPipeWrite = pipefd[1];
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclAttnShuttle::~RtclAttnShuttle()
{
  Rtools::Catch2Cerr(__func__, [this](){ Remove();} );
  ::close(fFdPipeWrite);
  ::close(fFdPipeRead);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclAttnShuttle::Add(RlinkServer* pserv, Tcl_Interp* interp)
{
  // connect to RlinkServer
  pserv->AddAttnHandler(bind(&RtclAttnShuttle::AttnHandler, this, _1),
                        fMask, this);
  fpServ = pserv;

  // connect to Tcl
  // cast first to ptrdiff_t to promote to proper int size
  fShuttleChn = Tcl_MakeFileChannel(reinterpret_cast<ClientData>(fFdPipeRead), 
                                    TCL_READABLE);

  Tcl_SetChannelOption(nullptr, fShuttleChn, "-buffersize", "64");
  Tcl_SetChannelOption(nullptr, fShuttleChn, "-encoding", "binary");
  Tcl_SetChannelOption(nullptr, fShuttleChn, "-translation", "binary");

  Tcl_CreateChannelHandler(fShuttleChn, TCL_READABLE, 
                      reinterpret_cast<Tcl_FileProc*>(ThunkTclChannelHandler),
                      reinterpret_cast<ClientData>(this));

  fpInterp = interp;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclAttnShuttle::Remove()
{
  // disconnect from RlinkServer
  if (fpServ) {
    fpServ->RemoveAttnHandler(fMask, this);
    fpServ = nullptr;
  }
  // disconnect from Tcl
  if (fpInterp) {
    Tcl_DeleteChannelHandler(fShuttleChn, 
                       reinterpret_cast<Tcl_FileProc*>(ThunkTclChannelHandler),
                       reinterpret_cast<ClientData>(this));
    Tcl_Close(fpInterp, fShuttleChn);
    fpInterp = nullptr;
  }
  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclAttnShuttle::AttnHandler(RlinkServer::AttnArgs& args)
{
  fpServ->GetAttnInfo(args);

  uint16_t apat = args.fAttnPatt & args.fAttnMask;
  int irc = ::write(fFdPipeWrite, &apat, sizeof(apat));
  if (irc < 0) 
    throw Rexception("RtclAttnShuttle::AttnHandler()",
                     "write() failed: ", errno);
  
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclAttnShuttle::TclChannelHandler(int /*mask*/)
{
  uint16_t apat;
  Tcl_ReadRaw(fShuttleChn, reinterpret_cast<char*>(&apat), sizeof(apat));
  // FIXME_code: handle return code

  Tcl_SetVar2Ex(fpInterp, "Rlink_attnbits", nullptr, 
                Tcl_NewIntObj(int(apat)), 0);
  // FIXME_code: handle return code

  Tcl_EvalObjEx(fpInterp, fpScript, TCL_EVAL_GLOBAL);
  // FIXME_code: handle return code
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclAttnShuttle::ThunkTclChannelHandler(ClientData cdata, int mask)
{
  reinterpret_cast<RtclAttnShuttle*>(cdata)->TclChannelHandler(mask);
  return;
}

} // end namespace Retro
