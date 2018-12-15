// $Id: Rw11UnitVirt.ipp 1080 2018-12-09 20:30:33Z mueller $
//
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-09  1080   1.4    add HasVirt(); return ref for Virt()
// 2018-12-01  1076   1.3    use unique_ptr instead of scoped_ptr
// 2017-04-15   875   1.2.2  add VirtBase()
// 2017-04-07   868   1.2.1  Dump(): add detail arg
// 2015-05-13   680   1.2    Attach(): check for Enabled()
// 2014-11-02   600   1.1.1  add (bool) cast, needed in 4.8.2
// 2013-05-03   515   1.1    use AttachDone(),DetachCleanup(),DetachDone()
// 2013-03-03   494   1.0    Initial version
// 2013-02-05   483   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (inline) of Rw11UnitVirt.
*/

#include "boost/thread/locks.hpp"

#include "librtools/RosFill.hpp"

#include "Rw11UnitVirt.hpp"

/*!
  \class Retro::Rw11UnitVirt
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

template <class TV>
Rw11UnitVirt<TV>::Rw11UnitVirt(Rw11Cntl* pcntl, size_t index)
  : Rw11Unit(pcntl, index),
    fupVirt()
{}

//------------------------------------------+-----------------------------------
//! Destructor

template <class TV>
Rw11UnitVirt<TV>::~Rw11UnitVirt()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TV>
inline bool Rw11UnitVirt<TV>::HasVirt() const
{
  return bool(fupVirt);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TV>
inline TV& Rw11UnitVirt<TV>::Virt()
{
  return *fupVirt;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TV>
inline const TV& Rw11UnitVirt<TV>::Virt() const
{
  return *fupVirt;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TV>
inline Rw11Virt* Rw11UnitVirt<TV>::VirtBase() const
{
  return fupVirt.get();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TV>
inline bool Rw11UnitVirt<TV>::Attach(const std::string& url, RerrMsg& emsg)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Connect());
  if (fupVirt) Detach();
  if (!Enabled()) {
    emsg.Init("Rw11UnitVirt::Attach","unit not enabled");
    return false;
  }
  fupVirt = std::move(TV::New(url, this, emsg));
  if (fupVirt) AttachDone();
  return bool(fupVirt);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TV>
inline void Rw11UnitVirt<TV>::Detach()
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Connect());
  if (!fupVirt) return;
  DetachCleanup();
  fupVirt.reset();
  DetachDone();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TV>
void Rw11UnitVirt<TV>::Dump(std::ostream& os, int ind, const char* text,
                            int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitVirt @ " << this << std::endl;
  if (fupVirt) {
    fupVirt->Dump(os, ind+2, "*fupVirt: ", detail);
  } else {
    os << bl << "  fupVirt:         " << fupVirt.get()   << std::endl;
  }
  
  Rw11Unit::Dump(os, ind, " ^", detail);
  return;
} 

} // end namespace Retro
