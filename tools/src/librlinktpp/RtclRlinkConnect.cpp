// $Id: RtclRlinkConnect.cpp 1160 2019-06-07 17:30:17Z mueller $
//
// Copyright 2011-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.6.11 use RtclStats::Exec()
// 2019-03-10  1121   1.6.10 M_exec(): tranfer BlockDone values after rblk
// 2019-02-23  1114   1.6.9  use std::bind instead of lambda
// 2018-12-23  1091   1.6.8  use AddWblk(move)
// 2018-12-18  1089   1.6.7  use c++ style casts
// 2018-12-17  1085   1.6.6  use std::lock_guard instead of boost
// 2018-12-15  1082   1.6.5  use lambda instead of boost::bind
// 2018-12-08  1079   1.6.4  use HasPort(); Port() returns now ref
// 2018-12-07  1077   1.6.3  use SetLastExpectBlock move semantics
// 2018-11-16  1070   1.6.2  use auto; use range loop
// 2018-09-16  1047   1.6.1  coverity fixup (uninitialized scalar)
// 2017-04-29   888   1.6    drop M_rawio; add M_rawread,M_rawrblk,M_rawwblk
// 2017-04-22   883   1.5.2  M_amap: -testname opt addr check; add hasrbmon get 
// 2017-04-02   865   1.5.1  M_dump: use GetArgsDump and Dump detail
// 2017-02-20   854   1.5    use Rtime
// 2016-04-02   758   1.4.6  add USR_ACCESS register support (UsrAcc->usracc)
// 2016-03-20   748   1.4.5  M_get/set: add timeout
// 2015-05-09   676   1.4.3  M_errcnt: add -increment; M_log: add -bare,-info..
// 2015-04-19   668   1.4.2  M_wtlam: allow tout=0 for pending attn cleanup
// 2015-04-12   666   1.4.1  add M_init
// 2015-04-03   661   1.4    expect logic: drop estatdef, use LastExpect..
// 2015-03-28   660   1.3.3  add stat* getter/setter; M_exec: add -estaterr ect
// 2015-01-06   631   1.3.2  add M_get, M_set, remove M_config
// 2014-12-20   616   1.3.1  M_exec: add -edone for BlockDone checking
// 2014-12-06   609   1.3    new rlink v4 iface
// 2014-08-22   584   1.2.1  use nullptr
// 2014-08-15   583   1.2    rb_mreq addr now 16 bit
// 2014-08-02   576   1.1.7  BUGFIX: redo estatdef logic; avoid LastExpect()
// 2013-02-23   492   1.1.6  use RlogFile.Name(); use Context().ErrorCount()
// 2013-02-22   491   1.1.5  use new RlogFile/RlogMsg interfaces
// 2013-02-02   480   1.1.4  allow empty exec commands
// 2013-01-27   478   1.1.3  use RtclRlinkPort::DoRawio on M_rawio
// 2013-01-06   473   1.1.2  add M_rawio: rawio -write|-read
// 2011-11-28   434   1.1.1  ConfigBase(): use uint32_t for lp64 compatibility
// 2011-04-23   380   1.1    use boost/bind instead of RmethDsc
// 2011-04-17   376   1.0.1  M_wtlam: now correct log levels
// 2011-03-27   374   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of class RtclRlinkConnect.
 */

#include <ctype.h>

#include <iostream>
#include <functional>

#include "librtcltools/Rtcl.hpp"
#include "librtcltools/RtclOPtr.hpp"
#include "librtcltools/RtclNameSet.hpp"
#include "librtcltools/RtclStats.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RlogMsg.hpp"
#include "librlink/RlinkCommandList.hpp"
#include "RtclRlinkPort.hpp"

