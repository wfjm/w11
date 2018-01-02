// $Id: RlinkAddrMap.ipp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-03-05   366   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
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
