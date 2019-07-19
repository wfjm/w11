// $Id: Rw11UnitStreamBase.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-05-04   515   1.0    Initial version
// 2013-05-01   513   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11UnitStreamBase.
*/

#include "Rw11UnitStreamBase.hpp"

/*!
  \class Retro::Rw11UnitStreamBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

template <class TC>
Rw11UnitStreamBase<TC>::Rw11UnitStreamBase(TC* pcntl, size_t index)
  : Rw11UnitStream(pcntl, index),
    fpCntl(pcntl)
{}

//------------------------------------------+-----------------------------------
//! Destructor

template <class TC>
Rw11UnitStreamBase<TC>::~Rw11UnitStreamBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline TC& Rw11UnitStreamBase<TC>::Cntl() const
{
  return *fpCntl;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void Rw11UnitStreamBase<TC>::Dump(std::ostream& os, int ind, const char* text,
                                  int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitStreamBase  @ " << this << std::endl;
  os << bl << "  fpCntl:          " << fpCntl   << std::endl;
  Rw11UnitStream::Dump(os, ind, " ^", detail);
  return;
} 

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void  Rw11UnitStreamBase<TC>::AttachDone()
{
  Cntl().UnitSetup(Index());
  return;
}
  

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void  Rw11UnitStreamBase<TC>::DetachDone()
{
  Cntl().UnitSetup(Index());
  return;
}

} // end namespace Retro
