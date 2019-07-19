// $Id: RtclProxyBase.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-18  1089   1.5.2  use c++ style casts
// 2018-09-16  1047   1.5.1  coverity fixup (uninitialized pointer)
// 2017-03-11   859   1.5    adopt new DispatchCmd() logic
// 2014-08-22   584   1.4.3  use nullptr
// 2013-02-09   485   1.4.2  add CommandName()
// 2013-02-05   483   1.4.1  ClassCmdConfig: use RtclArgs
// 2013-02-02   480   1.4    factor out RtclCmdBase base class
// 2013-02-01   479   1.3    add DispatchCmd(), support $unknown method
// 2011-07-31   401   1.2    add ctor(type,interp,name) for direct usage
// 2011-04-23   380   1.1    use boost/function instead of RmethDsc
// 2011-03-05   366   1.0.1  use AppendResultNewLines() in exception catcher
// 2011-02-20   363   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclProxyBase.
*/

#include "RtclProxyBase.hpp"

#include "RtclContext.hpp"
#include "Rtcl.hpp"

using namespace std;

/*!
  \class Retro::RtclProxyBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclProxyBase::RtclProxyBase(const std::string& type)
  : RtclCmdBase(),
    fType(type),
    fInterp(nullptr),
    fCmdToken(0)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclProxyBase::RtclProxyBase(const std::string& type, Tcl_Interp* interp,
                             const char* name)
  : RtclCmdBase(),
    fType(type),
    fInterp(nullptr)
{
  CreateObjectCmd(interp, name);
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclProxyBase::~RtclProxyBase()
{
  if (fInterp) RtclContext::Find(fInterp).UnRegisterProxy(this);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclProxyBase::ClassCmdConfig(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string RtclProxyBase::CommandName() const
{
  return string(Tcl_GetCommandName(fInterp, fCmdToken));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclProxyBase::CreateObjectCmd(Tcl_Interp* interp, const char* name)
{
  fInterp = interp;
  fCmdToken = 
    Tcl_CreateObjCommand(interp, name, ThunkTclObjectCmd,
                reinterpret_cast<ClientData>(this), 
                reinterpret_cast<Tcl_CmdDeleteProc*>(ThunkTclCmdDeleteProc));
  RtclContext::Find(interp).RegisterProxy(this);
  Tcl_CreateExitHandler(reinterpret_cast<Tcl_ExitProc*>(ThunkTclExitProc),
                        reinterpret_cast<ClientData>(this));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclProxyBase::TclObjectCmd(Tcl_Interp* interp, int objc, 
                                Tcl_Obj* const objv[])
{
  RtclArgs  args(interp, objc, objv, 1);
  return DispatchCmd(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclProxyBase::ThunkTclObjectCmd(ClientData cdata, Tcl_Interp* interp, 
                                     int objc, Tcl_Obj* const objv[])
{
  if (!cdata) {
    Tcl_AppendResult(interp, "-E: BUG! ThunkTclObjectCmd called with cdata==0",
                     nullptr);
    return TCL_ERROR;
  }
  
  try {
    return (reinterpret_cast<RtclProxyBase*>(cdata))->TclObjectCmd(interp,
                                                                   objc, objv);
  } catch (exception& e) {
    Rtcl::AppendResultNewLines(interp);
    Tcl_AppendResult(interp, "-E: exception caught '", e.what(), "'", nullptr);
  }
  return TCL_ERROR;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclProxyBase::ThunkTclCmdDeleteProc(ClientData cdata)
{
  Tcl_DeleteExitHandler(reinterpret_cast<Tcl_ExitProc*>(ThunkTclExitProc),
                        cdata);
  delete (reinterpret_cast<RtclProxyBase*>(cdata));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclProxyBase::ThunkTclExitProc(ClientData cdata)
{
  delete (reinterpret_cast<RtclProxyBase*>(cdata));
  return;
}

} // end namespace Retro
