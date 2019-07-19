// $Id: Rw11UnitTM11.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11UnitTM11.
*/

#include "librtools/RosFill.hpp"
#include "Rw11CntlTM11.hpp"

#include "Rw11UnitTM11.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitTM11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitTM11::Rw11UnitTM11(Rw11CntlTM11* pcntl, size_t index)
  : Rw11UnitTapeBase<Rw11CntlTM11>(pcntl, index),
    fTmds(0)
{
  // setup tape unit type: only tu10 supported !
  fType    = "tu10";
  fEnabled = true;
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitTM11::~Rw11UnitTM11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitTM11::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitTM11 @ " << this << endl;
  os << bl << "  fTmds:           " << fTmds    << endl;

  Rw11UnitTapeBase<Rw11CntlTM11>::Dump(os, ind, " ^", detail);
  return;
}
  
} // end namespace Retro
