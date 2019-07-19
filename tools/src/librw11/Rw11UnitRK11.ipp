// $Id: Rw11UnitRK11.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-04-20   508   1.0    Initial version
// 2013-04-14   505   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11UnitRK11.
*/

#include "Rw11UnitRK11.hpp"

/*!
  \class Retro::Rw11UnitRK11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitRK11::SetRkds(uint16_t rkds)
{
  fRkds = rkds;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11UnitRK11::Rkds() const
{
  return fRkds;
}

} // end namespace Retro
