// $Id: Rw11UnitDisk.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-19  1090   1.0.4  use RosPrintf(bool)
// 2018-12-09  1080   1.0.3  use HasVirt(); Virt() returns ref
// 2017-04-07   868   1.0.2  Dump(): add detail arg
// 2015-03-21   659   1.0.1  add fEnabled, Enabled()
// 2013-04-19   507   1.0    Initial version
// 2013-02-19   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11UnitDisk.
*/

#include "librtools/Rexception.hpp"
#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"

#include "Rw11UnitDisk.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitDisk
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitDisk::Rw11UnitDisk(Rw11Cntl* pcntl, size_t index)
  : Rw11UnitVirt<Rw11VirtDisk>(pcntl, index),
    fType(),
    fEnabled(false),
    fNCyl(0),
    fNHead(0),
    fNSect(0),
    fBlksize(0),
    fNBlock(),
    fWProt(false)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitDisk::~Rw11UnitDisk()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitDisk::SetType(const std::string& /*type*/)
{
  throw Rexception("Rw11UnitDisk::SetType", 
                   string("Bad args: only type '") + fType + "' supported");
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitDisk::VirtRead(size_t lba, size_t nblk, uint8_t* data,
                            RerrMsg& emsg)
{
  if (!HasVirt()) {
    emsg.Init("Rw11UnitDisk::VirtRead", "no disk attached");
    return false;
  }
  return Virt().Read(lba, nblk, data, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitDisk::VirtWrite(size_t lba, size_t nblk, const uint8_t* data, 
                             RerrMsg& emsg)
{
  if (!HasVirt()) {
    emsg.Init("Rw11UnitDisk::VirtWrite", "no disk attached");
    return false;
  }
  return Virt().Write(lba, nblk, data, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitDisk::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitDisk @ " << this << endl;
  os << bl << "  fType:           " << fType  << endl;
  os << bl << "  fEnabled:        " << RosPrintf(fEnabled) << endl;
  os << bl << "  fNCyl:           " << fNCyl  << endl;
  os << bl << "  fNHead:          " << fNHead << endl;
  os << bl << "  fNSect:          " << fNSect << endl;
  os << bl << "  fBlksize:        " << fBlksize << endl;
  os << bl << "  fNBlock:         " << fNBlock  << endl;
  os << bl << "  fWProt:          " << RosPrintf(fWProt) << endl;

  Rw11UnitVirt<Rw11VirtDisk>::Dump(os, ind, " ^", detail);
  return;
} 


} // end namespace Retro
