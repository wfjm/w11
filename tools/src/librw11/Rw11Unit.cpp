// $Id: Rw11Unit.cpp 495 2013-03-06 17:13:48Z mueller $
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
// 2013-03-06   495   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11Unit.cpp 495 2013-03-06 17:13:48Z mueller $
  \brief   Implemenation of Rw11Unit.
*/

#include "librtools/RosFill.hpp"

#include "Rw11Unit.hpp"

using namespace std;

/*!
  \class Retro::Rw11Unit
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11Unit::Rw11Unit(Rw11Cntl* pcntl, size_t index)
  : fpCntlBase(pcntl),
    fIndex(index),
    fStats()
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11Unit::~Rw11Unit()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11Unit::Attach(const std::string& url, RerrMsg& emsg)
{
  emsg.Init("Rw11Unit::Attach","attach not available for this device type");
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Unit::Detach()
{
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Unit::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11Unit @ " << this << endl;

  os << bl << "  fIndex:          " << fIndex << endl;
  fStats.Dump(os, ind+2, "fStats: ");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Unit::AttachSetup()
{}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Unit::DetachCleanup()
{}

} // end namespace Retro
