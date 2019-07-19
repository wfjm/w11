// $Id: Rw11UnitTM11.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11UnitTM11.
*/

#include "Rw11UnitTM11.hpp"

/*!
  \class Retro::Rw11UnitTM11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitTM11::SetTmds(uint16_t tmds)
{
  fTmds = tmds;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11UnitTM11::Tmds() const
{
  return fTmds;
}

} // end namespace Retro
