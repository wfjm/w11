// $Id: Rw11UnitPC11.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-05-12  1149   1.1.1  AttachDone(): use base class AttachDone()
// 2019-04-20  1134   1.1    add AttachDone()
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-05-03   515   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11UnitPC11.
*/

#include "librtools/RosFill.hpp"
#include "Rw11CntlPC11.hpp"

#include "Rw11UnitPC11.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitPC11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitPC11::Rw11UnitPC11(Rw11CntlPC11* pcntl, size_t index)
  : Rw11UnitStreamBase<Rw11CntlPC11>(pcntl, index)
{
  // unit 0 -> reader   -> read  only stream
  // unit 1 -> puncher  -> write only stream
  const char* opts = (index==0) ? "?ronly" : "?wonly";
  SetAttachOpts(opts);
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitPC11::~Rw11UnitPC11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitPC11::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitPC11 @ " << this << endl;
  Rw11UnitStreamBase<Rw11CntlPC11>::Dump(os, ind, " ^", detail);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitPC11::AttachDone()
{
  // the base class AttachDone() calls Cntl().UnitSetup() for all UnitStream's
  // the UnitPC11 specialization calls Cntl().AttachDone in addition
  Rw11UnitStreamBase<Rw11CntlPC11>::AttachDone();
  Cntl().AttachDone(Index());
  return;
}
  
} // end namespace Retro
