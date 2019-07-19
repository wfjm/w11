// $Id: RethTools.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-02-04   849   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11.
*/

// all method definitions in namespace Retro
namespace Retro {
namespace RethTools {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Mac2WList(uint64_t mac, uint16_t wlist[3])
{
  wlist[0] =  mac      & 0xffff;
  wlist[1] = (mac>>16) & 0xffff;
  wlist[2] = (mac>>32) & 0xffff;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint64_t WList2Mac(const uint16_t wlist[3])
{
  return  uint64_t(wlist[0])      |
         (uint64_t(wlist[1])<<16) |
         (uint64_t(wlist[2])<<32);
}

} // end namespace RethTools
} // end namespace Retro
