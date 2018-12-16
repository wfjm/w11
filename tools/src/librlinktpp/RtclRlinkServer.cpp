// $Id: RtclRlinkServer.cpp 1082 2018-12-15 13:56:20Z mueller $
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
// 2018-12-14  1081   1.2.1  use std::bind instead of boost
// 2018-12-01  1076   1.2    use unique_ptr
// 2018-11-16  1070   1.1.2  use auto; use range loop
// 2017-04-02   865   1.1.1  M_dump: use GetArgsDump and Dump detail
// 2015-04-04   662   1.1    add M_get, M_set; remove 'server -trace'
// 2014-08-22   584   1.0.6  use nullptr
// 2013-05-01   513   1.0.5  TraceLevel now uint32_t
// 2013-04-26   510   1.0.4  change M_attn, now -info instead of -show
// 2013-04-21   509   1.0.3  add server -resume
// 2013-02-05   483   1.0.2  ClassCmdConfig: use RtclArgs
// 2013-02-05   482   1.0.1  add shared_ptr to RlinkConnect object
// 2013-01-12   474   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of class RtclRlinkServer.
 */

#include <ctype.h>

#include <stdexcept>
#include <iostream>
#include <vector>
#include <string>
#include <memory>

#include "librtools/RosPrintBvi.hpp"
#include "librtcltools/Rtcl.hpp"
#include "librtcltools/RtclOPtr.hpp"
#include "librtcltools/RtclStats.hpp"
#include "librtcltools/RtclContext.hpp"
#include "RtclRlinkConnect.hpp"

#include "RtclRlinkServer.hpp"

using namespace std;

