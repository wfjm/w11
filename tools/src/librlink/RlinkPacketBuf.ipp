// $Id: RlinkPacketBuf.ipp 375 2011-04-02 07:56:47Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-04-02   375   1.0    Initial version
// 2011-03-05   366   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPacketBuf.ipp 375 2011-04-02 07:56:47Z mueller $
  \brief   Implemenation (inline) of class RlinkPacketBuf.
*/

// all method definitions in namespace Retro (avoid using in includes...)
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBuf::PutWithCrc(uint8_t data)
{
  fPktBuf.push_back(data);
  fCrc.AddData(data);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBuf::PutWithCrc(uint16_t data)
{
  PutWithCrc((uint8_t)( data     & 0xff)); // lsb first
  PutWithCrc((uint8_t)((data>>8) & 0xff));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBuf::PutCrc()
{
  fPktBuf.push_back(fCrc.Crc());
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkPacketBuf::CheckSize(size_t nbyte) const
{
  return fPktBuf.size()-fNdone >= nbyte;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint8_t RlinkPacketBuf::Get8WithCrc()
{
  uint8_t data = fPktBuf[fNdone++];
  fCrc.AddData(data);
  return data;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t RlinkPacketBuf::Get16WithCrc()
{
  uint8_t datl = fPktBuf[fNdone++];
  uint8_t dath = fPktBuf[fNdone++];
  fCrc.AddData(datl);
  fCrc.AddData(dath);
  return (uint16_t)datl | ((uint16_t)dath << 8);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkPacketBuf::CheckCrc()
{
  uint8_t data = fPktBuf[fNdone++];
  return data == fCrc.Crc();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkPacketBuf::PktSize() const
{
  return fPktBuf.size();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkPacketBuf::RawSize() const
{
  return fRawBuf.size();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBuf::SetFlagBit(uint32_t mask)
{
  fFlags |= mask;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkPacketBuf::Flags() const
{
  return fFlags;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkPacketBuf::TestFlag(uint32_t mask) const
{
  return (fFlags & mask) != 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkPacketBuf::Nesc() const
{
  return fNesc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkPacketBuf::Nattn() const
{
  return fNattn;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkPacketBuf::Nidle() const
{
  return fNidle;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkPacketBuf::Ndrop() const
{
  return fNdrop;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBuf::ClearFlagBit(uint32_t mask)
{
  fFlags &= ~mask;
  return;
}

} // end namespace Retro
