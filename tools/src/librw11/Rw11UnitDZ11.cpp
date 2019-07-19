// $Id: Rw11UnitDZ11.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-05-04  1146   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11UnitDZ11.
*/

#include "librtools/RosFill.hpp"
#include "Rw11CntlDZ11.hpp"

#include "Rw11UnitDZ11.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitDZ11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitDZ11::Rw11UnitDZ11(Rw11CntlDZ11* pcntl, size_t index)
  : Rw11UnitTermBase<Rw11CntlDZ11>(pcntl, index)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitDZ11::~Rw11UnitDZ11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitDZ11::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitDZ11 @ " << this << endl;
  Rw11UnitTermBase<Rw11CntlDZ11>::Dump(os, ind, " ^", detail);
  return;
}
  
} // end namespace Retro
