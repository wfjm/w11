// $Id: RtclRw11Cntl.cpp 1085 2018-12-16 14:11:16Z mueller $
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
// 2018-12-17  1085   1.1.4  use std::lock_guard instead of boost
// 2018-12-15  1082   1.1.3  use lambda instead of bind
// 2017-04-16   877   1.1.2  add UnitCommands(); add Class()
// 2017-04-02   865   1.0.2  M_dump: use GetArgsDump and Dump detail
// 2015-03-27   660   1.0.1  add M_start
// 2013-03-06   495   1.0    Initial version
// 2013-02-08   484   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11Cntl.
*/

#include "librtcltools/RtclStats.hpp"
#include "librtcltools/RtclOPtr.hpp"

#include "RtclRw11Cntl.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11Cntl
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11Cntl::RtclRw11Cntl(const std::string& type,
                           const std::string& cclass)
  : RtclProxyBase(type),
    fClass(cclass),
    fGets(),
    fSets()
{
  AddMeth("get",      [this](RtclArgs& args){ return M_get(args); });
  AddMeth("set",      [this](RtclArgs& args){ return M_set(args); });
  AddMeth("probe",    [this](RtclArgs& args){ return M_probe(args); });
  AddMeth("start",    [this](RtclArgs& args){ return M_start(args); });
  AddMeth("stats",    [this](RtclArgs& args){ return M_stats(args); });
  AddMeth("dump",     [this](RtclArgs& args){ return M_dump(args); });
  AddMeth("$default", [this](RtclArgs& args){ return M_default(args); });

  fGets.Add<Tcl_Obj*>      ("units", [this](){ return UnitCommands(); });
  fGets.Add<const string&> ("class", [this](){ return Class(); });
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11Cntl::~RtclRw11Cntl()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cntl::M_get(RtclArgs& args)
{
  // synchronize with server thread
  lock_guard<RlinkConnect> lock(Obj().Connect());
  return fGets.M_get(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cntl::M_set(RtclArgs& args)
{
  // synchronize with server thread
  lock_guard<RlinkConnect> lock(Obj().Connect());
  return fSets.M_set(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cntl::M_probe(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  args.SetResult(Obj().Probe());
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cntl::M_start(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  Obj().Probe();
  Obj().Start();
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cntl::M_stats(RtclArgs& args)
{
  RtclStats::Context cntx;
  if (!RtclStats::GetArgs(args, cntx)) return kERR;
  if (!RtclStats::Collect(args, cntx, Obj().Stats())) return kERR;
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cntl::M_dump(RtclArgs& args)
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

int RtclRw11Cntl::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  ostringstream sos;
  sos << "no default output defined yet...\n";
  args.AppendResultLines(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Tcl_Obj* RtclRw11Cntl::UnitCommands()
{
  Tcl_Obj* rlist = Tcl_NewListObj(0,nullptr);
  for (size_t i = 0; i < Obj().NUnit(); i++) {
    string ucmd = CommandName() + to_string(i);
    RtclOPtr pele(Tcl_NewStringObj(ucmd.data(), ucmd.length()));
    Tcl_ListObjAppendElement(nullptr, rlist, pele);
  }
  return rlist;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

const std::string& RtclRw11Cntl::Class() const
{
  return fClass;
}

} // end namespace Retro
