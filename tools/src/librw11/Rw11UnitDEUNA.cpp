// $Id: Rw11UnitDEUNA.cpp 1080 2018-12-09 20:30:33Z mueller $
//
// Copyright 2014-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-09  1080   1.0.2  use HasVirt(); Virt() returns ref
// 2018-12-01  1076   1.0.1  use unique_ptr
// 2017-01-29   847   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of Rw11UnitDEUNA.
*/

#include "boost/bind.hpp"

#include "librtools/RosFill.hpp"
#include "Rw11CntlDEUNA.hpp"

#include "Rw11UnitDEUNA.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitDEUNA
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitDEUNA::Rw11UnitDEUNA(Rw11CntlDEUNA* pcntl, size_t index)
  : Rw11UnitVirt<Rw11VirtEth>(pcntl, index),
    fpCntl(pcntl)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitDEUNA::~Rw11UnitDEUNA()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitDEUNA::Dump(std::ostream& os, int ind, const char* text,
                         int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitDEUNA @ " << this << endl;
  os << bl << "  fpCntl:          " << fpCntl   << std::endl;
  Rw11UnitVirt<Rw11VirtEth>::Dump(os, ind, " ^", detail);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitDEUNA::AttachDone()
{
  Virt().SetupRcvCallback(boost::bind(&Rw11CntlDEUNA::RcvCallback,
                                       &Cntl(), _1));
  Cntl().UnitSetup(0);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitDEUNA::DetachDone()
{
  Cntl().UnitSetup(0);
  return;
}

} // end namespace Retro
