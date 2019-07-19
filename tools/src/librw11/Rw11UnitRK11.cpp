// $Id: Rw11UnitRK11.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-04-20   508   1.0    Initial version
// 2013-02-05   483   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11UnitRK11.
*/

#include "librtools/RosFill.hpp"
#include "Rw11CntlRK11.hpp"

#include "Rw11UnitRK11.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitRK11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitRK11::Rw11UnitRK11(Rw11CntlRK11* pcntl, size_t index)
  : Rw11UnitDiskBase<Rw11CntlRK11>(pcntl, index),
    fRkds(0)
{
  // setup disk geometry: only rk05 supported, no rk05f !
  fType    = "rk05";
  fEnabled = true;
  fNCyl    = 203;
  fNHead   =   2;
  fNSect   =  12;
  fBlksize = 512;
  fNBlock  = fNCyl*fNHead*fNSect;
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitRK11::~Rw11UnitRK11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitRK11::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitRK11 @ " << this << endl;
  os << bl << "  fRkds:           " << fRkds    << endl;

  Rw11UnitDiskBase<Rw11CntlRK11>::Dump(os, ind, " ^", detail);
  return;
}
  
} // end namespace Retro