#include "RtclRlinkConnect.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::RtclRlinkConnect
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RtclRlinkConnect::RtclRlinkConnect(Tcl_Interp* interp, const char* name)
  : RtclProxyOwned<RlinkConnect>("RlinkConnect", interp, name, 
                                 new RlinkConnect()),
    fGets(),
    fSets()
{
  AddMeth("open",     bind(&RtclRlinkConnect::M_open,    this, _1));
  AddMeth("close",    bind(&RtclRlinkConnect::M_close,   this, _1));
  AddMeth("init",     bind(&RtclRlinkConnect::M_init,    this, _1));
  AddMeth("exec",     bind(&RtclRlinkConnect::M_exec,    this, _1));
  AddMeth("amap",     bind(&RtclRlinkConnect::M_amap,    this, _1));
  AddMeth("errcnt",   bind(&RtclRlinkConnect::M_errcnt,  this, _1));
  AddMeth("wtlam",    bind(&RtclRlinkConnect::M_wtlam,   this, _1));
  AddMeth("oob",      bind(&RtclRlinkConnect::M_oob,     this, _1));
  AddMeth("rawread",  bind(&RtclRlinkConnect::M_rawread, this, _1));
  AddMeth("rawrblk",  bind(&RtclRlinkConnect::M_rawrblk, this, _1));
  AddMeth("rawwblk",  bind(&RtclRlinkConnect::M_rawwblk, this, _1));
  AddMeth("stats",    bind(&RtclRlinkConnect::M_stats,   this, _1));
  AddMeth("log",      bind(&RtclRlinkConnect::M_log,     this, _1));
  AddMeth("print",    bind(&RtclRlinkConnect::M_print,   this, _1));
  AddMeth("dump",     bind(&RtclRlinkConnect::M_dump,    this, _1));
  AddMeth("get",      bind(&RtclRlinkConnect::M_get,     this, _1));
  AddMeth("set",      bind(&RtclRlinkConnect::M_set,     this, _1));
  AddMeth("$default", bind(&RtclRlinkConnect::M_default, this, _1));
  
  for (size_t i=0; i<8; i++) {
    fCmdnameObj[i] = Tcl_NewStringObj(RlinkCommand::CommandName(i), -1);
  }

  // attributes of RlinkConnect
  RlinkConnect* pobj  = &Obj();

  fGets.Add<uint32_t>  ("baseaddr",   bind(&RlinkConnect::LogBaseAddr, pobj));
  fGets.Add<uint32_t>  ("basedata",   bind(&RlinkConnect::LogBaseData, pobj));
  fGets.Add<uint32_t>  ("basestat",   bind(&RlinkConnect::LogBaseStat, pobj));
  fGets.Add<uint32_t>  ("printlevel", bind(&RlinkConnect::PrintLevel, pobj));
  fGets.Add<uint32_t>  ("dumplevel",  bind(&RlinkConnect::DumpLevel, pobj));
  fGets.Add<uint32_t>  ("tracelevel", bind(&RlinkConnect::TraceLevel, pobj));
  fGets.Add<const Rtime&> ("timeout", bind(&RlinkConnect::Timeout, pobj));
  fGets.Add<const string&> ("logfile",bind(&RlinkConnect::LogFileName, pobj));

  fGets.Add<uint32_t>  ("initdone",   bind(&RlinkConnect::LinkInitDone, pobj));
  fGets.Add<uint32_t>  ("sysid",      bind(&RlinkConnect::SysId, pobj));
  fGets.Add<uint32_t>  ("usracc",     bind(&RlinkConnect::UsrAcc, pobj));
  fGets.Add<size_t>    ("rbufsize",   bind(&RlinkConnect::RbufSize, pobj));
  fGets.Add<size_t>    ("bsizemax",   bind(&RlinkConnect::BlockSizeMax, pobj));
  fGets.Add<size_t>    ("bsizeprudent",
                          bind(&RlinkConnect::BlockSizePrudent, pobj));
  fGets.Add<bool>      ("hasrbmon",   bind(&RlinkConnect::HasRbmon, pobj));

  fSets.Add<uint32_t>  ("baseaddr",
                          bind(&RlinkConnect::SetLogBaseAddr, pobj, _1));
  fSets.Add<uint32_t>  ("basedata", 
                          bind(&RlinkConnect::SetLogBaseData, pobj, _1));
  fSets.Add<uint32_t>  ("basestat", 
                          bind(&RlinkConnect::SetLogBaseStat, pobj, _1));
  fSets.Add<uint32_t>  ("printlevel", 
                          bind(&RlinkConnect::SetPrintLevel, pobj, _1));
  fSets.Add<uint32_t>  ("dumplevel", 
                          bind(&RlinkConnect::SetDumpLevel, pobj, _1));
  fSets.Add<uint32_t>  ("tracelevel", 
                          bind(&RlinkConnect::SetTraceLevel, pobj, _1));
  fSets.Add<const Rtime&>   ("timeout", 
                               bind(&RlinkConnect::SetTimeout, pobj, _1));
  fSets.Add<const string&>  ("logfile", 
                               bind(&RlinkConnect::SetLogFileName, pobj, _1));  

  // attributes of buildin RlinkContext
  RlinkContext* pcntx = &Obj().Context();
  fGets.Add<bool>      ("statchecked",
                          bind(&RlinkContext::StatusIsChecked, pcntx));
  fGets.Add<uint8_t>   ("statvalue", 
                          bind(&RlinkContext::StatusValue, pcntx));
  fGets.Add<uint8_t>   ("statmask", 
                          bind(&RlinkContext::StatusMask, pcntx));

  fSets.Add<uint8_t>   ("statvalue", 
                          bind(&RlinkContext::SetStatusValue, pcntx, _1));
  fSets.Add<uint8_t>   ("statmask", 
                          bind(&RlinkContext::SetStatusMask, pcntx, _1));
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRlinkConnect::~RtclRlinkConnect()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_open(RtclArgs& args)
{
  string path;

  if (!args.GetArg("?path", path)) return kERR;
  if (!args.AllDone()) return kERR;

  RerrMsg emsg;
  if (args.NOptMiss() == 0) {               // open path
    if (!Obj().Open(path, emsg)) return args.Quit(emsg);
  } else {                                  // open 
    string name = Obj().IsOpen() ? Obj().Port().Url().Url() : string();
    args.SetResult(name);
  }
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_close(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  if (!Obj().IsOpen()) return args.Quit("-E: port not open");
  Obj().Close();
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_init(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  if (!Obj().IsOpen()) return args.Quit("-E: port not open");
  if (Obj().LinkInitDone()) return args.Quit("-E: already initialized");
  RerrMsg emsg;
  if (!Obj().LinkInit(emsg)) return args.Quit(emsg);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_exec(RtclArgs& args)
{
  static RtclNameSet optset("-rreg|-rblk|-wreg|-wblk|-labo|-attn|-init|"
                            "-edata|-edone|-estat|"
                            "-estaterr|-estatnak|-estattout|"
                            "-print|-dump|-rlist");

  Tcl_Interp* interp = args.Interp();

  RlinkCommandList clist;
  string opt;
  uint16_t addr=0;

  vector<string> vardata;
  vector<string> varstat;
  string varprint;
  string vardump;
  string varlist;

  while (args.NextOpt(opt, optset)) {
    
    size_t lsize = clist.Size();
    if        (opt == "-rreg") {            // -rreg addr ?varData ?varStat ---
      if (!GetAddr(args, addr)) return kERR;
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddRreg(addr);

    } else if (opt == "-rblk") {            // -rblk addr size ?varData ?varStat
      int32_t bsize=0;
      if (!GetAddr(args, addr)) return kERR;
      if (!args.GetArg("bsize", bsize, 1, Obj().BlockSizeMax())) return kERR;
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddRblk(addr, size_t(bsize));

    } else if (opt == "-wreg") {            // -wreg addr data ?varStat -------
      uint16_t data=0;
      if (!GetAddr(args, addr)) return kERR;
      if (!args.GetArg("data", data)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWreg(addr, data);

    } else if (opt == "-wblk") {            // -wblk addr block ?varStat ------
      vector<uint16_t> block;
      if (!GetAddr(args, addr)) return kERR;
      if (!args.GetArg("data", block, 1, Obj().BlockSizeMax())) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWblk(addr, move(block));

    } else if (opt == "-labo") {            // -labo varData ?varStat ---------
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddLabo();

    } else if (opt == "-attn") {            // -attn varData ?varStat ---------
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddAttn();

    } else if (opt == "-init") {            // -init addr data ?varStat -------
      uint16_t data=0;
      if (!GetAddr(args, addr)) return kERR;
      if (!args.GetArg("data", data)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddInit(addr, data);

    } else if (opt == "-edata") {           // -edata data ?mask --------------
      if (!ClistNonEmpty(args, clist)) return kERR;
      if (clist[lsize-1].Command() == RlinkCommand::kCmdRblk) {
        vector<uint16_t> data;
        vector<uint16_t> mask;
        size_t bsize = clist[lsize-1].BlockSize();
        if (!args.GetArg("data", data, 0, bsize)) return kERR;
        if (!args.GetArg("??mask", mask, 0, bsize)) return kERR;
        clist.SetLastExpectBlock(move(data), move(mask));
      } else {
        uint16_t data=0;
        uint16_t mask=0xffff;
        if (!args.GetArg("data", data)) return kERR;
        if (!args.GetArg("??mask", mask)) return kERR;
        clist.SetLastExpectData(data, mask);
      }

    } else if (opt == "-edone") {           // -edone done --------------------
      if (!ClistNonEmpty(args, clist)) return kERR;
      uint16_t done=0;
      if (!args.GetArg("done", done)) return kERR;
      uint8_t cmd = clist[lsize-1].Command();
      if (cmd == RlinkCommand::kCmdRblk ||
          cmd == RlinkCommand::kCmdWblk) {
        clist.SetLastExpectDone(done);
      } else {
        return args.Quit("-E: -edone allowed only after -rblk,-wblk");
      }

    } else if (opt == "-estat") {           // -estat stat ?mask --------------
      if (!ClistNonEmpty(args, clist)) return kERR;
      uint8_t stat=0;
      uint8_t mask=0xff;
      if (!args.GetArg("stat", stat))   return kERR;
      if (!args.GetArg("??mask", mask)) return kERR;
      clist.SetLastExpectStatus(stat, mask);

    } else if (opt == "-estaterr" ||        // -estaterr ----------------------
               opt == "-estatnak" ||        // -estatnak ----------------------
               opt == "-estattout") {       // -estattout ---------------------
      if (!ClistNonEmpty(args, clist)) return kERR;
      uint8_t val = 0;
      uint8_t msk = RlinkCommand::kStat_M_RbTout |
                    RlinkCommand::kStat_M_RbNak  |
                    RlinkCommand::kStat_M_RbErr;
      if (opt == "-estaterr")  val = RlinkCommand::kStat_M_RbErr;
      if (opt == "-estatnak")  val = RlinkCommand::kStat_M_RbNak;
      if (opt == "-estattout") val = RlinkCommand::kStat_M_RbTout;
      clist.SetLastExpectStatus(val, msk);
      
    } else if (opt == "-print") {           // -print ?varRes -----------------
      varprint = "-";
      if (!args.GetArg("??varRes", varprint)) return kERR;
    } else if (opt == "-dump") {            // -dump ?varRes ------------------
      vardump = "-";
      if (!args.GetArg("??varRes", vardump)) return kERR;
    } else if (opt == "-rlist") {           // -rlist ?varRes -----------------
      varlist = "-";
      if (!args.GetArg("??varRes", varlist)) return kERR;
    }

  } // while (args.NextOpt(opt, optset))

  int nact = 0;
  if (varprint == "-") nact += 1;
  if (vardump  == "-") nact += 1;
  if (varlist  == "-") nact += 1;
  if (nact > 1) 
    return args.Quit(
      "-E: more that one of -print,-dump,-rlist without target variable found");

  if (!args.AllDone()) return kERR;
  if (clist.Size() == 0) return kOK;

  RerrMsg emsg;
  
  if (!Obj().Exec(clist, emsg)) return args.Quit(emsg);

  for (size_t icmd=0; icmd<clist.Size(); icmd++) {
    RlinkCommand& cmd = clist[icmd];
    
    if (icmd<vardata.size() && !vardata[icmd].empty()) {
      RtclOPtr pres;
      vector<uint16_t> retstat;
      RtclOPtr pele;
      switch (cmd.Command()) {
        case RlinkCommand::kCmdRreg:
        case RlinkCommand::kCmdAttn:
        case RlinkCommand::kCmdLabo:
          pres = Tcl_NewIntObj(int(cmd.Data()));
          break;
        case RlinkCommand::kCmdRblk:
          pres = Rtcl::NewListIntObj(cmd.Block().data(), cmd.BlockDone());
          break;
      }
      if(!Rtcl::SetVar(interp, vardata[icmd], pres)) return kERR;
    }

    if (icmd<varstat.size() && !varstat[icmd].empty()) {
      RtclOPtr pres(Tcl_NewIntObj(int(cmd.Status())));
      if (!Rtcl::SetVar(interp, varstat[icmd], pres)) return kERR;
    }
  }

  if (!varprint.empty()) {
    ostringstream sos;
    clist.Print(sos, &Obj().AddrMap(), Obj().LogBaseAddr(), 
                Obj().LogBaseData(), Obj().LogBaseStat());
    RtclOPtr pobj(Rtcl::NewLinesObj(sos));
    if (!Rtcl::SetVarOrResult(args.Interp(), varprint, pobj)) return kERR;
  }

  if (!vardump.empty()) {
    ostringstream sos;
    clist.Dump(sos, 0);
    RtclOPtr pobj(Rtcl::NewLinesObj(sos));
    if (!Rtcl::SetVarOrResult(args.Interp(), vardump, pobj)) return kERR;
  }

  if (!varlist.empty()) {
    RtclOPtr prlist(Tcl_NewListObj(0, nullptr));
    for (size_t icmd=0; icmd<clist.Size(); icmd++) {
      RlinkCommand& cmd(clist[icmd]);
    
      RtclOPtr pres(Tcl_NewListObj(0, nullptr));
      Tcl_ListObjAppendElement(nullptr, pres, fCmdnameObj[cmd.Command()]);
      Tcl_ListObjAppendElement(nullptr, pres, 
                               Tcl_NewIntObj(int(cmd.Request())));
      Tcl_ListObjAppendElement(nullptr, pres, Tcl_NewIntObj(int(cmd.Flags())));
      Tcl_ListObjAppendElement(nullptr, pres, Tcl_NewIntObj(int(cmd.Status())));

      switch (cmd.Command()) {
        case RlinkCommand::kCmdRreg:
        case RlinkCommand::kCmdAttn:
        case RlinkCommand::kCmdLabo:
          Tcl_ListObjAppendElement(nullptr, pres, 
                                   Tcl_NewIntObj(int(cmd.Data())));
          break;
          
        case RlinkCommand::kCmdRblk:
          Tcl_ListObjAppendElement(nullptr, pres, 
                                   Rtcl::NewListIntObj(cmd.Block()));
          break;
      }
      Tcl_ListObjAppendElement(nullptr, prlist, pres);
    }    
    if (!Rtcl::SetVarOrResult(args.Interp(), varlist, prlist)) return kERR;
  }
  
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_amap(RtclArgs& args)
{
  static RtclNameSet optset("-name|-testname|-testaddr|-insert|-erase|"
                            "-clear|-print");

  const RlinkAddrMap& addrmap = Obj().AddrMap();

  string opt;
  string name;
  uint16_t addr=0;

  if (args.NextOpt(opt, optset)) {
    if        (opt == "-name") {            // amap -name addr
      if (!args.GetArg("addr", addr)) return kERR;
      if (!args.AllDone()) return kERR;
      string   tstname;
      if(addrmap.Find(addr, tstname)) {
        args.SetResult(tstname);
      } else {
        return args.Quit(string("-E: address '") + args.PeekArgString(-1) +
                         "' not mapped");
      }

    } else if (opt == "-testname") {        // amap -testname name ?addr
      if (!args.GetArg("name", name)) return kERR;
      if (!args.GetArg("?addr", addr)) return kERR;
      if (!args.AllDone()) return kERR;
      uint16_t tstaddr;
      bool found = addrmap.Find(name, tstaddr);
      if (found && args.NOptMiss()==0) {      // if specified addr
        if (tstaddr != addr) found = false;   // verify addr
      }
      args.SetResult(int(found));

    } else if (opt == "-testaddr") {        // amap -testaddr addr
      if (!args.GetArg("addr", addr)) return kERR;
      if (!args.AllDone()) return kERR;
      string   tstname;
      args.SetResult(int(addrmap.Find(addr, tstname)));

    } else if (opt == "-insert") {          // amap -insert name addr
      uint16_t tstaddr=0;
      string   tstname;
      int      tstint=0;
      if (!args.GetArg("name", name)) return kERR;
      // enforce that the name is not a valid representation of an int
      if (Tcl_GetIntFromObj(nullptr, args[args.NDone()-1], &tstint) == kOK) 
        return args.Quit(string("-E: name should not look like an int but '")+
                         name + "' does");
      if (!args.GetArg("addr", addr)) return kERR;
      if (!args.AllDone()) return kERR;
      if (addrmap.Find(name, tstaddr)) 
        return args.Quit(string("-E: mapping already defined for '")+name+"'");
      if (addrmap.Find(addr, tstname)) 
        return args.Quit(string("-E: mapping already defined for address '") +
                         args.PeekArgString(-1) + "'");
      Obj().AddrMapInsert(name, addr);

    } else if (opt == "-erase") {           // amap -erase name
      if (!args.GetArg("name", name)) return kERR;
      if (!args.AllDone()) return kERR;
      if (!Obj().AddrMapErase(name)) 
        return args.Quit(string("-E: no mapping defined for '") + name + "'");

    } else if (opt == "-clear") {           // amap -clear
      if (!args.AllDone()) return kERR;
      Obj().AddrMapClear();

    } else if (opt == "-print") {           // amap -print
      if (!args.AllDone()) return kERR;
      ostringstream sos;
      addrmap.Print(sos);
      args.AppendResultLines(sos);
    }
    
  } else {
    if (!args.OptValid()) return kERR;
    if (!args.GetArg("?name", name)) return kERR;
    if (args.NOptMiss()==0) {               // amap name
      uint16_t tstaddr=0;
      if(addrmap.Find(name, tstaddr)) {
        args.SetResult(int(tstaddr));
      } else {
        return args.Quit(string("-E: no mapping defined for '") + name + "'");
      }

    } else {                                // amap
      RtclOPtr plist(Tcl_NewListObj(0, nullptr));
      const auto amap = addrmap.Amap();
      for (auto& o: amap) {
        Tcl_Obj* tpair[2];
        tpair[0] = Tcl_NewIntObj(o.first);
        tpair[1] = Tcl_NewStringObj(o.second.c_str(),o.second.length());
        Tcl_ListObjAppendElement(nullptr, plist, Tcl_NewListObj(2, tpair));
      }
      args.SetResult(plist);
    }
  }
  
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_errcnt(RtclArgs& args)
{
  static RtclNameSet optset("-clear|-increment");
  string opt;
  bool fclr = false;
  bool finc = false;
  
  while (args.NextOpt(opt, optset)) {
    if (opt == "-clear")     fclr = true;
    if (opt == "-increment") finc = true;
  }
  if (!args.AllDone()) return kERR;

  if (finc) Obj().Context().IncErrorCount();
  args.SetResult(int(Obj().Context().ErrorCount()));
  if (fclr) Obj().Context().ClearErrorCount();

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_wtlam(RtclArgs& args)
{
  double dtout;
  string rvn_apat;
  if (!args.GetArg("tout", dtout, 0.0)) return kERR;
  if (!args.GetArg("??varApat", rvn_apat)) return kERR;
  if (!args.AllDone()) return kERR;

  RerrMsg emsg;
  uint16_t apat = 0;
  Rtime twait;

  int irc = Obj().WaitAttn(Rtime(dtout), twait, apat, emsg);

  if (rvn_apat.length()) {
    if(!Rtcl::SetVar(args.Interp(), rvn_apat,
                     Tcl_NewIntObj(int(apat)))) return kERR;
  }

  if (irc == -2) {                          // IO error
    return args.Quit(emsg);
  } else if (irc == -1) {                   // timeout
    if (Obj().PrintLevel() >= 1) {
      RlogMsg lmsg(Obj().LogFile());
      lmsg << "-- wtlam to=" << RosPrintf(dtout, "f", 0,3)
           << " FAIL timeout" << endl;
      Obj().Context().IncErrorCount();
      args.SetResult(dtout);
      return kOK;
    }
  }

  if (Obj().PrintLevel() >= 3) {
    RlogMsg lmsg(Obj().LogFile());
    lmsg << "-- wtlam  apat=" << RosPrintf(apat,"x0",4);
    if (dtout == 0.) {
      lmsg << "  to=0 harvest only";
    } else {
      lmsg << "  to=" << RosPrintf(dtout, "f", 0,3)
           << "  T=" << RosPrintf(double(twait), "f", 0,3);
    }
    lmsg << "  OK" << endl;
  }
  
  args.SetResult(double(twait));
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_oob(RtclArgs& args)
{
  static RtclNameSet optset("-rlmon|-rlbmon|-rbmon|-sbcntl|-sbdata");

  string opt;
  uint16_t addr=0;
  uint16_t data=0;
  RerrMsg emsg;

  if (args.NextOpt(opt, optset)) {
    if        (opt == "-rlmon") {           // oob -rlmon (0|1)
      if (!args.GetArg("val", data, 1)) return kERR;
      if (!args.AllDone()) return kERR;
      addr = RlinkConnect:: kSBCNTL_V_RLMON; // rlmon enable bit
      if (!Obj().SndOob(0x00, (addr<<8)+data, emsg)) return args.Quit(emsg);

    } else if (opt == "-rlbmon") {          // oob -rlbmon (0|1)
      if (!args.GetArg("val", data, 1)) return kERR;
      if (!args.AllDone()) return kERR;
      addr = RlinkConnect:: kSBCNTL_V_RLBMON; // rlbmon enable bit
      if (!Obj().SndOob(0x00, (addr<<8)+data, emsg)) return args.Quit(emsg);

    } else if (opt == "-rbmon") {           // oob -rbmon (0|1)
      if (!args.GetArg("val", data, 1)) return kERR;
      if (!args.AllDone()) return kERR;
      addr = RlinkConnect:: kSBCNTL_V_RBMON; // rbmon enable bit
      if (!Obj().SndOob(0x00, (addr<<8)+data, emsg)) return args.Quit(emsg);

    } else if (opt == "-sbcntl") {          // oob -sbcntl bit (0|1)
      if (!args.GetArg("bit", addr, 15)) return kERR;
      if (!args.GetArg("val", data,  1)) return kERR;
      if (!args.AllDone()) return kERR;
      if (!Obj().SndOob(0x00, (addr<<8)+data, emsg)) return args.Quit(emsg);

    } else if (opt == "-sbdata") {          // oob -sbdata addr val
      if (!args.GetArg("bit", addr, 0x0ff)) return kERR;
      if (!args.GetArg("val", data)) return kERR;
      if (!args.AllDone()) return kERR;
      if (!Obj().SndOob(addr, data, emsg)) return args.Quit(emsg);
    }
  } else {
    return args.Quit(
      "-E: missing option, one of -rlmon,-rbmon,-sbcntl,-sbdata");
  }

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_rawread(RtclArgs& args)
{
  if (!(Obj().HasPort() &&
        Obj().Port().IsOpen())) return args.Quit("-E: port not open");
  return RtclRlinkPort::DoRawRead(args, Obj().Port());
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_rawrblk(RtclArgs& args)
{
  if (!(Obj().HasPort() &&
        Obj().Port().IsOpen())) return args.Quit("-E: port not open");
  size_t errcnt = 0;
  int rc = RtclRlinkPort::DoRawRblk(args, Obj().Port(), errcnt);
  Obj().Context().IncErrorCount(errcnt);
  return rc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_rawwblk(RtclArgs& args)
{
  if (!(Obj().HasPort() &&
        Obj().Port().IsOpen())) return args.Quit("-E: port not open");
  return RtclRlinkPort::DoRawWblk(args, Obj().Port());
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_stats(RtclArgs& args)
{
  RtclStats::Context cntx;
  if (!RtclStats::GetArgs(args, cntx)) return kERR;
  if (!RtclStats::Exec(args, cntx, Obj().Stats())) return kERR;
  if (!RtclStats::Exec(args, cntx, Obj().SndStats())) return kERR;
  if (!RtclStats::Exec(args, cntx, Obj().RcvStats())) return kERR;
  if (Obj().HasPort()) {
    if (!RtclStats::Exec(args, cntx, Obj().Port().Stats())) return kERR;
  }
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_log(RtclArgs& args)
{
  static RtclNameSet optset("-bare|-info|-warn|-error|-fatal");
  string opt;
  bool fbare = false;
  char tag   = 0;
  while (args.NextOpt(opt, optset)) {
    if (opt == "-bare")  fbare = true;
    if (opt == "-info")  tag = 'I';
    if (opt == "-warn")  tag = 'W';
    if (opt == "-error") tag = 'E';
    if (opt == "-fatal") tag = 'F';
  }

  string msg;
  if (!args.GetArg("msg", msg)) return kERR;
  if (!args.AllDone()) return kERR;
  if (Obj().PrintLevel() != 0 ||
      Obj().DumpLevel()  != 0 ||
      Obj().TraceLevel() != 0) {
    if (tag || fbare) {
      Obj().LogFile().Write(msg, tag);
    } else {
      Obj().LogFile().Write(string("# ") + msg);
    }
  }
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_print(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;

  ostringstream sos;
  Obj().Print(sos);
  args.SetResult(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_dump(RtclArgs& args)
{
  int detail=0;
  if (!GetArgsDump(args, detail)) return kERR;
  if (!args.AllDone()) return kERR;

  ostringstream sos;
  Obj().Dump(sos, 0, "", detail);
  args.SetResult(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_get(RtclArgs& args)
{
  // synchronize with server thread (really needed ??)
  lock_guard<RlinkConnect> lock(Obj());
  return fGets.M_get(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_set(RtclArgs& args)
{
  // synchronize with server thread (really needed ??)
  lock_guard<RlinkConnect> lock(Obj());
  return fSets.M_set(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  ostringstream sos;

  sos << "print base:  " << "addr " << RosPrintf(Obj().LogBaseAddr(), "d", 2)
      << "  data " << RosPrintf(Obj().LogBaseData(), "d", 2)
      << "  stat " << RosPrintf(Obj().LogBaseStat(), "d", 2) << endl;
  sos << "logfile:     " << Obj().LogFile().Name()
      << "   printlevel " << Obj().PrintLevel()
      << "   dumplevel " << Obj().DumpLevel();

  args.AppendResultLines(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclRlinkConnect::GetAddr(RtclArgs& args, uint16_t& addr)
{
  Tcl_Obj* pobj=0;
  if (!args.GetArg("addr", pobj)) return kERR;

  int tstint=0;
  // if a number is given..
  if (Tcl_GetIntFromObj(nullptr, pobj, &tstint) == kOK) {
    if (tstint >= 0 && tstint <= 0xffff) {
      addr = uint16_t(tstint);
    } else {
      args.AppendResult("-E: value '", Tcl_GetString(pobj), 
                        "' for 'addr' out of range 0...0xffff", nullptr);
      return false;
    }
  // if a name is given 
  } else {
    string name(Tcl_GetString(pobj));
    uint16_t tstaddr=0;
    if (Obj().AddrMap().Find(name, tstaddr)) {
      addr = tstaddr;
    } else {
      args.AppendResult("-E: no address mapping known for '", 
                        Tcl_GetString(pobj), "'", nullptr);
      return false;
    }
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclRlinkConnect::GetVarName(RtclArgs& args, const char* argname, 
                                  size_t nind, 
                                  std::vector<std::string>& varname)
{
  while (varname.size() < nind+1) varname.push_back(string());
  string name;
  if (!args.GetArg(argname, name)) return false;
  if (name.length()) {                      // if variable defined
    char c = name[0];
    if (isdigit(c) || c=='+' || c=='-' ) {  // check for mistaken number
      args.AppendResult("-E: invalid variable name '", name.c_str(), 
                        "': looks like a number", nullptr);
      return false;
    }
  }
  
  varname[nind] = name;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclRlinkConnect::ConfigBase(RtclArgs& args, uint32_t& base)
{
  uint32_t tmp = base;
  if (!args.Config("??base", tmp, 16, 2)) return false;
  if (tmp != base && tmp != 2 && tmp !=8 && tmp != 16) {
    args.AppendResult("-E: base must be 2, 8, or 16, found '",
                      args.PeekArgString(-1), "'", nullptr);
    return false;
  }
  base = tmp;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclRlinkConnect::ClistNonEmpty(RtclArgs& args,
                                     const RlinkCommandList& clist)
{
  if (clist.Size() == 0) {
    args.AppendResult("-E: -edata, -edone, or -estat "
                      "not allowed on empty command list", nullptr);
    return false;
  }
  return true;
}

} // end namespace Retro
