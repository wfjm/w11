// $Id: Rw11UnitStream.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-09  1080   1.1.2  use HasVirt(); Virt() returns ref; Pos() not const 
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2017-02-04   848   1.1    Pos(): return -1 if not attached
// 2013-05-04   515   1.0    Initial version
// 2013-05-01   513   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11UnitStream.
*/

#include "librtools/Rexception.hpp"

#include "Rw11UnitStream.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitStream
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitStream::Rw11UnitStream(Rw11Cntl* pcntl, size_t index)
  : Rw11UnitVirt<Rw11VirtStream>(pcntl, index)
{
  fStats.Define(kStatNPreAttDrop,    "NPreAttDrop",
                "output bytes dropped prior attach");
  fStats.Define(kStatNPreAttMiss,    "NPreAttMiss",
                "input bytes missed prior attach");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitStream::~Rw11UnitStream()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitStream::SetPos(int pos)
{
  if (!HasVirt()) 
    throw Rexception("Rw11UnitStream::SetPos", "no stream attached");

  RerrMsg emsg;
  if (!Virt().Seek(pos, emsg)) throw Rexception(emsg);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11UnitStream::Pos()
{
  if (!HasVirt()) return -1;            // allow tcl 'get ?' if not attached

  RerrMsg emsg;
  int irc = Virt().Tell(emsg);
  if (irc < 0) throw Rexception(emsg);
  return irc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11UnitStream::VirtRead(uint8_t* data, size_t count, RerrMsg& emsg)
{
  if (!HasVirt()) {
    fStats.Inc(kStatNPreAttMiss);
    emsg.Init("Rw11UnitStream::VirtRead", "no stream attached");
    return -1;
  }
  return Virt().Read(data, count, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitStream::VirtWrite(const uint8_t* data, size_t count, RerrMsg& emsg)
{
  if (!HasVirt()) {
    fStats.Inc(kStatNPreAttDrop, double(count));
    emsg.Init("Rw11UnitStream::VirtWrite", "no stream attached");
    return false;
  }
  return Virt().Write(data, count, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitStream::VirtFlush(RerrMsg& emsg)
{
  if (!HasVirt()) {
    emsg.Init("Rw11UnitStream::VirtFlush", "no stream attached");
    return false;
  }
  return Virt().Flush(emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitStream::Dump(std::ostream& os, int ind, const char* text,
                          int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitStream @ " << this << endl;
  Rw11UnitVirt<Rw11VirtStream>::Dump(os, ind, " ^", detail);
  return;
} 


} // end namespace Retro
