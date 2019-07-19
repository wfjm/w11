// $Id: Rw11UnitTapeBase.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-09  1080   1.0.2  use HasVirt(); Virt() returns ref
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11UnitTapeBase.
*/

#include "Rw11UnitTapeBase.hpp"

/*!
  \class Retro::Rw11UnitTapeBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

template <class TC>
Rw11UnitTapeBase<TC>::Rw11UnitTapeBase(TC* pcntl, size_t index)
  : Rw11UnitTape(pcntl, index),
    fpCntl(pcntl)
{}

//------------------------------------------+-----------------------------------
//! Destructor

template <class TC>
Rw11UnitTapeBase<TC>::~Rw11UnitTapeBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline TC& Rw11UnitTapeBase<TC>::Cntl() const
{
  return *fpCntl;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void Rw11UnitTapeBase<TC>::Dump(std::ostream& os, int ind, const char* text,
                                int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitTapeBase  @ " << this << std::endl;
  os << bl << "  fpCntl:          " << fpCntl   << std::endl;
  Rw11UnitTape::Dump(os, ind, " ^", detail);
  return;
} 

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void  Rw11UnitTapeBase<TC>::AttachDone()
{
  // transfer, if defined capacity from unit to virt
  if (Capacity()!=0 && Virt().Capacity()==0) Virt().SetCapacity(Capacity());
  Cntl().UnitSetup(Index());
  return;
}
  

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void  Rw11UnitTapeBase<TC>::DetachDone()
{
  Cntl().UnitSetup(Index());
  return;
}

} // end namespace Retro
