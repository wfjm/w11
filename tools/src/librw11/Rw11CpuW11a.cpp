// $Id: Rw11CpuW11a.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2014-12-25   621   1.1    adopt to 4k word ibus window
// 2013-03-03   494   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11CpuW11a.
*/

#include "librtools/RosFill.hpp"

#include "Rw11CpuW11a.hpp"

using namespace std;

/*!
  \class Retro::Rw11CpuW11a
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CpuW11a::Rw11CpuW11a()
  : Rw11Cpu("w11a")
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11CpuW11a::~Rw11CpuW11a()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CpuW11a::Setup(size_t ind, uint16_t base, uint16_t ibase)
{
  fIndex = ind;
  fBase  = base;
  fIBase = ibase;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CpuW11a::Dump(std::ostream& os, int ind, const char* text,
                       int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CpuW11a @ " << this << endl;
  Rw11Cpu::Dump(os, ind, " ^", detail);
  return;
}
  
} // end namespace Retro
