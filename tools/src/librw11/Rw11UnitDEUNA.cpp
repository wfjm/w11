// $Id: Rw11UnitDEUNA.cpp 868 2017-04-07 20:09:33Z mueller $
//
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-01-29   847   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitDEUNA.cpp 868 2017-04-07 20:09:33Z mueller $
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
  fpVirt->SetupRcvCallback(boost::bind(&Rw11CntlDEUNA::RcvCallback,
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
