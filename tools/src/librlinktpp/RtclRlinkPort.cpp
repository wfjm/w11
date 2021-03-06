// $Id: RtclRlinkPort.cpp 1175 2019-06-30 06:13:17Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-29  1175   1.4.6  DoRaw{Read,Rblk}(): add missing OptValid() call
// 2019-06-07  1160   1.4.5  use RtclStats::Exec()
// 2019-02-23  1114   1.4.4  use std::bind instead of lambda
// 2018-12-22  1091   1.4.3  M_Open(): drop move() (-Wpessimizing-move fix)
// 2018-12-18  1089   1.4.2  use c++ style casts
// 2018-12-15  1082   1.4.1  use lambda instead of boost::bind
// 2018-12-08  1079   1.4    use ref not ptr for RlinkPort
// 2018-12-01  1076   1.3    use unique_ptr
// 2017-04-29   888   1.2    LogFileName(): returns now const std::string&
//                           drop M_rawio; add M_rawread,M_rawrblk,M_rawwblk
// 2017-04-02   865   1.1.1  M_dump: use GetArgsDump and Dump detail
// 2017-02-19   853   1.1    use Rtime
// 2015-01-09   632   1.0.4  add M_get, M_set, remove M_config
// 2014-08-22   584   1.0.3  use nullptr
// 2013-02-23   492   1.0.2  use RlogFile.Name();
// 2013-02-22   491   1.0.1  use new RlogFile/RlogMsg interfaces
// 2013-01-27   478   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of class RtclRlinkPort.
 */

#include <ctype.h>

#include <iostream>
#include <functional>

#include "librtcltools/Rtcl.hpp"
#include "librtcltools/RtclOPtr.hpp"
#include "librtcltools/RtclNameSet.hpp"
#include "librtcltools/RtclStats.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RlogFile.hpp"
#include "librlink/RlinkPortFactory.hpp"

