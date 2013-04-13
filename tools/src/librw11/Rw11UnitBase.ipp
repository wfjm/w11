// $Id: Rw11UnitBase.ipp 495 2013-03-06 17:13:48Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-03-06   495   1.0    Initial version
// 2013-02-05   483   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitBase.ipp 495 2013-03-06 17:13:48Z mueller $
  \brief   Implemenation (inline) of Rw11UnitBase.
*/

#include "boost/thread/locks.hpp"

#include "librtools/RosFill.hpp"

#include "Rw11CntlBase.hpp"
#include "Rw11UnitBase.hpp"

/*!
  \class Retro::Rw11UnitBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

template <class TC, class TV>
Rw11UnitBase<TC,TV>::Rw11UnitBase(TC* pcntl, size_t index)
  : Rw11Unit(index),
    fpCntl(pcntl),
    fpVirt()
{}

//------------------------------------------+-----------------------------------
//! Destructor

template <class TC, class TV>
Rw11UnitBase<TC,TV>::~Rw11UnitBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC, class TV>
inline TC& Rw11UnitBase<TC,TV>::Cntl() const
{
  return *fpCntl;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC, class TV>
inline TV* Rw11UnitBase<TC,TV>::Virt() const
{
  return fpVirt.get();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC, class TV>
inline bool Rw11UnitBase<TC,TV>::Attach(const std::string& url, RerrMsg& emsg)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Cntl().Connect());
  if (fpVirt) DetachCleanup();
  fpVirt.reset(TV::New(url, emsg));
  if (fpVirt) AttachSetup();
  return fpVirt;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC, class TV>
inline void Rw11UnitBase<TC,TV>::Detach()
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Cntl().Connect());
  if (fpVirt) DetachCleanup();
  fpVirt.reset();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC, class TV>
void Rw11UnitBase<TC,TV>::Dump(std::ostream& os, int ind, 
                               const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitBase @ " << this << std::endl;
  os << bl << "  fpCntl:          " << fpCntl   << std::endl;
  if (fpVirt) {
    fpVirt->Dump(os, ind+2, "*fpVirt: ");
  } else {
    os << bl << "  fpVirt:          " << fpVirt.get()   << std::endl;
  }
  
  Rw11Unit::Dump(os, ind, " ^");
  return;
} 

} // end namespace Retro
