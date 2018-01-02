// $Id: Rw11UnitDL11.cpp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-03-03   494   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of Rw11UnitDL11.
*/

#include "boost/bind.hpp"

#include "librtools/RosFill.hpp"
#include "Rw11CntlDL11.hpp"

#include "Rw11UnitDL11.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitDL11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitDL11::Rw11UnitDL11(Rw11CntlDL11* pcntl, size_t index)
  : Rw11UnitTermBase<Rw11CntlDL11>(pcntl, index)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitDL11::~Rw11UnitDL11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitDL11::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitDL11 @ " << this << endl;
  Rw11UnitTermBase<Rw11CntlDL11>::Dump(os, ind, " ^", detail);
  return;
}
  
} // end namespace Retro
