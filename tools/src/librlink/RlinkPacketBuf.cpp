// $Id: RlinkPacketBuf.cpp 492 2013-02-24 22:14:47Z mueller $
//
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-02-03   481   1.0.3  use Rexception
// 2013-01-13   474   1.0.2  add PollAttn() method
// 2013-01-04   469   1.0.1  SndOob(): Add filler 0 to ensure escape state
// 2011-04-02   375   1.0    Initial version
// 2011-03-05   366   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPacketBuf.cpp 492 2013-02-24 22:14:47Z mueller $
  \brief   Implemenation of class RlinkPacketBuf.
 */

#include <sys/time.h>

// debug
#include <iostream>

#include "RlinkPacketBuf.hpp"

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/Rexception.hpp"

using namespace std;

/*!
  \class Retro::RlinkPacketBuf
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint32_t RlinkPacketBuf::kFlagSopSeen;
const uint32_t RlinkPacketBuf::kFlagEopSeen;
const uint32_t RlinkPacketBuf::kFlagNakSeen;
const uint32_t RlinkPacketBuf::kFlagAttnSeen;
const uint32_t RlinkPacketBuf::kFlagTout;
const uint32_t RlinkPacketBuf::kFlagDatDrop;
const uint32_t RlinkPacketBuf::kFlagDatMiss;

const uint8_t RlinkPacketBuf::kCPREF;
const uint8_t RlinkPacketBuf::kNCOMM;
const uint8_t RlinkPacketBuf::kCommaIdle;
const uint8_t RlinkPacketBuf::kCommaSop;
const uint8_t RlinkPacketBuf::kCommaEop;
const uint8_t RlinkPacketBuf::kCommaNak;
const uint8_t RlinkPacketBuf::kCommaAttn;
const uint8_t RlinkPacketBuf::kSymEsc;

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkPacketBuf::RlinkPacketBuf()
  : fPktBuf(),
    fRawBuf(),
    fRawBufSize(0),
    fCrc(),
    fFlags(0),
    fNdone(0),
    fNesc(0),
    fNattn(0),
    fNidle(0),
    fNdrop(0)
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkPacketBuf::~RlinkPacketBuf()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPacketBuf::Init()
{
  fPktBuf.clear();
  fRawBufSize = 0;
  fCrc.Clear();
  fFlags = 0;
  fNdone = 0;
  fNesc  = 0;
  fNattn = 0;
  fNidle = 0;
  fNdrop = 0;
  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPacketBuf::SndPacket(RlinkPort* port, RerrMsg& emsg)
{
  fRawBuf.reserve(2*fPktBuf.size()+2);        // max. size of raw data
  fRawBuf.clear();
  
  fRawBuf.push_back(kCommaSop);

  size_t   ni = fPktBuf.size();
  uint8_t* pi = fPktBuf.data();
  for (size_t i=0; i<ni; i++) {
    uint8_t c = *pi++;
    if (c == kSymEsc || (c >= kCPREF && c <= kCPREF+kNCOMM)) {
      fRawBuf.push_back(kSymEsc);
      fRawBuf.push_back(((~kCPREF) & 0xf0) | (c & 0x0f));
      fNesc += 1;
    } else {
      fRawBuf.push_back(c);
    }
  }

  fRawBuf.push_back(kCommaEop);

  return SndRaw(port, emsg);
  
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPacketBuf::RcvPacket(RlinkPort* port, size_t nrcv, float timeout, 
                               RerrMsg& emsg)
{
  fPktBuf.clear();

  bool   escseen = false;                   // in esc
  bool   sopseen = false;                   // sop seen
  bool   eopseen = false;                   // eop seen
  bool   nakseen = false;                   // nak seen

  while (!(eopseen|nakseen)) {              // try till eop or nak received
    size_t   nread = nrcv - fPktBuf.size();
    // FIXME_code: if the 'enough data' handling below correct ?
    if (nread < 0)  return true;
    
    if (!sopseen) nread += 1;
    if (!eopseen) nread += 1;

    size_t sizeold = fRawBufSize;
    int irc = RcvRaw(port, nread, timeout, emsg);

    if (irc <= 0) {
      if (irc == RlinkPort::kTout) {
        SetFlagBit(kFlagTout);
        return true;
      } else {
        return false;
      }
    }

    uint8_t* pi = fRawBuf.data()+sizeold;
    for (int i=0; i<irc; i++) {
      uint8_t c = *pi++;
      if (escseen) {
        escseen = false;
        if (sopseen && !(nakseen || eopseen)) {
          fPktBuf.push_back((kCPREF & 0xf0) | (c & 0x0f));
        }
      } else if (c == kCommaSop) {
        if (!eopseen) {
          SetFlagBit(kFlagSopSeen);
          sopseen  = true;
        } else {
          // FIXME_code: handle multiple sop
        }
      } else if (c == kCommaEop) {
        SetFlagBit(kFlagEopSeen);
        eopseen  = true;
      } else if (c == kCommaNak) {
        SetFlagBit(kFlagNakSeen);
        nakseen  = true;
      } else if (c == kCommaAttn) {
        SetFlagBit(kFlagAttnSeen);
        fNattn += 1;
      } else if (c == kCommaIdle) {
        fNidle += 1;
      } else if (c == kSymEsc) {
        fNesc += 1;
        escseen = true;
      } else {
        if (sopseen && !(nakseen || eopseen)) {
          fPktBuf.push_back(c);
        } else {
          fNdrop += 1;
        }
      }
    } // for (int i=0; i<irc; i++)

  } // while (!(eopseen|nakseen))

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

double RlinkPacketBuf::WaitAttn(RlinkPort* port, double timeout, RerrMsg& emsg)
{
  if (timeout <= 0.)
    throw Rexception("RlinkPacketBuf::WaitAttn()", "Bad args: timeout <= 0.");

  struct timeval tval;
  gettimeofday(&tval, 0);
  double tbeg  = double(tval.tv_sec) + 1.e-6*double(tval.tv_usec);
  double trest = timeout;

  Init();

  while (trest > 0.) {
    size_t sizeold = fRawBufSize;
    int irc = RcvRaw(port, 1, trest, emsg);

    if (irc <= 0) {
      if (irc == RlinkPort::kTout) {
        SetFlagBit(kFlagTout);
        return -1.;
      } else {
        return -2.;
      }
    }

    gettimeofday(&tval, 0);
    double tend  = double(tval.tv_sec) + 1.e-6*double(tval.tv_usec);
    trest -= (tend-tbeg);

    uint8_t c = fRawBuf[sizeold];

    if (c == kCommaAttn) {
      fNattn += 1;
      SetFlagBit(kFlagAttnSeen);
      break;
    } else if (c == kCommaIdle) {
      fNidle += 1;
    } else {
      fNdrop += 1;
    }

    tbeg   = tend;
  }

  return timeout - trest;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RlinkPacketBuf::PollAttn(RlinkPort* port, RerrMsg& emsg)
{
  Init();

  int irc = RcvRaw(port, 128, 0., emsg);

  if (irc <= 0) {
    if (irc == RlinkPort::kTout) {
      SetFlagBit(kFlagTout);
      return 0;
    } else {
      return -2;
    }
  }

  for (size_t i=0; i<(size_t)irc; i++) {
    uint8_t c = fRawBuf[i];
    if (c == kCommaAttn) {
      fNattn += 1;
      SetFlagBit(kFlagAttnSeen);
      break;
    } else if (c == kCommaIdle) {
      fNidle += 1;
    } else {
      fNdrop += 1;
    }
  }

  return fNattn;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPacketBuf::SndOob(RlinkPort* port, uint16_t addr, uint16_t data, 
                            RerrMsg& emsg)
{
  Init();

  fRawBuf.clear();
  fRawBuf.push_back(kSymEsc);                       // ESC
  fRawBuf.push_back(kSymEsc);                       // ESC
  fRawBuf.push_back((uint8_t)addr);                 // ADDR 
  fRawBuf.push_back((uint8_t)(data & 0x00ff));      // DL
  fRawBuf.push_back((uint8_t)((data>>8) & 0x00ff)); // DH
  // write a filler char (just 0) to ensure that the 8b->9b stage in the
  // receiver (byte2cdata) is always out if the escape state...
  fRawBuf.push_back(0);                             // filler

  return SndRaw(port, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPacketBuf::SndKeep(RlinkPort* port, RerrMsg& emsg)
{
  Init();

  fRawBuf.clear();
  fRawBuf.push_back(kSymEsc);                       // ESC
  fRawBuf.push_back(kSymEsc);                       // ESC

  return SndRaw(port, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPacketBuf::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkPacketBuf @ " << this << endl;
  os << bl << "  fCrc:          " << RosPrintBvi(fCrc.Crc(), 0) << endl;
  os << bl << "  fFlags:        " << RosPrintBvi(fFlags, 0) << endl;
  os << bl << "  fNdone:        " << RosPrintf(fNdone,"d",4) << endl;
  os << bl << "  fNesc:         " << RosPrintf(fNesc,"d",4) << endl;
  os << bl << "  fNattn:        " << RosPrintf(fNattn,"d",4) << endl;
  os << bl << "  fNidle:        " << RosPrintf(fNidle,"d",4) << endl;
  os << bl << "  fNdrop:        " << RosPrintf(fNdrop,"d",4) << endl;

  os << bl << "  fPktBuf(size): " << RosPrintf(fPktBuf.size(),"d",4);
  size_t ncol  = max(1, (80-ind-4-6)/(2+1));
  for (size_t i=0; i< fPktBuf.size(); i++) {
    if (i%ncol == 0) os << "\n" << bl << "    " << RosPrintf(i,"d",4) << ": ";
    os << RosPrintBvi(fPktBuf[i],16) << " ";
  }
  os << endl;

  os << bl << "  fRawBuf(size): " << RosPrintf(fRawBufSize,"d",4);
  for (size_t i=0; i< fRawBufSize; i++) {
    if (i%ncol == 0) os << "\n" << bl << "    " << RosPrintf(i,"d",4) << ": ";
    os << RosPrintBvi(fRawBuf[i],16) << " ";
  }
  os << endl;
  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPacketBuf::SndRaw(RlinkPort* port, RerrMsg& emsg)
{
  if (port==0 || !port->IsOpen())
    throw Rexception("RlinkPacketBuf::SndRaw()", "Bad state: port not open");

  fRawBufSize = fRawBuf.size();
  int irc = port->Write(fRawBuf.data(), fRawBuf.size(), emsg);
  if (irc < 0) return false;
  if ((size_t)irc != fRawBuf.size()) {
    emsg.Init("RlinkPacketBuf::SndRaw()", "failed to write all data");
    return false;
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RlinkPacketBuf::RcvRaw(RlinkPort* port, size_t size, float timeout, 
                           RerrMsg& emsg)
{
  if (port==0 || !port->IsOpen())
    throw Rexception("RlinkPacketBuf::RcvRaw()", "Bad state: port not open");

  if (fRawBuf.size() < fRawBufSize+size) fRawBuf.resize(fRawBufSize+size);
  int irc = port->Read(fRawBuf.data()+fRawBufSize, size, timeout, emsg);
  if (irc == RlinkPort::kEof) {
    emsg.Init("RlinkPacketBuf::RcvRaw()", "eof on read");
  }
  
  if (irc > 0) {
    fRawBufSize += irc;
  }

  return irc;
}

} // end namespace Retro
