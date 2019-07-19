// $Id: Rw11UnitTape.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-09  1080   1.0.1  use HasVirt(); Virt() returns ref
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11UnitTape.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rw11UnitTape::Type() const
{
  return fType;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitTape::Enabled() const
{
  return fEnabled;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitTape::WProt() const
{
  return HasVirt() ? Virt().WProt() : fWProt;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11UnitTape::Capacity() const
{
  return HasVirt() ? Virt().Capacity() : fCapacity;
}


} // end namespace Retro
