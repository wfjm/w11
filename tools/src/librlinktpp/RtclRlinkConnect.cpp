// $Id: RtclRlinkConnect.cpp 380 2011-04-25 18:14:52Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-04-23   380   1.1    use boost/bind instead of RmethDsc
// 2011-04-17   376   1.0.1  M_wtlam: now correct log levels
// 2011-03-27   374   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRlinkConnect.cpp 380 2011-04-25 18:14:52Z mueller $
  \brief   Implemenation of class RtclRlinkConnect.
 */

#include <ctype.h>

#include <stdexcept>
#include <iostream>

#include "boost/bind.hpp"

#include "librtcltools/Rtcl.hpp"
#include "librtcltools/RtclOPtr.hpp"
#include "librtcltools/RtclNameSet.hpp"
#include "librtcltools/RtclStats.hpp"
#include "librtools/RosPrintf.hpp"
#include "librlink/RlinkCommandList.hpp"
#include "RtclRlinkConnect.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::RtclRlinkConnect
  \brief FIXME_docs
*/

//------------------------------------------+-----------------------------------
//! Default constructor

RtclRlinkConnect::RtclRlinkConnect(Tcl_Interp* interp, const char* name)
  : RtclProxyOwned<RlinkConnect>("RlinkConnect", interp, name, 
                                 new RlinkConnect()),
    fErrCnt(0),
    fLogFileName("-")
{
  AddMeth("open",     boost::bind(&RtclRlinkConnect::M_open,    this, _1));
  AddMeth("close",    boost::bind(&RtclRlinkConnect::M_close,   this, _1));
  AddMeth("exec",     boost::bind(&RtclRlinkConnect::M_exec,    this, _1));
  AddMeth("amap",     boost::bind(&RtclRlinkConnect::M_amap,    this, _1));
  AddMeth("errcnt",   boost::bind(&RtclRlinkConnect::M_errcnt,  this, _1));
  AddMeth("wtlam",    boost::bind(&RtclRlinkConnect::M_wtlam,   this, _1));
  AddMeth("oob",      boost::bind(&RtclRlinkConnect::M_oob,     this, _1));
  AddMeth("stats",    boost::bind(&RtclRlinkConnect::M_stats,   this, _1));
  AddMeth("log",      boost::bind(&RtclRlinkConnect::M_log,     this, _1));
  AddMeth("print",    boost::bind(&RtclRlinkConnect::M_print,   this, _1));
  AddMeth("dump",     boost::bind(&RtclRlinkConnect::M_dump,    this, _1));
  AddMeth("config",   boost::bind(&RtclRlinkConnect::M_config,  this, _1));
  AddMeth("$default", boost::bind(&RtclRlinkConnect::M_default, this, _1));

  for (size_t i=0; i<8; i++) {
    fCmdnameObj[i] = Tcl_NewStringObj(RlinkCommand::CommandName(i), -1);
  }
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
    if (!Obj().Open(path, emsg)) {
      args.AppendResult(emsg.Message());
      return kERR;
    }
  } else {                                  // open 
    string name = Obj().IsOpen() ? Obj().Port()->Url() : string();
    args.SetResult(name);
  }
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_close(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;

  if (!Obj().IsOpen()) {
    args.AppendResult("-E: port not open", NULL);
    return kERR;
  }
  Obj().Close();
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_exec(RtclArgs& args)
{
  static RtclNameSet optset("-rreg|-rblk|-wreg|-wblk|-stat|-attn|-init|"
                            "-edata|-estat|-estatdef|"
                            "-volatile|-print|-dump|-rlist");

  Tcl_Interp* interp = args.Interp();

  RlinkCommandList clist;
  string opt;
  uint16_t addr;

  vector<string> vardata;
  vector<string> varstat;
  string varprint;
  string vardump;
  string varlist;

  uint8_t estatdef_val = 0x00;
  uint8_t estatdef_msk = 0xff;

  while (args.NextOpt(opt, optset)) {
    
    size_t lsize = clist.Size();
    if        (opt == "-rreg") {            // -rreg addr ?varData ?varStat ---
      if (!GetAddr(args, Obj(), addr)) return kERR;
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddRreg(addr);

    } else if (opt == "-rblk") {            // -rblk addr size ?varData ?varStat
      int32_t bsize;
      if (!GetAddr(args, Obj(), addr)) return kERR;
      if (!args.GetArg("bsize", bsize, 1, 256)) return kERR;
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddRblk(addr, (size_t) bsize);

    } else if (opt == "-wreg") {            // -wreg addr data ?varStat -------
      uint16_t data;
      if (!GetAddr(args, Obj(), addr)) return kERR;
      if (!args.GetArg("data", data)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWreg(addr, data);

    } else if (opt == "-wblk") {            // -wblk addr block ?varStat ------
      vector<uint16_t> block;
      if (!GetAddr(args, Obj(), addr)) return kERR;
      if (!args.GetArg("data", block, 1, 256)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWblk(addr, block);

    } else if (opt == "-stat") {            // -stat varData ?varStat ---------
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddStat();

    } else if (opt == "-attn") {            // -attn varData ?varStat ---------
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddAttn();

    } else if (opt == "-init") {            // -init addr data ?varStat -------
      uint16_t data;
      if (!GetAddr(args, Obj(), addr)) return kERR;
      if (!args.GetArg("data", data)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddInit(addr, data);

    } else if (opt == "-edata") {           // -edata data ?mask --------------
      if (!ClistNonEmpty(args, clist)) return kERR;
      if (clist[lsize-1].Expect()==0) {
        clist.LastExpect(new RlinkCommandExpect());
      }
      if (clist[lsize-1].Command() == RlinkCommand::kCmdRblk) {
        vector<uint16_t> data;
        vector<uint16_t> mask;
        size_t bsize = clist[lsize-1].BlockSize();
        if (!args.GetArg("data", data, 0, bsize)) return kERR;
        if (!args.GetArg("??mask", mask, 0, bsize)) return kERR;
        clist[lsize-1].Expect()->SetBlock(data, mask);
      } else {
        uint16_t data=0;
        uint16_t mask=0;
        if (!args.GetArg("data", data)) return kERR;
        if (!args.GetArg("??mask", mask)) return kERR;
        clist[lsize-1].Expect()->SetData(data, mask);
      }

    } else if (opt == "-estat") {           // -estat ?stat ?mask -------------
      if (!ClistNonEmpty(args, clist)) return kERR;
      uint8_t stat=0;
      uint8_t mask=0;
      if (!args.GetArg("??stat", stat)) return kERR;
      if (!args.GetArg("??mask", mask)) return kERR;
      if (args.NOptMiss() == 2)  mask = 0xff;
      if (clist[lsize-1].Expect()==0) {
        clist.LastExpect(new RlinkCommandExpect());
      }
      clist[lsize-1].Expect()->SetStatus(stat, mask);

    } else if (opt == "-estatdef") {        // -estatdef ?stat ?mask -----------
      uint8_t stat=0;
      uint8_t mask=0;
      if (!args.GetArg("??stat", stat)) return kERR;
      if (!args.GetArg("??mask", mask)) return kERR;
      if (args.NOptMiss() == 2)  mask = 0xff;
      estatdef_val = stat;
      estatdef_msk = mask;

    } else if (opt == "-volatile") {        // -volatile ----------------------
      if (!ClistNonEmpty(args, clist)) return kERR;
      clist.LastVolatile();

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

    if (lsize != clist.Size()) {            // cmd added to clist (ind=lsize!)
      if (estatdef_msk != 0xff) {             // estatdef defined
        if (clist[lsize].Expect()==0) {
          clist.LastExpect(new RlinkCommandExpect());
        }
        clist[lsize].Expect()->SetStatus(estatdef_val, estatdef_msk); 
      }
    }
  }

  int nact = 0;
  if (varprint == "-") nact += 1;
  if (vardump  == "-") nact += 1;
  if (varlist  == "-") nact += 1;
  if (nact > 1) {
    args.AppendResult("-E: more that one of -print,-dump,-list without ",
                      "target variable found", NULL);
    return kERR;
  }

  if (!args.AllDone()) return kERR;

  RerrMsg emsg;
  
  if (!Obj().Exec(clist, emsg)) {
    args.AppendResult(emsg.Message());
    return kERR;
  }

  for (size_t icmd=0; icmd<clist.Size(); icmd++) {
    RlinkCommand& cmd = clist[icmd];
    
    if (cmd.TestFlagAny(RlinkCommand::kFlagChkStat)) fErrCnt += 1;
    if (cmd.TestFlagAny(RlinkCommand::kFlagChkData)) fErrCnt += 1;

    if (icmd<vardata.size() && !vardata[icmd].empty()) {
      RtclOPtr pres;
      vector<uint16_t> retstat;
      RtclOPtr pele;
      switch (cmd.Command()) {
        case RlinkCommand::kCmdRreg:
        case RlinkCommand::kCmdAttn:
          pres = Tcl_NewIntObj((int)cmd.Data());
          break;

        case RlinkCommand::kCmdRblk:
          pres = Rtcl::NewListIntObj(cmd.Block());
          break;

        case RlinkCommand::kCmdStat:
          retstat.resize(2);
          retstat[0] = cmd.StatRequest();
          retstat[1] = cmd.Data();
          pres = Rtcl::NewListIntObj(retstat);
          break;
      }
      if(!Rtcl::SetVar(interp, vardata[icmd], pres)) return kERR;
    }

    if (icmd<varstat.size() && !varstat[icmd].empty()) {
      RtclOPtr pres = Tcl_NewIntObj((int)cmd.Status());
      if (!Rtcl::SetVar(interp, varstat[icmd], pres)) return kERR;
    }
  }

  if (!varprint.empty()) {
    ostringstream sos;
    const RlinkConnect::LogOpts& logopts = Obj().GetLogOpts();
    clist.Print(sos, &Obj().AddrMap(), logopts.baseaddr, logopts.basedata, 
                logopts.basestat);
    RtclOPtr pobj = Rtcl::NewLinesObj(sos);
    if (!Rtcl::SetVarOrResult(args.Interp(), varprint, pobj)) return kERR;
  }

  if (!vardump.empty()) {
    ostringstream sos;
    clist.Dump(sos, 0);
    RtclOPtr pobj = Rtcl::NewLinesObj(sos);
    if (!Rtcl::SetVarOrResult(args.Interp(), vardump, pobj)) return kERR;
  }

  if (!varlist.empty()) {
    RtclOPtr prlist = Tcl_NewListObj(0, NULL);
    for (size_t icmd=0; icmd<clist.Size(); icmd++) {
      RlinkCommand& cmd(clist[icmd]);
    
      RtclOPtr pres = Tcl_NewListObj(0, NULL);
      Tcl_ListObjAppendElement(NULL, pres, fCmdnameObj[cmd.Command()]);
      Tcl_ListObjAppendElement(NULL, pres, Tcl_NewIntObj((int)cmd.Request()));
      Tcl_ListObjAppendElement(NULL, pres, Tcl_NewIntObj((int)cmd.Flags()));
      Tcl_ListObjAppendElement(NULL, pres, Tcl_NewIntObj((int)cmd.Status()));

      switch (cmd.Command()) {
        case RlinkCommand::kCmdRreg:
        case RlinkCommand::kCmdAttn:
          Tcl_ListObjAppendElement(NULL, pres, Tcl_NewIntObj((int)cmd.Data()));
          break;
          
        case RlinkCommand::kCmdRblk:
          Tcl_ListObjAppendElement(NULL, pres, 
                                   Rtcl::NewListIntObj(cmd.Block()));
          break;

        case RlinkCommand::kCmdStat:
          Tcl_ListObjAppendElement(NULL, pres,
                                   Tcl_NewIntObj((int)cmd.StatRequest()));
          Tcl_ListObjAppendElement(NULL, pres, Tcl_NewIntObj((int)cmd.Data()));
          break;
      }
      Tcl_ListObjAppendElement(NULL, prlist, pres);
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
      if (!args.GetArg("addr", addr, 0x00ff)) return kERR;
      if (!args.AllDone()) return kERR;
      string   tstname;
      if(addrmap.Find(addr, tstname)) {
        args.SetResult(tstname);
      } else {
        args.AppendResult("-E: address \"", args.PeekArgString(-1), 
                          "\" not mapped", NULL);
        return kERR;
      }

    } else if (opt == "-testname") {        // amap -testname name
      if (!args.GetArg("name", name)) return kERR;
      if (!args.AllDone()) return kERR;
      uint16_t tstaddr;
      args.SetResult(int(addrmap.Find(name, tstaddr)));

    } else if (opt == "-testaddr") {        // amap -testaddr addr
      if (!args.GetArg("addr", addr, 0x00ff)) return kERR;
      if (!args.AllDone()) return kERR;
      string   tstname;
      args.SetResult(int(addrmap.Find(addr, tstname)));

    } else if (opt == "-insert") {          // amap -insert name addr
      uint16_t tstaddr;
      string   tstname;
      int      tstint;
      if (!args.GetArg("name", name)) return kERR;
      // enforce that the name is not a valid representation of an int
      if (Tcl_GetIntFromObj(NULL, args[args.NDone()-1], &tstint) == kOK) {
        args.AppendResult("-E: name should not look like an int but \"", 
                          name.c_str(), "\" does", NULL);
        return kERR;
      }
      if (!args.GetArg("addr", addr, 0x00ff)) return kERR;
      if (!args.AllDone()) return kERR;
      if (addrmap.Find(name, tstaddr)) {
        args.AppendResult("-E: mapping already defined for \"", name.c_str(),
                          "\"", NULL);
        return kERR;
      }
      if (addrmap.Find(addr, tstname)) {
        args.AppendResult("-E: mapping already defined for address \"", 
                          args.PeekArgString(-1), "\"", NULL);
        return kERR;
      }
      Obj().AddrMapInsert(name, addr);

    } else if (opt == "-erase") {           // amap -erase name
      if (!args.GetArg("name", name)) return kERR;
      if (!args.AllDone()) return kERR;
      if (!Obj().AddrMapErase(name)) {
        args.AppendResult("-E: no mapping defined for \"", name.c_str(),
                          "\"", NULL);
        return kERR;
      }

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
      uint16_t tstaddr;
      if(addrmap.Find(name, tstaddr)) {
        args.SetResult(int(tstaddr));
      } else {
        args.AppendResult("-E: no mapping defined for \"", name.c_str(), 
                          "\"", NULL);
        return kERR;
      }

    } else {                                // amap
      RtclOPtr plist = Tcl_NewListObj(0, NULL);
      const RlinkAddrMap::amap_t amap = addrmap.Amap();
      for (RlinkAddrMap::amap_cit_t it=amap.begin(); it!=amap.end(); it++) {
        Tcl_Obj* tpair[2];
        tpair[0] = Tcl_NewIntObj(it->first);
        tpair[1] = Tcl_NewStringObj((it->second).c_str(),(it->second).length());
        Tcl_ListObjAppendElement(NULL, plist, Tcl_NewListObj(2, tpair));
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

int RtclRlinkConnect::M_wtlam(RtclArgs& args)
{
  double tout;
  if (!args.GetArg("tout", tout, 0.001)) return kERR;
  if (!args.AllDone()) return kERR;

  RerrMsg emsg;
  double twait = Obj().WaitAttn(tout, emsg);

  if (twait == -2.) {
    args.AppendResult(emsg.Message());
    return kERR;
  } else if (twait == -1.) {
    if (Obj().GetLogOpts().printlevel >= 1) {
      Obj().LogFile()() << "-- wtlam to=" << RosPrintf(tout, "f", 0,3)
                        << " FAIL timeout" << endl;
      fErrCnt += 1;
      args.SetResult(tout);
      return kOK;
    }
  }

  if (Obj().GetLogOpts().printlevel >= 3) {
    Obj().LogFile()() << "-- wtlam to=" << RosPrintf(tout, "f", 0,3)
                      << "  T=" << RosPrintf(twait, "f", 0,3)
                      << "  OK" << endl;
  }
  
  args.SetResult(twait);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_oob(RtclArgs& args)
{
  static RtclNameSet optset("-rlmon|-rbmon|-sbcntl|-sbdata");

  string opt;
  uint16_t addr;
  uint16_t data;
  RerrMsg emsg;

  if (args.NextOpt(opt, optset)) {
    if        (opt == "-rlmon") {           // oob -rlmon (0|1)
      if (!args.GetArg("val", data, 1)) return kERR;
      if (!args.AllDone()) return kERR;
      addr = 15;                              // rlmon on bit 15
      if (!Obj().SndOob(0x00, (addr<<8)+data, emsg)) {
        args.AppendResult(emsg.Message());
        return kERR;
      }

    } else if (opt == "-rbmon") {           // oob -rbmon (0|1)
      if (!args.GetArg("val", data, 1)) return kERR;
      if (!args.AllDone()) return kERR;
      addr = 14;                              // rbmon on bit 14
      if (!Obj().SndOob(0x00, (addr<<8)+data, emsg)) {
        args.AppendResult(emsg.Message());
        return kERR;
      }

    } else if (opt == "-sbcntl") {          // oob -sbcntl bit (0|1)
      if (!args.GetArg("bit", addr, 15)) return kERR;
      if (!args.GetArg("val", data,  1)) return kERR;
      if (!args.AllDone()) return kERR;
      if (!Obj().SndOob(0x00, (addr<<8)+data, emsg)) {
        args.AppendResult(emsg.Message());
        return kERR;
      }

    } else if (opt == "-sbdata") {          // oob -sbdata addr val
      if (!args.GetArg("bit", addr, 0x0ff)) return kERR;
      if (!args.GetArg("val", data)) return kERR;
      if (!args.AllDone()) return kERR;
      if (!Obj().SndOob(addr, data, emsg)) {
        args.AppendResult(emsg.Message());
        return kERR;
      }
    }
  } else {
     args.AppendResult("-E: missing option, one of "
                       "-rlmon,-rbmon,-sbcntl,-sbdata",
                       NULL);
     return kERR;
  }

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_stats(RtclArgs& args)
{
  RtclStats::Context cntx;
  if (!RtclStats::GetArgs(args, cntx)) return kERR;
  if (!RtclStats::Exec(args, cntx, Obj().Stats())) return kERR;
  if (Obj().Port()) {
    if (!RtclStats::Exec(args, cntx, Obj().Port()->Stats())) return kERR;
  }
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_log(RtclArgs& args)
{
  string msg;
  if (!args.GetArg("msg", msg)) return kERR;
  if (!args.AllDone()) return kERR;
  if (Obj().GetLogOpts().printlevel != 0 ||
      Obj().GetLogOpts().dumplevel  != 0 ||
      Obj().GetLogOpts().tracelevel != 0) {
    Obj().LogFile()() << "# " << msg << endl;
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
  if (!args.AllDone()) return kERR;

  ostringstream sos;
  Obj().Dump(sos, 0);
  args.SetResult(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_config(RtclArgs& args)
{
  static RtclNameSet optset("-baseaddr|-basedata|-basestat|"
                            "-logfile|-logprintlevel|-logdumplevel|"
                            "-logtracelevel");
 
  RlinkConnect::LogOpts logopts = Obj().GetLogOpts();

  if (args.NDone() == (size_t)args.Objc()) {
    ostringstream sos;
    sos << "-baseaddr " << RosPrintf(logopts.baseaddr, "d")
        << " -basedata " << RosPrintf(logopts.basedata, "d")
        << " -basestat " << RosPrintf(logopts.basestat, "d")
        << " -logfile {" << fLogFileName << "}"
        << " -logprintlevel " << RosPrintf(logopts.printlevel, "d")
        << " -logdumplevel " << RosPrintf(logopts.dumplevel, "d")
        << " -logtracelevel " << RosPrintf(logopts.tracelevel, "d");
    args.AppendResult(sos);
    return kOK;
  }

  string opt;
  while (args.NextOpt(opt, optset)) {
    if        (opt == "-baseaddr") {        // -baseaddr ?base -----------------
      if (!ConfigBase(args, logopts.baseaddr)) return kERR;
      if (args.NOptMiss() == 0) Obj().SetLogOpts(logopts);

    } else if (opt == "-basedata") {        // -basedata ?base -----------------
      if (!ConfigBase(args, logopts.basedata)) return kERR;
      if (args.NOptMiss() == 0) Obj().SetLogOpts(logopts);

    } else if (opt == "-basestat") {        // -basestat ?base -----------------
      if (!ConfigBase(args, logopts.basestat)) return kERR;
      if (args.NOptMiss() == 0) Obj().SetLogOpts(logopts);

    } else if (opt == "-logfile") {         // -logfile ?name ------------------
      if (!args.Config("??name", fLogFileName)) return false;
      if (args.NOptMiss() == 0) {             // new filename ?
        if (fLogFileName == "-") {
          Obj().LogUseStream(&cout);
        } else {
          if (!Obj().LogOpen(fLogFileName)) {
            args.AppendResult("-E: open failed for \"", 
                              fLogFileName.c_str(), "\", using stdout", NULL);
            Obj().LogUseStream(&cout);
            fLogFileName = "-";
            return kERR;
          }
        }
      }

    } else if (opt == "-logprintlevel") {   // -logprintlevel ?loglevel --------
      if (!args.Config("??loglevel", logopts.printlevel, 3)) return false;
      if (args.NOptMiss() == 0) Obj().SetLogOpts(logopts);

    } else if (opt == "-logdumplevel") {    // -logdumplevel ?loglevel ---------
      if (!args.Config("??loglevel", logopts.dumplevel, 3)) return false;
      if (args.NOptMiss() == 0) Obj().SetLogOpts(logopts);

    } else if (opt == "-logtracelevel") {   // -logtracelevel ?loglevel --------
      if (!args.Config("??loglevel", logopts.tracelevel, 3)) return false;
      if (args.NOptMiss() == 0) Obj().SetLogOpts(logopts);
    }
  }

  if (!args.AllDone()) return kERR;
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkConnect::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  ostringstream sos;
  const RlinkConnect::LogOpts& logopts = Obj().GetLogOpts();

  sos << "print base:  " << "addr " << RosPrintf(logopts.baseaddr, "d", 2)
      << "  data " << RosPrintf(logopts.basedata, "d", 2)
      << "  stat " << RosPrintf(logopts.basestat, "d", 2) << endl;
  sos << "logfile:     " << fLogFileName
      << "   printlevel " << logopts.printlevel
      << "   dumplevel " << logopts.dumplevel;

  args.AppendResultLines(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclRlinkConnect::GetAddr(RtclArgs& args, RlinkConnect& conn, 
                               uint16_t& addr)
{
  Tcl_Obj* pobj=0;
  if (!args.GetArg("addr", pobj)) return kERR;

  int tstint;
  // if a number is given..
  if (Tcl_GetIntFromObj(NULL, pobj, &tstint) == kOK) {
    if (tstint >= 0 && tstint <= 0x00ff) {
      addr = (uint16_t)tstint;
    } else {
      args.AppendResult("-E: value \"", Tcl_GetString(pobj), 
                        "\" for \"addr\" out of range 0...0x00ff", NULL);
      return false;
    }
  // if a name is given 
  } else {
    string name(Tcl_GetString(pobj));
    uint16_t tstaddr;
    if (Obj().AddrMap().Find(name, tstaddr)) {
      addr = tstaddr;
    } else {
      args.AppendResult("-E: no address mapping known for \"", 
                        Tcl_GetString(pobj), "\"", NULL);
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
      args.AppendResult("-E: invalid variable name \"", name.c_str(), 
                        "\": looks like a number", NULL);
      return false;
    }
  }
  
  varname[nind] = name;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclRlinkConnect::ConfigBase(RtclArgs& args, size_t& base)
{
  size_t tmp = base;
  if (!args.Config("??base", tmp, 16, 2)) return false;
  if (tmp != base && tmp != 2 && tmp !=8 && tmp != 16) {
    args.AppendResult("-E: base must be 2, 8, or 16, found \"",
                      args.PeekArgString(-1), "\"", NULL);
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
    args.AppendResult("-E: -volatile not allowed on empty command list", NULL);
    return false;
  }
  return true;
}

//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_RtclRlinkConnect_NoInline))
#define inline
//#include "RtclRlinkConnect.ipp"
#undef  inline
#endif