#include "RtclRlinkPort.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::RtclRlinkPort
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RtclRlinkPort::RtclRlinkPort(Tcl_Interp* interp, const char* name)
  : RtclProxyBase("RlinkPort"),
    fupObj(),
    fspLog(new RlogFile(&cout)),
    fTraceLevel(0),
    fErrCnt(0),
    fGets(),
    fSets()
{
  CreateObjectCmd(interp, name);
  AddMeth("open",     bind(&RtclRlinkPort::M_open,    this, _1));
  AddMeth("close",    bind(&RtclRlinkPort::M_close,   this, _1));
  AddMeth("errcnt",   bind(&RtclRlinkPort::M_errcnt,  this, _1));
  AddMeth("rawread",  bind(&RtclRlinkPort::M_rawread, this, _1));
  AddMeth("rawrblk",  bind(&RtclRlinkPort::M_rawrblk, this, _1));
  AddMeth("rawwblk",  bind(&RtclRlinkPort::M_rawwblk, this, _1));
  AddMeth("stats",    bind(&RtclRlinkPort::M_stats,   this, _1));
  AddMeth("log",      bind(&RtclRlinkPort::M_log,     this, _1));
  AddMeth("dump",     bind(&RtclRlinkPort::M_dump,    this, _1));
  AddMeth("get",      bind(&RtclRlinkPort::M_get,     this, _1));
  AddMeth("set",      bind(&RtclRlinkPort::M_set,     this, _1));
  AddMeth("$default", bind(&RtclRlinkPort::M_default, this, _1));

  SetupGetSet();
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRlinkPort::~RtclRlinkPort()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_open(RtclArgs& args)
{
  string path;

  if (!args.GetArg("?path", path)) return kERR;
  if (!args.AllDone()) return kERR;

  RerrMsg emsg;
  if (args.NOptMiss() == 0) {               // open path
    fupObj = RlinkPortFactory::Open(path, emsg);
    SetupGetSet();
    if (!fupObj) return args.Quit(emsg);
    fupObj->SetLogFile(fspLog);
    fupObj->SetTraceLevel(fTraceLevel);
  } else {                                  // open
    string name = (fupObj && fupObj->IsOpen()) ? fupObj->Url().Url() : string();
    args.SetResult(name);
  }
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_close(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  if (!TestPort(args, false)) return kERR;
  fupObj.reset();
  SetupGetSet();
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_errcnt(RtclArgs& args)
{
  static RtclNameSet optset("-clear");
  string opt;
  bool fclear = false;
  
  while (args.NextOpt(opt, optset)) {
    if (opt == "-clear") fclear = true;
  }
  if (!args.AllDone()) return kERR;

  args.SetResult(int(fErrCnt));
  if (fclear) fErrCnt = 0;

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_rawread(RtclArgs& args)
{
  if (!TestPort(args)) return kERR;
  return DoRawRead(args, *fupObj);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_rawrblk(RtclArgs& args)
{
  if (!TestPort(args)) return kERR;
  return DoRawRblk(args, *fupObj, fErrCnt);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_rawwblk(RtclArgs& args)
{
  if (!TestPort(args)) return kERR;
  return DoRawWblk(args, *fupObj);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_stats(RtclArgs& args)
{
  RtclStats::Context cntx;

  if (!TestPort(args, false)) return kERR;
  if (!RtclStats::GetArgs(args, cntx)) return kERR;
  if (!RtclStats::Exec(args, cntx, fupObj->Stats())) return kERR;
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_log(RtclArgs& args)
{
  string msg;
  if (!args.GetArg("msg", msg)) return kERR;
  if (!args.AllDone()) return kERR;
  if (fTraceLevel != 0) fspLog->Write(string("# ") + msg);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_dump(RtclArgs& args)
{
  int detail=0;
  if (!GetArgsDump(args, detail)) return kERR;
  if (!args.AllDone()) return kERR;
  if (!TestPort(args, false)) return kERR;

  ostringstream sos;
  fupObj->Dump(sos, 0, "", 0);
  args.SetResult(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_get(RtclArgs& args)
{
  return fGets.M_get(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_set(RtclArgs& args)
{
  return fSets.M_set(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  ostringstream sos;

  sos << "logfile:     " << fspLog->Name()
      << "   tracelevel " << fTraceLevel; 

  args.AppendResultLines(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclRlinkPort::SetupGetSet()
{
  fGets.Clear();
  fSets.Clear();
  
  fGets.Add<const string&>  ("logfile",
                                bind(&RtclRlinkPort::LogFileName, this));
  fSets.Add<const string&>  ("logfile", 
                                bind(&RtclRlinkPort::SetLogFileName, this, _1));

  if (!fupObj) return;
  fGets.Add<uint32_t>  ("tracelevel", 
                          bind(&RlinkPort::TraceLevel, fupObj.get()));
  fSets.Add<uint32_t>  ("tracelevel", 
                          bind(&RlinkPort::SetTraceLevel, fupObj.get(), _1));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclRlinkPort::TestPort(RtclArgs& args, bool testopen)
{
  if (fupObj && (!testopen || fupObj->IsOpen())) return true;
  args.AppendResult("-E: port not open", nullptr);
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclRlinkPort::SetLogFileName(const std::string& name)
{
  RerrMsg emsg;
  if (!fspLog->Open(name, emsg)) {
    fspLog->UseStream(&cout);
    throw Rexception("RtclRlinkPort::SetLogFile", 
                     emsg.Text() + "', using stdout");
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

const std::string& RtclRlinkPort::LogFileName() const
{
  return fspLog->Name();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::DoRawRead(RtclArgs& args, RlinkPort& port)
{
  int32_t rsize;
  string rvname;
  vector<uint8_t> rdata;
  double timeout = 1.;

  if (!args.GetArg("bsize", rsize, 1, 4096)) return kERR;
  if (!args.GetArg("varData", rvname)) return kERR;
  
  static RtclNameSet optset("-timeout");
  string opt;
  while (args.NextOpt(opt, optset)) {
    if (opt == "-timeout") {     // -timeout tsec ------------------
      if (!args.GetArg("tsec", timeout, 0.)) return kERR;
    }
  }
  if (!args.OptValid()) return kERR;

  RerrMsg emsg;
  Rtime tused;
  rdata.resize(rsize);

  int irc = port.RawRead(rdata.data(), rdata.size(), false, Rtime(timeout), 
                         tused, emsg);

  if (irc == RlinkPort::kEof)    return args.Quit("-E: RawRead EOF");
  if (irc == RlinkPort::kTout)   return args.Quit("-E: RawRead timeout");
  if (irc < 0)                   return args.Quit(emsg);

  rdata.resize(irc);

  RtclOPtr pres(Rtcl::NewListIntObj(rdata));
  if(!Rtcl::SetVar(args.Interp(), rvname, pres)) return kERR;

  args.SetResult(double(tused));

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::DoRawRblk(RtclArgs& args, RlinkPort& port, size_t& errcnt)
{
  int32_t rsize;
  string rvname;
  vector<uint8_t> rdata;
  vector<uint8_t> edata;
  vector<uint8_t> emask;
  double timeout = 1.;
  
  if (!args.GetArg("bsize", rsize, 1, 4096)) return kERR;
  if (!args.GetArg("??varData", rvname)) return kERR;

  static RtclNameSet optset("-edata|-timeout");
  string opt;
  while (args.NextOpt(opt, optset)) {
    if (opt == "-edata") {              // -edata data ?mask --------------
      if (!args.GetArg("data", edata, 0, rsize)) return kERR;
      if (!args.GetArg("??mask", emask, 0, rsize)) return kERR;
    } else if (opt == "-timeout") {     // -timeout tsec ------------------
      if (!args.GetArg("tsec", timeout, 0.)) return kERR;
    }
  }
  if (!args.OptValid()) return kERR;

  RerrMsg emsg;
  Rtime tused;
  rdata.resize(rsize);

  int irc = port.RawRead(rdata.data(), rdata.size(), true, Rtime(timeout), 
                         tused, emsg);
  if (irc == RlinkPort::kEof)    return args.Quit("-E: RawRead EOF");
  if (irc == RlinkPort::kTout)   return args.Quit("-E: RawRead timeout");
  if (irc < 0)                   return args.Quit(emsg);
  
  if (rvname.length()) {
    RtclOPtr pres(Rtcl::NewListIntObj(rdata));
    if(!Rtcl::SetVar(args.Interp(), rvname, pres)) return kERR;
  }
  if (edata.size()) {
    size_t nerr=0;
    for (size_t i=0; i<rdata.size(); i++) {
      if (i >= edata.size()) break;
      uint8_t eval = edata[i];
      uint8_t emsk = (i < emask.size()) ? emask[i] : 0x00;
      if ((rdata[i]|emsk) != (eval|emsk)) nerr += 1;
    }
    if (nerr) errcnt += 1;
  }
  args.SetResult(double(tused));
  
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::DoRawWblk(RtclArgs& args, RlinkPort& port)
{
  vector<uint8_t> wdata;
  if (!args.GetArg("data", wdata, 1, 4096)) return kERR;
  
  RerrMsg emsg;
  int irc = port.RawWrite(wdata.data(), wdata.size(), emsg);
  if (irc != int(wdata.size())) return args.Quit(emsg);
  
  return kOK;
}


} // end namespace Retro
