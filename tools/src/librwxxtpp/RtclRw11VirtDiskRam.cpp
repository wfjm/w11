// $Id: RtclRw11VirtDiskRam.cpp 1063 2018-10-29 18:37:42Z mueller $
//
// Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-10-28  1063   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11VirtDiskRam.
*/

#include "RtclRw11VirtDiskRam.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11VirtDiskRam
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11VirtDiskRam::RtclRw11VirtDiskRam(Rw11VirtDiskRam* pobj)
  : RtclRw11VirtBase<Rw11VirtDiskRam>(pobj)
{
  AddMeth("list",  boost::bind(&RtclRw11VirtDiskRam::M_list,   this, _1));
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11VirtDiskRam::~RtclRw11VirtDiskRam()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11VirtDiskRam::M_list(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  ostringstream sos;

  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Obj().Cpu().Connect());
  Obj().List(sos);
  args.SetResult(sos);
  return kOK;
}

} // end namespace Retro
