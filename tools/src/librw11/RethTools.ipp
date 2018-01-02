// $Id: RethTools.ipp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-02-04   849   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
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
