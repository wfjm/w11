// $Id: RtclRw11Virt.cpp 1082 2018-12-15 13:56:20Z mueller $
//
// Copyright 2017-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-15  1082   1.0.2  use lambda instead of bind
// 2017-04-07   868   1.0.1  M_dump: use GetArgsDump and Dump detail
// 2017-03-11   859   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11Virt.
*/

#include "librtcltools/RtclStats.hpp"

#include "RtclRw11Virt.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11Virt
  \brief FIXME_docs
*/


// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11Virt::RtclRw11Virt(Rw11Virt* pvirt)
  : RtclCmdBase(),
    fpVirt(pvirt),
    fGets(),
    fSets()
{
  AddMeth("get",    [this](RtclArgs& args){ return M_get(args); });
  AddMeth("set",    [this](RtclArgs& args){ return M_set(args); });
  AddMeth("stats",  [this](RtclArgs& args){ return M_stats(args); });
  AddMeth("dump",   [this](RtclArgs& args){ return M_dump(args); });
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclRw11Virt::~RtclRw11Virt()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Virt::M_get(RtclArgs& args)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Virt()->Cpu().Connect());
  return fGets.M_get(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Virt::M_set(RtclArgs& args)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Virt()->Cpu().Connect());
  return fSets.M_set(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Virt::M_stats(RtclArgs& args)
{
  RtclStats::Context cntx;
  if (!RtclStats::GetArgs(args, cntx)) return kERR;
  if (!RtclStats::Collect(args, cntx, Virt()->Stats())) return kERR;
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Virt::M_dump(RtclArgs& args)
{
  int detail=0;
  if (!GetArgsDump(args, detail)) return kERR;
  if (!args.AllDone()) return kERR;

  std::ostringstream sos;
  Virt()->Dump(sos, 0, "", detail);
  args.SetResult(sos);
  return kOK;
}

} // end namespace Retro
