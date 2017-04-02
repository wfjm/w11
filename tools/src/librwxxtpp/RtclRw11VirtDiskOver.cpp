// $Id: RtclRw11VirtDiskOver.cpp 859 2017-03-11 22:36:45Z mueller $
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
// 2017-03-11   859   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11VirtDiskOver.cpp 859 2017-03-11 22:36:45Z mueller $
  \brief   Implemenation of RtclRw11VirtDiskOver.
*/

#include "RtclRw11VirtDiskOver.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11VirtDiskOver
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11VirtDiskOver::RtclRw11VirtDiskOver(Rw11VirtDiskOver* pobj)
  : RtclRw11VirtBase<Rw11VirtDiskOver>(pobj)
{
  AddMeth("flush", boost::bind(&RtclRw11VirtDiskOver::M_flush,  this, _1));
  AddMeth("list",  boost::bind(&RtclRw11VirtDiskOver::M_list,   this, _1));
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11VirtDiskOver::~RtclRw11VirtDiskOver()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11VirtDiskOver::M_flush(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;

  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Obj().Cpu().Connect());
  RerrMsg emsg;
  if (!Obj().Flush(emsg)) return args.Quit(emsg);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11VirtDiskOver::M_list(RtclArgs& args)
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
