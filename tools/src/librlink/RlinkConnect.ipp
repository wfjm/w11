// $Id: RlinkConnect.ipp 375 2011-04-02 07:56:47Z mueller $
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
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkConnect.ipp 375 2011-04-02 07:56:47Z mueller $
  \brief   Implemenation (inline) of RlinkConnect.
*/

// all method definitions in namespace Retro (avoid using in includes...)
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::IsOpen() const
{
  return fpPort && fpPort->IsOpen();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkPort* RlinkConnect::Port() const
{
  return fpPort;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::AddrMapInsert(const std::string& name, uint16_t addr)
{
  return fAddrMap.Insert(name, addr);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::AddrMapErase(const std::string& name)
{
  return fAddrMap.Erase(name);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::AddrMapErase(uint16_t addr)
{
  return fAddrMap.Erase(addr);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkConnect::AddrMapClear()
{
  return fAddrMap.Clear();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const RlinkAddrMap& RlinkConnect::AddrMap() const
{
  return fAddrMap;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rstats& RlinkConnect::Stats() const
{
  return fStats;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const RlinkConnect::LogOpts& RlinkConnect::GetLogOpts() const
{
  return fLogOpts;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlogFile& RlinkConnect::LogFile() const
{
  return (RlogFile&)fLogFile;
}


} // end namespace Retro
