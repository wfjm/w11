// $Id: RtclRw11VirtDiskRam.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2018-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-02-23  1114   1.0.3  use std::bind instead of lambda
// 2018-12-17  1087   1.0.2  use std::lock_guard instead of boost
// 2018-12-15  1082   1.0.1  use lambda instead of boost::bind
// 2018-10-28  1063   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclRw11VirtDiskRam.
*/

#include <functional>

#include "RtclRw11VirtDiskRam.hpp"

using namespace std;
using namespace std::placeholders;

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
  AddMeth("list", bind(&RtclRw11VirtDiskRam::M_list,   this, _1));
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
