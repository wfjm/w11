// $Id: Rw11UnitDL11.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-03-03   494   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11UnitDL11.
*/

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