/*!
  \class Retro::RtclRlinkServer
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RtclRlinkServer::RtclRlinkServer(Tcl_Interp* interp, const char* name)
  : RtclProxyOwned<RlinkServer>("RlinkServer", interp, name, 
                                new RlinkServer()),
    fspConn(),
    fGets(),
    fSets()
{
  AddMeth("server",   [this](RtclArgs& args){ return M_server(args); });
  AddMeth("attn",     [this](RtclArgs& args){ return M_attn(args); });
  AddMeth("stats",    [this](RtclArgs& args){ return M_stats(args); });
  AddMeth("print",    [this](RtclArgs& args){ return M_print(args); });
  AddMeth("dump",     [this](RtclArgs& args){ return M_dump(args); });
  AddMeth("get",      [this](RtclArgs& args){ return M_get(args); });
  AddMeth("set",      [this](RtclArgs& args){ return M_set(args); });
  AddMeth("$default", [this](RtclArgs& args){ return M_default(args); });

  // attributes of RlinkConnect
  RlinkServer* pobj  = &Obj();
  fGets.Add<uint32_t>  ("tracelevel", [pobj](){ return pobj->TraceLevel(); });

  fSets.Add<uint32_t>  ("tracelevel", 
                        [pobj](uint32_t v){ pobj->SetTraceLevel(v); });

  // attributes of buildin RlinkContext
  RlinkContext* pcntx = &Obj().Context();
  fGets.Add<bool>      ("statchecked",
                        [pcntx](){ return pcntx->StatusIsChecked(); });
  fGets.Add<uint8_t>   ("statvalue",
                        [pcntx](){ return pcntx->StatusValue(); });
  fGets.Add<uint8_t>   ("statmask",
                        [pcntx](){ return pcntx->StatusMask(); });

  fSets.Add<uint8_t>   ("statvalue", 
                        [pcntx](uint8_t v){ pcntx->SetStatusValue(v); });
  fSets.Add<uint8_t>   ("statmask", 
                        [pcntx](uint8_t v){ pcntx->SetStatusMask(v); });
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRlinkServer::~RtclRlinkServer()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkServer::ClassCmdConfig(RtclArgs& args)
{
  string parent;
  if (!args.GetArg("parent", parent)) return kERR;

  // locate RlinkConnect proxy and object -> setup Server->Connect linkage
  RtclProxyBase* pprox = RtclContext::Find(args.Interp()).FindProxy(
                            "RlinkConnect", parent);
  if (pprox == nullptr) 
    return args.Quit(string("-E: object '") + parent + 
                     "' not found or not type RlinkConnect");

  // make RtclRlinkServer object be co-owner of RlinkConnect object
  fspConn = dynamic_cast<RtclRlinkConnect*>(pprox)->ObjSPtr();
  // set RlinkConnect in RlinkServer (make RlinkServer also co-owner)
  Obj().SetConnect(fspConn);

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkServer::M_server(RtclArgs& args)
{
  static RtclNameSet optset("-start|-stop|-resume|-test");
  string opt;
  if (args.NextOpt(opt, optset)) {
    if        (opt == "-start") {           // server -start
      if (!args.AllDone()) return kERR;
      Obj().Start();
    } else if (opt == "-stop") {            // server -stop
      if (!args.AllDone()) return kERR;
      Obj().Stop();
    } else if (opt == "-resume") {          // server -resume
      if (!args.AllDone()) return kERR;
      Obj().Resume();
    } else if (opt == "-test") {            // server -test
      if (!args.AllDone()) return kERR;
      args.SetResult(Obj().IsActive());
    }
    
  } else {                                  // server
    if (!args.OptValid()) return kERR;
    if (!args.AllDone()) return kERR;
    args.SetResult(Obj().IsActive());
  }

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkServer::M_attn(RtclArgs& args)
{
  static RtclNameSet optset("-add|-remove|-info|-test|-list");

  Tcl_Interp* interp = args.Interp();

  string opt;

  if (args.NextOpt(opt, optset)) {
    if        (opt == "-add") {             // attn -add mask script
      uint16_t mask=0;
      Tcl_Obj* script=0;
      if (!args.GetArg("mask", mask,0xff,1)) return kERR;
      if (!args.GetArg("script", script)) return kERR;
      if (!args.AllDone()) return kERR;

      ahdl_uptr_t up(new RtclAttnShuttle(mask, script));
      try {
        up->Add(&Obj(), interp);
      } catch (exception& e) {
        return args.Quit(string("-E: handler rejected: ")+e.what());
      }
      fAttnHdl.push_back(move(up));
      return kOK;

    } else if (opt == "-remove") {            // attn -remove mask
      uint16_t mask=0;
      if (!args.GetArg("mask", mask)) return kERR;
      if (!args.AllDone()) return kERR;
      if (!fAttnHdl.empty()) {
        for (auto it = fAttnHdl.end(); it != fAttnHdl.begin(); ) {
          it--;
          if ((*it)->Mask() == mask) {
            fAttnHdl.erase(it);
            return kOK;
          }
        }
      }
      return args.Quit(string("-E: no handler defined for '") +
                       args.PeekArgString(-1) + "'");

    } else if (opt == "-info") {            // attn -info mask
      uint16_t mask=0;
      if (!args.GetArg("mask", mask)) return kERR;
      if (!args.AllDone()) return kERR;
      RtclOPtr pres(Tcl_NewListObj(0,nullptr));
      for (auto& po : fAttnHdl) {
        if (po->Mask() & mask) {
          RtclOPtr pele(Tcl_NewListObj(0,nullptr));
          Tcl_ListObjAppendElement(nullptr, pele, 
                                   Tcl_NewIntObj(po->Mask()) );
          Tcl_ListObjAppendElement(nullptr, pele, po->Script() );
          Tcl_ListObjAppendElement(nullptr, pres, pele);
        }
      }
      args.SetResult(pres);
      return kOK;

    } else if (opt == "-test") {            // attn -test mask
      uint16_t mask=0;
      if (!args.GetArg("mask", mask)) return kERR;
      if (!args.AllDone()) return kERR;
      int nhdl = 0;
      for (auto& po: fAttnHdl) {
        if (po->Mask() & mask) {
          nhdl += 1;
          int rc = Tcl_EvalObjEx(interp, po->Script(), TCL_EVAL_GLOBAL);
          if (rc != kOK) return rc;
        }
      }
      if (nhdl) return kOK;
      return args.Quit(string("-E: no handler defined for '") +
                       args.PeekArgString(-1) + "'");

    } else if (opt == "-list") {            // attn -list
      if (!args.AllDone()) return kERR;
      vector<uint16_t> vres;
      for (auto& po : fAttnHdl) {
        vres.push_back(po->Mask());
      }
      args.SetResult(Rtcl::NewListIntObj(vres));
    }
    
  } else {                                  // attn
    if (!args.OptValid()) return kERR;
    if (!args.AllDone()) return kERR;
    uint16_t mask=0;
    for (auto& po: fAttnHdl) {
      mask |= po->Mask();
    }
    args.SetResult(mask);
  }

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkServer::M_stats(RtclArgs& args)
{
  RtclStats::Context cntx;
  if (!RtclStats::GetArgs(args, cntx)) return kERR;
  if (!RtclStats::Collect(args, cntx, Obj().Stats())) return kERR;
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkServer::M_print(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;

  ostringstream sos;
  Obj().Print(sos);
  args.SetResult(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkServer::M_dump(RtclArgs& args)
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

int RtclRlinkServer::M_get(RtclArgs& args)
{
  // synchronize with server thread (really needed ??)
  boost::lock_guard<RlinkConnect> lock(Obj().Connect());
  return fGets.M_get(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkServer::M_set(RtclArgs& args)
{
  // synchronize with server thread (really needed ??)
  boost::lock_guard<RlinkConnect> lock(Obj().Connect());
  return fSets.M_set(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkServer::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  ostringstream sos;
  sos << "no default output defined yet...\n";
  args.AppendResultLines(sos);
  return kOK;
}

} // end namespace Retro
