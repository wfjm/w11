// $Id: RtclRw11VirtDiskRam.cpp 1087 2018-12-17 08:25:37Z mueller $
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
// 2018-12-17  1087   1.0.2  use std::lock_guard instead of boost
// 2018-12-15  1082   1.0.1  use lambda instead of bind
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
  AddMeth("list", [this](RtclArgs& args){ return M_list(args); });
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
  lock_guard<RlinkConnect> lock(Obj().Cpu().Connect());
  Obj().List(sos);
  args.SetResult(sos);
  return kOK;
}

} // end namespace Retro
