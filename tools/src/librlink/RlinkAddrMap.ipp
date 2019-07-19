// $Id: RlinkAddrMap.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-03-05   366   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of class RlinkAddrMap.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const RlinkAddrMap::nmap_t& RlinkAddrMap::Nmap() const
{
  return fNameMap;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const RlinkAddrMap::amap_t& RlinkAddrMap::Amap() const
{
  return fAddrMap;
}

} // end namespace Retro
