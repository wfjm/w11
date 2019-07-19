// $Id: Rw11UnitVirt.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-17  1085   1.4.1  use std::lock_guard instead of boost
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
  \brief   Implemenation (inline) of Rw11UnitVirt.
*/

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
  std::lock_guard<RlinkConnect> lock(Connect());
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
  std::lock_guard<RlinkConnect> lock(Connect());
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
