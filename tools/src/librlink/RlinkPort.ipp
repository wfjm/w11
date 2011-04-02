// $Id: RlinkPort.ipp 375 2011-04-02 07:56:47Z mueller $
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
// 2011-03-27   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPort.ipp 375 2011-04-02 07:56:47Z mueller $
  \brief   Implemenation (inline) of RlinkPort.
*/

// all method definitions in namespace Retro (avoid using in includes...)
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkPort::IsOpen() const
{
  return fIsOpen;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& RlinkPort::Url() const
{
  return fUrl;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& RlinkPort::UrlScheme() const
{
  return fScheme;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& RlinkPort::UrlPath() const
{
  return fPath;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const RlinkPort::omap_t& RlinkPort::UrlOpts() const
{
  return fOptMap;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int RlinkPort::FdRead() const
{
  return fFdRead;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int RlinkPort::FdWrite() const
{
  return fFdWrite;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPort::SetLogFile(RlogFile* log)
{
  fpLogFile = log;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPort::SetTraceLevel(size_t level)
{
  fTraceLevel = level;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkPort::TraceLevel() const
{
  return fTraceLevel;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rstats& RlinkPort::Stats() const
{
  return fStats;
}

} // end namespace Retro
