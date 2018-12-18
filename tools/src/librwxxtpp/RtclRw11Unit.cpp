// $Id: RtclRw11Unit.cpp 1085 2018-12-16 14:11:16Z mueller $
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
// 2018-12-17  1085   1.3.2  use std::lock_guard instead of boost
// 2018-12-15  1082   1.3.1  use lambda instead of bind
// 2018-12-01  1076   1.3    use unique_ptr instead of scoped_ptr
// 2017-04-08   870   1.2    drop fpCpu, use added Cpu()=0 instead
// 2017-04-07   868   1.1.1  M_dump: use GetArgsDump and Dump detail
// 2017-04-02   863   1.1    add fpVirt; add DetachCleanup()
// 2013-03-03   494   1.0    Initial version
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11Unit.
*/

#include "librtools/Rexception.hpp"
#include "librtcltools/RtclStats.hpp"

#include "RtclRw11Unit.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11Unit
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RtclRw11Unit::RtclRw11Unit(const std::string& type)
  : RtclProxyBase(type),
    fGets(),
    fSets(),
    fupVirt()
{
  AddMeth("get",      [this](RtclArgs& args){ return M_get(args); });
  AddMeth("set",      [this](RtclArgs& args){ return M_set(args); });
  AddMeth("attach",   [this](RtclArgs& args){ return M_attach(args); });
  AddMeth("detach",   [this](RtclArgs& args){ return M_detach(args); });
  AddMeth("dump",     [this](RtclArgs& args){ return M_dump(args); });
  AddMeth("$default", [this](RtclArgs& args){ return M_default(args); });
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11Unit::~RtclRw11Unit()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclRw11Unit::DetachCleanup()
{
  if (!fupVirt) return;
  DelMeth("virt");
  fupVirt.reset();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_get(RtclArgs& args)
{
  // synchronize with server thread
  lock_guard<RlinkConnect> lock(Cpu().Connect());
  return fGets.M_get(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_set(RtclArgs& args)
{
  // synchronize with server thread
  lock_guard<RlinkConnect> lock(Cpu().Connect());
  return fSets.M_set(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_attach(RtclArgs& args)
{
  string url;
  if (!args.GetArg("url", url)) return kERR;

  if (!args.AllDone()) return kERR;

  RerrMsg emsg;
  // synchronize with server thread
  lock_guard<RlinkConnect> lock(Cpu().Connect());

  DetachCleanup();
  if (!Obj().Attach(url, emsg)) return args.Quit(emsg);
  AttachDone();
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_detach(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;

  // synchronize with server thread
  lock_guard<RlinkConnect> lock(Cpu().Connect());
  Obj().Detach();
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_virt(RtclArgs& args)
{
  if (!fupVirt) throw Rexception("RtclRw11Unit::M_virt:",
                                 "Bad state: fupVirt == nullptr");
  
  // synchronize with server thread
  lock_guard<RlinkConnect> lock(Cpu().Connect());
  return fupVirt->DispatchCmd(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_dump(RtclArgs& args)
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

int RtclRw11Unit::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  ostringstream sos;
  sos << "no default output defined yet...\n";
  args.AppendResultLines(sos);
  return kOK;
}

} // end namespace Retro
