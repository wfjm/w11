// $Id: Rw11UnitRHRP.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2015-05-14   680   1.0    Initial version
// 2015-03-21   659   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11UnitRHRP.
*/

#include "Rw11UnitRHRP.hpp"

/*!
  \class Retro::Rw11UnitRHRP
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11UnitRHRP::Rpdt() const
{
  return fRpdt;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitRHRP::IsRmType() const
{
  return fRpdt & kDTE_M_RM;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitRHRP::SetRpds(uint16_t rpds)
{
  fRpds = rpds;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11UnitRHRP::Rpds() const
{
  return fRpds;
}

} // end namespace Retro
