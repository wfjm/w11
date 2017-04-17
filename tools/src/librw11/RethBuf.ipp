// $Id: RethBuf.ipp 859 2017-03-11 22:36:45Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-02-25   856   1.0    Initial version
// 2017-02-12   850   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RethBuf.ipp 859 2017-03-11 22:36:45Z mueller $
  \brief   Implemenation (inline) of RethBuf.
*/

#include "RethTools.hpp"

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RethBuf::Clear()
{
  fSize = 0;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RethBuf::SetSize(uint16_t size)
{
  fSize = size;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RethBuf::SetTime()
{
  fTime.GetClock(CLOCK_REALTIME);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RethBuf::SetTime(const Rtime& time)
{
  fTime = time;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t RethBuf::Size() const
{
  return fSize;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rtime& RethBuf::Time() const
{
  return fTime;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const uint8_t* RethBuf::Buf8() const
{
  return fBuf;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const uint16_t* RethBuf::Buf16() const
{
  return (uint16_t*) fBuf;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const uint32_t* RethBuf::Buf32() const
{
  return (uint32_t*) fBuf;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint8_t* RethBuf::Buf8()
{
  return fBuf;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t* RethBuf::Buf16()
{
  return (uint16_t*) fBuf;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t* RethBuf::Buf32()
{
  return (uint32_t*) fBuf;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RethBuf::SetMacDestination(uint64_t mac)
{
  RethTools::Mac2WList(mac, Buf16()+kWOffDstMac);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RethBuf::SetMacSource(uint64_t mac)
{
  RethTools::Mac2WList(mac, Buf16()+kWOffSrcMac);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint64_t RethBuf::MacDestination() const
{
  return RethTools::WList2Mac(Buf16()+kWOffDstMac);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint64_t RethBuf::MacSource() const
{
  return RethTools::WList2Mac(Buf16()+kWOffSrcMac);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RethBuf::IsMcast() const
{
  return fBuf[0] & 0x1;                     // odd first byte destination MAC 
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RethBuf::IsBcast() const
{
  return Buf16()[0] == 0xffff && Buf16()[1] == 0xffff && Buf16()[2] == 0xffff;
}


} // end namespace Retro
