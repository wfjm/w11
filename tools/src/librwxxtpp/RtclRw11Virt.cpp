// $Id: RtclRw11Virt.cpp 1114 2019-02-23 18:01:55Z mueller $
//
// Copyright 2017-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-02-23  1114   1.0.4  use std::bind instead of lambda
// 2018-12-17  1087   1.0.3  use std::lock_guard instead of boost
// 2018-12-15  1082   1.0.2  use lambda instead of boost::bind
// 2017-04-07   868   1.0.1  M_dump: use GetArgsDump and Dump detail
// 2017-03-11   859   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11Virt.
*/

#include <functional>

#include "librtcltools/RtclStats.hpp"

#include "RtclRw11Virt.hpp"

using namespace std;
using namespace std::placeholders;

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
  AddMeth("get",    bind(&RtclRw11Virt::M_get,   this, _1));
  AddMeth("set",    bind(&RtclRw11Virt::M_set,   this, _1));
  AddMeth("stats",  bind(&RtclRw11Virt::M_stats, this, _1));
  AddMeth("dump",   bind(&RtclRw11Virt::M_dump,  this, _1));
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
  lock_guard<RlinkConnect> lock(Virt()->Cpu().Connect());
  return fGets.M_get(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Virt::M_set(RtclArgs& args)
{
  // synchronize with server thread
  lock_guard<RlinkConnect> lock(Virt()->Cpu().Connect());
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
