// $Id: RlinkCrc16.ipp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2014-11-08   602   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (inline) of class RlinkCrc16.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

inline RlinkCrc16::RlinkCrc16()
  : fCrc(0)
{}

//------------------------------------------+-----------------------------------
//! Destructor

inline RlinkCrc16::~RlinkCrc16()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCrc16::Clear()
{
  fCrc = 0;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCrc16::AddData(uint8_t data)
{
  uint8_t tmp = ((uint8_t)(fCrc>>8)) ^ data;
  fCrc = (fCrc<<8) ^ fCrc16Table[tmp];
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t RlinkCrc16::Crc() const
{
  return fCrc;
}

} // end namespace Retro
