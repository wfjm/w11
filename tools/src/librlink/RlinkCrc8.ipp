// $Id: RlinkCrc8.ipp 365 2011-02-28 07:28:26Z mueller $
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
// 2011-02-27   365   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkCrc8.ipp 365 2011-02-28 07:28:26Z mueller $
  \brief   Implemenation (inline) of class RlinkCrc8.
*/

// all method definitions in namespace Retro (avoid using in includes...)
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

inline RlinkCrc8::RlinkCrc8()
  : fCrc(0)
{}

//------------------------------------------+-----------------------------------
//! Destructor

inline RlinkCrc8::~RlinkCrc8()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCrc8::Clear()
{
  fCrc = 0;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCrc8::AddData(uint8_t data)
{
  fCrc = fCrc8Table[fCrc ^ data];
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint8_t RlinkCrc8::Crc() const
{
  return fCrc;
}

} // end namespace Retro
