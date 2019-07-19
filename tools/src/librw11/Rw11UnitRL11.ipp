// $Id: Rw11UnitRL11.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2014-06-08   561   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11UnitRL11.
*/

#include "Rw11UnitRL11.hpp"

/*!
  \class Retro::Rw11UnitRL11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitRL11::SetRlsta(uint16_t rlsta)
{
  fRlsta = rlsta;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitRL11::SetRlpos(uint16_t rlpos)
{
  fRlpos = rlpos;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11UnitRL11::Rlsta() const
{
  return fRlsta;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11UnitRL11::Rlpos() const
{
  return fRlpos;
}

} // end namespace Retro
