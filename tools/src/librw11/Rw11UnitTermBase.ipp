// $Id: Rw11UnitTermBase.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-05-12  1149   1.1    add AttachDone(),DetachDone()
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-03-03   494   1.0    Initial version
// 2013-02-22   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11UnitTermBase.
*/

#include "Rw11UnitTermBase.hpp"

/*!
  \class Retro::Rw11UnitTermBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

template <class TC>
Rw11UnitTermBase<TC>::Rw11UnitTermBase(TC* pcntl, size_t index)
  : Rw11UnitTerm(pcntl, index),
    fpCntl(pcntl)
{}

//------------------------------------------+-----------------------------------
//! Destructor

template <class TC>
Rw11UnitTermBase<TC>::~Rw11UnitTermBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline TC& Rw11UnitTermBase<TC>::Cntl() const
{
  return *fpCntl;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline void Rw11UnitTermBase<TC>::WakeupCntl()
{
  fpCntl->Wakeup();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void Rw11UnitTermBase<TC>::Dump(std::ostream& os, int ind, const char* text,
                                int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitTermBase  @ " << this << std::endl;
  os << bl << "  fpCntl:          " << fpCntl   << std::endl;
  Rw11UnitTerm::Dump(os, ind, " ^", detail);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void  Rw11UnitTermBase<TC>::AttachDone()
{
  Rw11UnitTerm::AttachDone();               // call base class handler
  Cntl().UnitSetup(Index());                // inform controller
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void  Rw11UnitTermBase<TC>::DetachDone()
{
  Cntl().UnitSetup(Index());
  return;
}

} // end namespace Retro
