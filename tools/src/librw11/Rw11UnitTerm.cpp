// $Id: Rw11UnitTerm.cpp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-04-13   504   1.0    Initial version
// 2013-02-19   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitTerm.cpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Implemenation of Rw11UnitTerm.
*/

#include "boost/thread/locks.hpp"
#include "boost/bind.hpp"

#include "librtools/RosPrintf.hpp"

#include "Rw11UnitTerm.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitTerm
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitTerm::Rw11UnitTerm(Rw11Cntl* pcntl, size_t index)
  : Rw11UnitVirt<Rw11VirtTerm>(pcntl, index),
    fRcv7bit(false),
    fRcvQueue()
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitTerm::~Rw11UnitTerm()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

const std::string& Rw11UnitTerm::ChannelId() const
{
  if (fpVirt) return fpVirt->ChannelId();
  static string nil;
  return nil;
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTerm::RcvQueueEmpty()
{
  return fRcvQueue.empty();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t Rw11UnitTerm::RcvQueueSize()
{
  return fRcvQueue.size();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

uint8_t Rw11UnitTerm::RcvNext()
{
  if (RcvQueueEmpty()) return 0;
  uint8_t ochr = fRcvQueue.front();
  fRcvQueue.pop_front();
  return ochr;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t Rw11UnitTerm::Rcv(uint8_t* buf, size_t count)
{
  uint8_t* p = buf;
  for (size_t i=0; i<count && !fRcvQueue.empty(); i++) {
    *p++ = fRcvQueue.front();
    fRcvQueue.pop_front();
  }
  return p - buf;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTerm::Snd(const uint8_t* buf, size_t count)
{
  bool ok = true;
  if (fpVirt) {
    RerrMsg emsg;
    ok = fpVirt->Snd(buf, count, emsg);
    // FIXME_code: handler errors
  } else {
    for (size_t i=0; i<count; i++) cout << buf[i] << flush;
  }
  return ok;
}


//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTerm::RcvCallback(const uint8_t* buf, size_t count)
{
  // lock connect to protect rxqueue
  boost::lock_guard<RlinkConnect> lock(Connect());

  bool que_empty_old = fRcvQueue.empty();
  for (size_t i=0; i<count; i++) fRcvQueue.push_back(buf[i]);
  bool que_empty_new = fRcvQueue.empty();
  if (que_empty_old && !que_empty_new) WakeupCntl();
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitTerm::WakeupCntl()
{
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitTerm::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitTerm @ " << this << endl;

  os << bl << "  fRcv7bit:        " << fRcv7bit << endl;
  {
    boost::lock_guard<RlinkConnect> lock(Connect());
    size_t size = fRcvQueue.size();
    os << bl << "  fRcvQueue.size:  " << fRcvQueue.size() << endl;
    if (size > 0) {
      os << bl << "  fRcvQueue:       \"";
      size_t ocount = 0;
      for (size_t i=0; i<size; i++) {
        if (ocount >= 50) {
          os << "...";
          break;
        }
        uint8_t byt = fRcvQueue[i];
        if (byt >= 040 && byt <= 0176) {
          os << char(byt);
          ocount += 1;
        } else {
          os << "<" << RosPrintf(byt,"o0",3) << ">";
          ocount += 5;
        }
      }
      os << "\"" << endl;
    }
  }
  
  Rw11UnitVirt<Rw11VirtTerm>::Dump(os, ind, " ^");
  return;
} 

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitTerm::AttachSetup()
{
  fpVirt->SetupRcvCallback(boost::bind(&Rw11UnitTerm::RcvCallback,
                                           this, _1, _2));
  return;
}


} // end namespace Retro
