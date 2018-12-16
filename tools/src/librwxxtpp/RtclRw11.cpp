// $Id: RtclRw11.cpp 1082 2018-12-15 13:56:20Z mueller $
//
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-15  1082   1.0.5  use lambda instead of bind
// 2017-04-16   876   1.0.4  add CpuCommands()
// 2017-04-07   868   1.0.3  M_dump: use GetArgsDump and Dump detail
// 2017-04-02   866   1.0.2  add M_set; handle default disk scheme
// 2015-03-28   660   1.0.1  add M_get
// 2014-12-25   621   1.1    adopt to 4k word ibus window
// 2013-03-06   495   1.0    Initial version
// 2013-01-27   478   0.1    First Draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of class RtclRw11.
 */

#include <ctype.h>

#include <iostream>
#include <string>

#include "librtools/RosPrintf.hpp"
#include "librtcltools/RtclContext.hpp"
#include "librlinktpp/RtclRlinkServer.hpp"
#include "RtclRw11CpuW11a.hpp"
#include "librw11/Rw11Cpu.hpp"
#include "librw11/Rw11Cntl.hpp"
#include "librw11/Rw11VirtDisk.hpp"

#include "RtclRw11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11::RtclRw11(Tcl_Interp* interp, const char* name)
  : RtclProxyOwned<Rw11>("Rw11", interp, name, new Rw11()),
    fspServ(),
    fGets(),
    fSets()
{
  AddMeth("get",      [this](RtclArgs& args){ return M_get(args); });
  AddMeth("set",      [this](RtclArgs& args){ return M_set(args); });
  AddMeth("start",    [this](RtclArgs& args){ return M_start(args); });
  AddMeth("dump",     [this](RtclArgs& args){ return M_dump(args); });
  AddMeth("$default", [this](RtclArgs& args){ return M_default(args); });

  Rw11* pobj = &Obj();
  fGets.Add<bool>          ("started", [pobj](){ return pobj->IsStarted(); });
  fGets.Add<const string&> ("diskscheme",
                            [](){ return Rw11VirtDisk::DefaultScheme(); });  
  fGets.Add<Tcl_Obj*>      ("cpus", [this](){ return CpuCommands(); });

  fSets.Add<const string&> ("diskscheme",  
                            [](const string& v)
                              { Rw11VirtDisk::SetDefaultScheme(v);} );
  
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11::~RtclRw11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11::ClassCmdConfig(RtclArgs& args)
{
  string parent;
  if (!args.GetArg("parent", parent)) return kERR;

  // locate RlinkServer proxy and object -> setup W11->Server linkage
  RtclProxyBase* pprox = RtclContext::Find(args.Interp()).FindProxy(
                           "RlinkServer", parent);

  if (pprox == nullptr) 
    return args.Quit(string("-E: object '") + parent +
                     "' not found or not type RlinkServer");

  // make RtclRlinkRw11 object be co-owner of RlinkServer object
  fspServ = dynamic_cast<RtclRlinkServer*>(pprox)->ObjSPtr();
  
  // set RlinkServer in Rw11 (make Rw11 also co-owner)
  Obj().SetServer(fspServ);

  // now configure cpu's
  string type;
  int    count = 1;
  if (!args.GetArg("type", type)) return kERR;
  if (!args.GetArg("?count", count, 1, 1)) return kERR;
  if (!args.AllDone()) return kERR;

  // 'factory section', create concrete w11Cpu objects
  if (type == "w11a") {                  // w11a --------------------------
    RtclRw11CpuW11a* pobj = new RtclRw11CpuW11a(args.Interp(), "cpu0");
    // configure cpu
    pobj->Obj().Setup(0,0,0x4000);          // ind=0,base=0,ibase=0x4000
    // install in w11
    Obj().AddCpu(dynamic_pointer_cast<Rw11Cpu>(pobj->ObjSPtr()));

  } else {                               // unknown cpu type --------------
    return args.Quit(string("-E: unknown cpu type '") + type + "'");
  }

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11::M_get(RtclArgs& args)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Obj().Connect());
  return fGets.M_get(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11::M_set(RtclArgs& args)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Obj().Connect());
  return fSets.M_set(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11::M_start(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  if (Obj().IsStarted()) return args.Quit("-E: already started");
  Obj().Start();
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11::M_dump(RtclArgs& args)
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

int RtclRw11::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  ostringstream sos;

  sos << "cpu type base : cntl  type  ibbase  probe  lam boot" << endl;

  for (size_t i=0; i<Obj().NCpu(); i++) {
    Rw11Cpu& cpu(Obj().Cpu(i));
    sos << " " << i << " "
        << " " << RosPrintf(cpu.Type().c_str(),"-s",4)
        << " " << RosPrintf(cpu.Base(),"x",4)
        << endl;
    
    vector<string> cntlnames;
    cpu.ListCntl(cntlnames);
    for (auto& cname : cntlnames) {
      Rw11Cntl& cntl(cpu.Cntl(cname));
      const Rw11Probe& pstat(cntl.ProbeStatus());
      sos << "                 " << RosPrintf(cntl.Name().c_str(),"-s",4)
          << " " << RosPrintf(cntl.Type().c_str(),"-s",5)
          << " " << RosPrintf(cntl.Base(),"o0",6)
          << "  ir=" << pstat.IndicatorInt() << "," << pstat.IndicatorRem();
      if (cntl.Lam() > 0) sos << " " << RosPrintf(cntl.Lam(),"d",3);
      else sos << "   -";
      uint16_t aload;
      uint16_t astart;
      vector<uint16_t> code;
      bool bootok = cntl.BootCode(0, code, aload, astart);
      sos << "   " << (bootok ? "y" : "n");
      sos << endl;
    }
  }

  args.AppendResultLines(sos);
  return kOK;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

Tcl_Obj* RtclRw11::CpuCommands()
{
  Tcl_Obj* rlist = Tcl_NewListObj(0,nullptr);
  for (size_t i=0; i<Obj().NCpu(); i++) {
    string ccmd = string("cpu") + to_string(i);
    RtclOPtr pele(Tcl_NewStringObj(ccmd.data(), ccmd.length()));
    Tcl_ListObjAppendElement(nullptr, rlist, pele);
  }
  return rlist;
}


} // end namespace Retro
