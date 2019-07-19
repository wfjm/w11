// $Id: RlinkPacketBuf.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   2.0.1  Stats() not longer const
// 2014-11-15   604   2.0    re-organize for rlink v4
// 2011-04-02   375   1.0    Initial version
// 2011-03-05   366   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of class RlinkPacketBuf.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkPacketBuf::PktSize() const
{
  return fPktBuf.size();
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

inline Rstats& RlinkPacketBuf::Stats()
{
  return fStats;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBuf::ClearFlagBit(uint32_t mask)
{
  fFlags &= ~mask;
  return;
}

} // end namespace Retro
