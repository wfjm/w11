// $Id: RtclRw11Cpu.cpp 504 2013-04-13 15:37:24Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-04-02   502   1.0    Initial version
// 2013-02-02   480   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11Cpu.cpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Implemenation of RtclRw11Cpu.
*/

#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>

#include <vector>
#include <memory>
#include <sstream>

#include "boost/bind.hpp"

#include "librtools/RerrMsg.hpp"
#include "librtools/RlogMsg.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtcltools/Rtcl.hpp"
#include "librtcltools/RtclStats.hpp"
#include "librtcltools/RtclOPtr.hpp"
#include "librtcltools/RtclNameSet.hpp"
#include "librlink/RlinkCommandList.hpp"

#include "RtclRw11.hpp"

#include "RtclRw11CntlFactory.hpp"
#include "librw11/Rw11Cntl.hpp"

#include "RtclRw11Cpu.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11Cpu
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RtclRw11Cpu::RtclRw11Cpu(const std::string& type)
  : RtclProxyBase(type),
    fGets()
{
  AddMeth("add",      boost::bind(&RtclRw11Cpu::M_add,     this, _1));
  AddMeth("cp",       boost::bind(&RtclRw11Cpu::M_cp,      this, _1));
  AddMeth("wtcpu",    boost::bind(&RtclRw11Cpu::M_wtcpu,   this, _1));
  AddMeth("deposit",  boost::bind(&RtclRw11Cpu::M_deposit, this, _1));
  AddMeth("examine",  boost::bind(&RtclRw11Cpu::M_examine, this, _1));
  AddMeth("lsmem",    boost::bind(&RtclRw11Cpu::M_lsmem,   this, _1));
  AddMeth("ldabs",    boost::bind(&RtclRw11Cpu::M_ldabs,   this, _1));
  AddMeth("ldasm",    boost::bind(&RtclRw11Cpu::M_ldasm,   this, _1));
  AddMeth("boot",     boost::bind(&RtclRw11Cpu::M_boot,    this, _1));
  AddMeth("get",      boost::bind(&RtclRw11Cpu::M_get,     this, _1));
  AddMeth("set",      boost::bind(&RtclRw11Cpu::M_set,     this, _1));
  AddMeth("stats",    boost::bind(&RtclRw11Cpu::M_stats,   this, _1));
  AddMeth("dump",     boost::bind(&RtclRw11Cpu::M_dump,    this, _1));
  AddMeth("$default", boost::bind(&RtclRw11Cpu::M_default, this, _1));
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11Cpu::~RtclRw11Cpu()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cpu::M_add(RtclArgs& args)
{
  return RtclRw11CntlFactory(args, *this);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cpu::M_cp(RtclArgs& args)
{
  static RtclNameSet optset("-rr|-rr0|-rr1|-rr2|-rr3|-rr4|-rr5|-rr6|-rr7|"
                            "-wr|-wr0|-wr1|-wr2|-wr3|-wr4|-wr5|-wr6|-wr7|"
                            "-rsp|-rpc|-wsp|-wpc|"
                            "-rps|-wps|"
                            "-wal|-wah|-rm|-rmi|-wm|-wmi|-brm|-bwm|"
                            "-stapc|-start|-stop|-continue|-step|-reset|"
                            "-ribrb|-wibrb|-wibrbbe|-ribr|-wibr|"
                            "-rconf|-rstat|"
                            "-edata|-estat|-estatdef"
                            );

  Tcl_Interp* interp = args.Interp();

  RlinkCommandList clist;
  string opt;
  uint16_t base = Obj().Base();

  vector<string> vardata;
  vector<string> varstat;

  uint8_t estatdef_val = 0x00;
  uint8_t estatdef_msk = 0xff;

  bool setcpugo = false;

  while (args.NextOpt(opt, optset)) {
    size_t lsize = clist.Size();
    
    // map register read/write
    if (opt == "-rsp") opt = "-rr6";
    if (opt == "-rpc") opt = "-rr7";
    if (opt == "-wsp") opt = "-wr6";
    if (opt == "-wpc") opt = "-wr7";
    
    int regnum = 0;
    if (opt.substr(0,3) == "-rr" || opt.substr(0,3) == "-wr" ) {
      if (opt.length() == 3) {
        if (!args.GetArg("regnum", regnum, 0, 7)) return kERR;
      } else {
        regnum = opt[3] - '0';
        regnum &= 0x7;                      // to be sure...
      }
      opt = opt.substr(0,3);
    }    

    if        (opt == "-rr") {              // -rr* ?varData ?varStat --------
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddRreg(base + Rw11Cpu::kCp_addr_r0 + regnum);

    } else if (opt == "-wr") {              // -wr* data ?varStat ------------
      uint16_t data;
      if (!args.GetArg("data", data)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWreg(base + Rw11Cpu::kCp_addr_r0 + regnum, data);

    } else if (opt == "-rps") {             // -rps ?varData ?varStat --------
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddRreg(base + Rw11Cpu::kCp_addr_psw);

    } else if (opt == "-wps") {             // -wps data ?varStat ------------
      uint16_t data;
      if (!args.GetArg("data", data)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWreg(base + Rw11Cpu::kCp_addr_psw, data);

    } else if (opt == "-wal") {             // -wal data ?varStat ------------
      uint16_t data;
      if (!args.GetArg("al", data)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWreg(base + Rw11Cpu::kCp_addr_al, data);

    } else if (opt == "-wah") {             // -wah data ?varStat ------------
      uint16_t data;
      if (!args.GetArg("ah", data)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWreg(base + Rw11Cpu::kCp_addr_ah, data);

    } else if (opt == "-rm" ||              // -rm(i) ?varData ?varStat ------
               opt == "-rmi") {
      uint16_t addr = opt=="-rm" ? Rw11Cpu::kCp_addr_mem : Rw11Cpu::kCp_addr_memi;
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddRreg(base + addr);

    } else if (opt == "-wm" ||              // -wm(i) data ?varStat -
               opt == "-wmi") {
      uint16_t addr = opt=="-wm" ? Rw11Cpu::kCp_addr_mem : 
                                   Rw11Cpu::kCp_addr_memi;
      uint16_t data;
      if (!args.GetArg("data", data)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWreg(base + addr, data);

    } else if (opt == "-brm") {             // -brm size ?varData ?varStat ---
      int32_t bsize;
      if (!args.GetArg("bsize", bsize, 1, 256)) return kERR;
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddRblk(base + Rw11Cpu::kCp_addr_memi, (size_t) bsize);

    } else if (opt == "-bwm") {             // -bwm block ?varStat -----------
      vector<uint16_t> block;
      if (!args.GetArg("data", block, 1, 256)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWblk(base + Rw11Cpu::kCp_addr_memi, block);
    
    } else if (opt == "-stapc") {           // -stapc addr ?varStat ----------
      uint16_t data;
      if (!args.GetArg("data", data)) return kERR;
      if (!GetVarName(args, "??varStat", lsize+1, varstat)) return kERR;  
      clist.AddWreg(base + Rw11Cpu::kCp_addr_pc, data);
      clist.AddWreg(base + Rw11Cpu::kCp_addr_cntl, Rw11Cpu::kCp_func_start);
      setcpugo = true;

    } else if (opt == "-start") {           // -start ?varStat ---------------
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWreg(base + Rw11Cpu::kCp_addr_cntl, Rw11Cpu::kCp_func_start);
      setcpugo = true;

    } else if (opt == "-stop") {            // -stop ?varStat ----------------
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWreg(base + Rw11Cpu::kCp_addr_cntl, Rw11Cpu::kCp_func_stop);

    } else if (opt == "-continue") {        // -continue ?varStat ------------
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWreg(base + Rw11Cpu::kCp_addr_cntl, Rw11Cpu::kCp_func_cont);
      setcpugo = true;

    } else if (opt == "-step") {            // -step ?varStat ----------------
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWreg(base + Rw11Cpu::kCp_addr_cntl, Rw11Cpu::kCp_func_step);

    } else if (opt == "-reset") {           // -reset ?varStat ---------------
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWreg(base + Rw11Cpu::kCp_addr_cntl, Rw11Cpu::kCp_func_reset);

    } else if (opt == "-ribrb") {           // -ribrb ?varData ?varStat ------
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddRreg(base + Rw11Cpu::kCp_addr_ibrb);

    } else if (opt == "-wibrb") {           // -wibrb base ?varStat ----------
      uint16_t data;
      if (!args.GetArg("base", data)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      data &= 0177700;                        // clear byte enables 
      clist.AddWreg(base + Rw11Cpu::kCp_addr_ibrb, data);

    } else if (opt == "-wibrbbe") {         // -wibrbbe base be ?varStat -----
      uint16_t data;
      uint16_t be;
      if (!args.GetArg("base", data)) return kERR;
      if (!args.GetArg("be", be, 0x3)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      data &= 0177700;                        // clear byte enables from base
      if (be == 0) be = 0x3;                  // map be 0 -> be 3
      data |= be;                             // set byte enables 
      clist.AddWreg(base + Rw11Cpu::kCp_addr_ibrb, data);

    } else if (opt == "-ribr") {           // -ribr off ?varData ?varStat ----
      uint16_t off;
      if (!args.GetArg("off",  off, 63)) return kERR;
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddRreg(base + Rw11Cpu::kCp_addr_ibr + off/2);

    } else if (opt == "-wibr") {           // -wibrb off data ?varStat --------
      uint16_t off;
      uint16_t data;
      if (!args.GetArg("off",  off, 63)) return kERR;
      if (!args.GetArg("data", data)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddWreg(base + Rw11Cpu::kCp_addr_ibr + off/2, data);

    } else if (opt == "-rconf") {           // -rconf ?varData ?varStat ------
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddRreg(base + Rw11Cpu::kCp_addr_conf);

    } else if (opt == "-rstat") {           // -rstat ?varData ?varStat ------
      if (!GetVarName(args, "??varData", lsize, vardata)) return kERR;
      if (!GetVarName(args, "??varStat", lsize, varstat)) return kERR;
      clist.AddRreg(base + Rw11Cpu::kCp_addr_stat);

    } else if (opt == "-edata") {           // -edata data ?mask --------------
      if (lsize == 0) 
        return args.Quit("-E: -edata not allowed on empty command list");
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
      if (lsize == 0) 
        return args.Quit("-E: -estat not allowed on empty command list");
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

    }

    if (lsize != clist.Size()) {            // cmd added to clist (ind=lsize!)
      if (estatdef_msk != 0xff) {           // estatdef defined
        if (clist[lsize].Expect()==0) {
          clist.LastExpect(new RlinkCommandExpect());
        }
        clist[lsize].Expect()->SetStatus(estatdef_val, estatdef_msk); 
      }
    }
  
  }

  if (!args.AllDone()) return kERR;
  if (clist.Size() == 0) return kOK;

  // signal cpugo up before clist executed to prevent races
  if (setcpugo) Obj().SetCpuGoUp();

  RerrMsg emsg;
  // this one intentionally on Connect() to allow mixing of rlc + w11 commands
  // FIXME_code: is this a good idea ??
  if (!Connect().Exec(clist, emsg)) return args.Quit(emsg);

  for (size_t icmd=0; icmd<clist.Size(); icmd++) {
    RlinkCommand& cmd = clist[icmd];
    
    if (icmd<vardata.size() && !vardata[icmd].empty()) {
      RtclOPtr pres;
      vector<uint16_t> retstat;
      RtclOPtr pele;
      switch (cmd.Command()) {
        case RlinkCommand::kCmdRreg:
          pres = Tcl_NewIntObj((int)cmd.Data());
          break;

        case RlinkCommand::kCmdRblk:
          pres = Rtcl::NewListIntObj(cmd.Block());
          break;
      }
      if(!Rtcl::SetVar(interp, vardata[icmd], pres)) return kERR;
    }

    if (icmd<varstat.size() && !varstat[icmd].empty()) {
      RtclOPtr pres = Tcl_NewIntObj((int)cmd.Status());
      if (!Rtcl::SetVar(interp, varstat[icmd], pres)) return kERR;
    }
  }

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cpu::M_wtcpu(RtclArgs& args)
{
  static RtclNameSet optset("-reset");

  string opt;
  bool reset = false;
  double tout;

  while (args.NextOpt(opt, optset)) {
    if (opt == "-reset") reset = true;
  }
  if (!args.GetArg("tout", tout, 0.001)) return kERR;
  if (!args.AllDone()) return kERR;

  double twait = -1;

  if (!Server().IsActive()) {               // server is not active
    RerrMsg emsg;
    twait = Connect().WaitAttn(tout, emsg);
    if (twait == -2.) {                     // wait failed, quit
      return args.Quit(emsg);
    }
    if (twait >= 0.) {                      // wait succeeded
      RlinkCommandList clist;                 // get and discard attn pattern 
      clist.AddAttn();
      if (!Connect().Exec(clist, emsg)) return args.Quit(emsg);
    }

  } else {                                  // server is active
    twait = Obj().WaitCpuGoDown(tout);
  } 

  if (twait < 0.) {                         // timeout
    if (Connect().GetLogOpts().printlevel >= 1) {
      RlogMsg lmsg(Connect().LogFile());
      lmsg << "-- wtcpu to=" << RosPrintf(tout, "f", 0,3) << " FAIL timeout";
    }
    Connect().Context().IncErrorCount();
    if (reset) {                            // reset requested 
      uint16_t base = Obj().Base();
      RlinkCommandList clist;
      clist.AddWreg(base + Rw11Cpu::kCp_addr_cntl, Rw11Cpu::kCp_func_stop);
      RerrMsg emsg;
      if (!Connect().Exec(clist, emsg)) return args.Quit(emsg);
    }
  } else {                                  // no timeout
    if (Connect().GetLogOpts().printlevel >= 3) {
      RlogMsg lmsg(Connect().LogFile());
      lmsg << "-- wtcpu to=" << RosPrintf(tout, "f", 0,3)
           << "  T=" << RosPrintf(twait, "f", 0,3)
           << "  OK";
    }
  }
  
  args.SetResult(twait);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cpu::M_deposit(RtclArgs& args)
{
  uint16_t  addr;
  vector<uint16_t> data;
  if (!args.GetArg("addr", addr)) return kERR;
  if (!args.GetArg("data", data, 1)) return kERR;
  if (!args.AllDone()) return kERR;

  RerrMsg emsg;
  // FIXME_code: handle memory read/write error
  if (!Obj().MemWrite(addr, data, emsg)) return args.Quit(emsg);

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cpu::M_examine(RtclArgs& args)
{
  uint16_t  addr;
  if (!args.GetArg("addr", addr)) return kERR;
  if (!args.AllDone()) return kERR;

  RerrMsg emsg;
  vector<uint16_t> data;
  // FIXME_code: handle memory read/write error
  if (!Obj().MemRead(addr, data, 1, emsg)) return args.Quit(emsg);

  args.SetResult(Rtcl::NewListIntObj(data));

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cpu::M_lsmem(RtclArgs& args)
{
  uint16_t  abeg;
  if (!args.GetArg("abeg", abeg)) return kERR;
  uint16_t  aend = abeg;
  if (!args.GetArg("?aend", aend, 0xffff, abeg)) return kERR;
  if (!args.AllDone()) return kERR;

  RerrMsg emsg;
  vector<uint16_t> data;
  size_t nword = 1+(aend-abeg)/2;
  // FIXME_code: handle memory read/write error
  if (!Obj().MemRead(abeg, data, nword, emsg)) return args.Quit(emsg);

  ostringstream sos;
  for (size_t i=0; i<nword; i++) {
    sos << RosPrintBvi(uint16_t(abeg+i*2), 8) 
        << " : " <<  RosPrintBvi(data[i], 8) << endl;
  }
  
  args.SetResult(sos);

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cpu::M_ldabs(RtclArgs& args)
{
  string file;
  if (!args.GetArg("file", file)) return kERR;
  if (!args.AllDone()) return kERR;
  RerrMsg emsg;
  // FIXME_code: handle memory read/write error
  if (!Obj().LoadAbs(file, emsg, true)) return args.Quit(emsg);
  return kOK;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cpu::M_ldasm(RtclArgs& args)
{
  static RtclNameSet optset("-lst|-sym|-opt|-file");
  Tcl_Interp* interp = args.Interp();

  string varlst;
  string varsym;
  string asmopt;
  string file;
  string code;

  string opt;
  while (args.NextOpt(opt, optset)) {
    if (opt == "-lst") {
      if (!args.GetArg("??varLst", varlst)) return kERR;
    } else if (opt == "-sym") {
      if (!args.GetArg("??varSym", varsym)) return kERR;
    } else if (opt == "-opt") {
      // don't use ?? because the argument will look like an option...
      if (!args.GetArg("opts", asmopt)) return kERR;
    } else if (opt == "-file") {
      if (!args.GetArg("??file", file)) return kERR;
    }
  }

  if (file.length() == 0) {
    if (!args.GetArg("code", code)) return kERR;
  }
  if (!args.AllDone()) return kERR;

  // delete sym array, otherwise old entries are preserved
  if (varsym.length()) 
    Tcl_UnsetVar(interp, varsym.c_str(), 0);

  int pipe_tcl2asm[2];                      // [0] read, [1] write end
  int pipe_asm2tcl[2];
  
  if (::pipe(pipe_tcl2asm) < 0) 
    return args.Quit(RerrMsg("RtclRw11Cpu::M_ldasm" , 
                             "1st pipe() failed: ", errno));
  if (::pipe(pipe_asm2tcl) < 0) 
    return args.Quit(RerrMsg("RtclRw11Cpu::M_ldasm" , 
                             "2nd pipe() failed: ", errno));

  pid_t pid = ::fork();
  if (pid == (pid_t) 0) {                   // in child here
    vector<const char*> argv;
    vector<string>      opts;

    argv.push_back("asm-11");
    if (varlst.length()>0) argv.push_back("--olst=-");
    argv.push_back("--ocof=-");
    if (asmopt.length()) {
      istringstream optstream(asmopt);
      string tok;
      while (optstream >> tok) {
        opts.push_back(tok);
        argv.push_back(opts[opts.size()-1].c_str());
      }
    }
    if (file.length()) {
      argv.push_back(file.c_str());
    } else {
      argv.push_back("-");
    }
    argv.push_back(NULL);
    
    ::dup2(pipe_tcl2asm[0], STDIN_FILENO);
    ::dup2(pipe_asm2tcl[1], STDOUT_FILENO);
    ::dup2(STDOUT_FILENO, STDERR_FILENO);
    ::close(pipe_tcl2asm[1]);
    ::close(pipe_asm2tcl[0]);
    ::execvp("asm-11", (char* const*) argv.data());
    ::perror("execvp() for asm-11 failed");
    ::exit(EXIT_FAILURE);
    
  } else {                                  // in parent here
    ::close(pipe_tcl2asm[0]);
    ::close(pipe_asm2tcl[1]);
    if (pid < (pid_t) 0) 
      return args.Quit(RerrMsg("RtclRw11Cpu::M_ldasm" , 
                               "fork() failed: ", errno));
  }

  // if first line empty, drop it (created often by using {)
  if (code.length() && code[0] == '\n') code = code.substr(1);

  istringstream ostream(code);
  string oline;
  while (std::getline(ostream, oline)) {
    oline += '\n';
    //cout << "+++1:" << oline;
    if (::write(pipe_tcl2asm[1], oline.data(), oline.length()) < 0) break;
  }
  ::close(pipe_tcl2asm[1]);
  
  FILE* fp = ::fdopen(pipe_asm2tcl[0], "r");
  if (fp == NULL) {
    ::close(pipe_asm2tcl[0]);
    return args.Quit(RerrMsg("RtclRw11Cpu::M_ldasm" , 
                             "fdopen() failed: ", errno));
  }

  vector<string> ilines;
  while(true) {
    char* pline = NULL;
    size_t nchar;
    if (::getline(&pline, &nchar, fp) < 0) break;
    //cout << "+++2:" << pline;
    string line(pline);
    if (line.length() && line[line.length()-1] =='\n')
      line.resize(line.length()-1);
    ilines.push_back(line);
    ::free(pline);
  }
  ::fclose(fp);
  ::close(pipe_asm2tcl[0]);

  int wstat;
  int wexit = -1;
  waitpid(pid, &wstat, 0);
  if (WIFEXITED(wstat)) wexit = WEXITSTATUS(wstat);

  bool insym = false;
  bool indat = false;
  char dtyp = ' ';
  
  ostringstream los;                        // list stream
  ostringstream eos;                        // error stream
  bool lstbodyseen = false;

  typedef map<uint16_t, uint16_t>  cmap_t;
  typedef cmap_t::iterator         cmap_it_t;
  typedef cmap_t::value_type       cmap_val_t;

  cmap_t   cmap;
  uint16_t dot = 0;

  for (size_t i=0; i<ilines.size(); i++) {
    string& line = ilines[i];
    if (line == "sym {") {
      insym = true;
      continue;
    } else if (line == "dat {") {
      indat = true;
      continue;
    } else if (dtyp == ' ' && line == "}") {
      insym = false;
      indat = false;
      continue;
    }

    // handle symbol table
    if (insym) {
      if (varsym.length() == 0) continue;
      size_t dpos = line.find(" => ");
      if (dpos != std::string::npos) {
        string key = line.substr(0,dpos);
        string val= line.substr(dpos+4);
        if (!Tcl_SetVar2Ex(interp, varsym.c_str(), key.c_str(),
                           Tcl_NewIntObj((int)strtol(val.c_str(),NULL,8)),
                           TCL_LEAVE_ERR_MSG)) return kERR;
      } else {
        return args.Quit(string("bad sym spec: ") + line);
      }

    // handle data part
    } else if (indat) {
      if (dtyp == ' ') {
        if (line.length() != 10) 
          return args.Quit(string("bad dat spec: ") + line);
        dtyp = line[0];
        dot  = (uint16_t)strtol(line.c_str()+2,NULL,8);
      } else if (line[0] == '}') {
        dtyp = ' ';
      } else {
        istringstream datstream(line);
        string dat;
        while (datstream >> dat) {
          //cout << "+++1 " << dtyp << ":" << dat << endl;
          uint16_t val = (uint16_t)strtol(dat.c_str(),NULL,8);
          if (dtyp == 'w') {
            cmap[dot] = val;
            dot += 2;
          } else {
            uint16_t tmp = cmap[dot&0xfffe];
            if (dot & 01) {
              tmp = (val&0xff)<<8 | (tmp&0xff); // odd (high) byte
            } else {
              tmp = (tmp&0xff00)  | (val&0xff); // even (low) byte
            }
            cmap[dot&0xfffe] = tmp;
            dot += 1;
          }
        }
      }

    // handle listing part (everything not sym{} or dat{}
    } else {
      los << line << endl;
      // put lines into error stream if
      //  1. before 'Input file list:' and not starting with '--'
      //  2. after  'Input file list:' and starting with uppercase letter
      if (line == "; Input file list:") lstbodyseen = true;
      bool etake = false;
      if (lstbodyseen) {
        if (line.length() && (line[0]>'A' && line[0]<'Z')) etake = true;
      } else {
        if (line.substr(0,2) != "--") etake = true;
      }
      if (line.substr(0,6) == "asm-11") etake = true;
      if (etake) eos << line << endl;
    }
  }

  if (varlst.length()) {
    if (!Rtcl::SetVar(interp, varlst, Rtcl::NewLinesObj(los))) return kERR;
  }

  // now, finally, iterate of cmap and write code to memory

  vector<uint16_t> block;
  uint16_t base = 0;
  dot = 0;
  RerrMsg emsg;
  
  for (cmap_it_t it=cmap.begin(); it!=cmap.end(); it++) {
    //cout << "+++2 mem[" << RosPrintf(it->first, "o0", 6)
    //     << "]=" << RosPrintf(it->second, "o0", 6) << endl;
    if (dot != it->first || block.size() == 256) {
      if (block.size()) {
        if (!Obj().MemWrite(base, block, emsg)) return args.Quit(emsg);
        block.clear();
      }
      base = dot = it->first;
    }
    block.push_back(it->second);
    dot += 2;
  }

  if (block.size()) {
    if (!Obj().MemWrite(base, block, emsg)) return args.Quit(emsg);
    block.clear();
  }

  if (wexit != 0) {
    args.AppendResultLines("asm-11 compilation failed with:");
    args.AppendResultLines(eos);
    return kERR;
  }

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cpu::M_boot(RtclArgs& args)
{
  string uname;
  if (!args.GetArg("uname", uname)) return kERR;
  if (!args.AllDone()) return kERR;
  RerrMsg emsg;
  if (!Obj().Boot(uname, emsg)) return args.Quit(emsg);
  return kOK;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cpu::M_get(RtclArgs& args)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Obj().Connect());
  return fGets.M_get(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cpu::M_set(RtclArgs& args)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Obj().Connect());
  return fSets.M_set(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cpu::M_stats(RtclArgs& args)
{
  RtclStats::Context cntx;
  if (!RtclStats::GetArgs(args, cntx)) return kERR;
  if (!RtclStats::Collect(args, cntx, Obj().Stats())) return kERR;
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cpu::M_dump(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;

  ostringstream sos;
  Obj().Dump(sos, 0);
  args.SetResult(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cpu::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  ostringstream sos;

  vector<string> cntlnames;
  Obj().ListCntl(cntlnames);

  sos << "name type ibbase lam" << endl;

  for (size_t i=0; i<cntlnames.size(); i++) {
    Rw11Cntl& cntl(Obj().Cntl(cntlnames[i]));
    sos << RosPrintf(cntl.Name().c_str(),"-s",4)
        << " " << RosPrintf(cntl.Type().c_str(),"-s",4)
        << " " << RosPrintf(cntl.Base(),"o",6)
        << " " << RosPrintf(cntl.Lam(),"d",3)
        << endl;
  }

  args.AppendResultLines(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclRw11Cpu::SetupGetSet()
{
  Rw11Cpu* pobj = &Obj();
  fGets.Add<const string&>("type",  boost::bind(&Rw11Cpu::Type, pobj));
  fGets.Add<size_t>       ("index", boost::bind(&Rw11Cpu::Index, pobj));
  fGets.Add<uint16_t>     ("base",  boost::bind(&Rw11Cpu::Base, pobj));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclRw11Cpu::GetVarName(RtclArgs& args, const char* argname, 
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
                        "': looks like a number", NULL);
      return false;
    }
  }
  
  varname[nind] = name;
  return true;
}

} // end namespace Retro
