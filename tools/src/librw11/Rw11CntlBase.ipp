// $Id: Rw11CntlBase.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.0.3  use std::shared_ptr instead of boost
// 2017-04-15   874   1.0.2  add UnitBase()
// 2017-04-02   865   1.0.1  Dump(): add detail arg
// 2013-03-06   495   1.0    Initial version
// 2013-02-14   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11CntlBase.
*/

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"

#include "Rw11CntlBase.hpp"

/*!
  \class Retro::Rw11CntlBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

template <class TU, size_t NU>
inline Rw11CntlBase<TU,NU>::Rw11CntlBase(const std::string& type)
  : Rw11Cntl(type)
{}

//------------------------------------------+-----------------------------------
//! Destructor

template <class TU, size_t NU>
inline Rw11CntlBase<TU,NU>::~Rw11CntlBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TU, size_t NU>
inline size_t Rw11CntlBase<TU,NU>::NUnit() const
{
  return NU;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TU, size_t NU>
inline Rw11Unit& Rw11CntlBase<TU,NU>::UnitBase(size_t index) const
{
  return *fspUnit[index];
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TU, size_t NU>
inline TU& Rw11CntlBase<TU,NU>::Unit(size_t index) const
{
  return *fspUnit[index];
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TU, size_t NU>
inline const std::shared_ptr<TU>& 
  Rw11CntlBase<TU,NU>::UnitSPtr(size_t index) const
{
  return fspUnit[index];
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TU, size_t NU>
void Rw11CntlBase<TU,NU>::Dump(std::ostream& os, int ind, 
                               const char* text, int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlBase @ " << this << std::endl;
  os << bl << "  fspUnit:         " << std::endl;
  for (size_t i=0; i<NU; i++) {
    os << bl << "    " << RosPrintf(i,"d",2) << "       : " 
       << fspUnit[i].get() << std::endl;
  }
  Rw11Cntl::Dump(os, ind, " ^", detail);
  return;
}
  
} // end namespace Retro
