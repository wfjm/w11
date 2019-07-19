// $Id: Rw11UnitDiskBase.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-09  1080   1.1.3  use HasVirt(); Virt() returns ref
// 2018-10-27  1061   1.1.2  adapt to new Rw11VirtDisk::Setup interface    
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2013-05-03   515   1.1    use AttachDone(),DetachCleanup(),DetachDone()
// 2013-04-14   506   1.0    Initial version
// 2013-02-22   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11UnitDiskBase.
*/

#include "Rw11UnitDiskBase.hpp"

/*!
  \class Retro::Rw11UnitDiskBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

template <class TC>
Rw11UnitDiskBase<TC>::Rw11UnitDiskBase(TC* pcntl, size_t index)
  : Rw11UnitDisk(pcntl, index),
    fpCntl(pcntl)
{}

//------------------------------------------+-----------------------------------
//! Destructor

template <class TC>
Rw11UnitDiskBase<TC>::~Rw11UnitDiskBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline TC& Rw11UnitDiskBase<TC>::Cntl() const
{
  return *fpCntl;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void Rw11UnitDiskBase<TC>::Dump(std::ostream& os, int ind, const char* text,
                                int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitDiskBase  @ " << this << std::endl;
  os << bl << "  fpCntl:          " << fpCntl   << std::endl;
  Rw11UnitDisk::Dump(os, ind, " ^", detail);
  return;
} 

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void  Rw11UnitDiskBase<TC>::AttachDone()
{
  Virt().Setup(BlockSize(), NBlock(), NCylinder(), NHead(), NSector());
  Cntl().UnitSetup(Index());
  return;
}
  

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
void  Rw11UnitDiskBase<TC>::DetachDone()
{
  SetWProt(false);
  Cntl().UnitSetup(Index());
  return;
}

} // end namespace Retro
