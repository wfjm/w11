// $Id: Rw11Virt.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-19  1090   1.1.2  use RosPrintf(bool)
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2017-04-02   864   1.1    add fWProt,WProt()
// 2013-03-06   495   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11Virt.
*/

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"

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
  os << bl << "  fWProt:          " << RosPrintf(fWProt) << endl;
  fStats.Dump(os, ind+2, "fStats: ", detail-1);
  return;
}


} // end namespace Retro
