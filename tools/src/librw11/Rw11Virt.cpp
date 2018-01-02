// $Id: Rw11Virt.cpp 983 2018-01-02 20:35:59Z mueller $
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
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2017-04-02   864   1.1    add fWProt,WProt()
// 2013-03-06   495   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of Rw11Virt.
*/

#include "librtools/RosFill.hpp"

#include "Rw11Virt.hpp"

using namespace std;

/*!
  \class Retro::Rw11Virt
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11Virt::Rw11Virt(Rw11Unit* punit)
  : fpUnit(punit),
    fUrl(),
    fWProt(false),
    fStats()
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11Virt::~Rw11Virt()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11Virt::WProt() const
{
  return fWProt;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Virt::Dump(std::ostream& os, int ind, const char* text,
                    int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11Virt @ " << this << endl;

  os << bl << "  fpUnit:          " << fpUnit << endl;
  fUrl.Dump(os, ind+2, "fUrl: ");
  os << bl << "  fWProt:          " << fWProt << endl;
  fStats.Dump(os, ind+2, "fStats: ", detail-1);
  return;
}


} // end namespace Retro
