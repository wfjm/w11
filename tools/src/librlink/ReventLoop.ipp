// $Id: ReventLoop.ipp 513 2013-05-01 14:02:06Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-05-01   513   1.1.1  fTraceLevel now uint32_t
// 2013-02-22   491   1.1    use new RlogFile/RlogMsg interfaces
// 2013-01-11   473   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: ReventLoop.ipp 513 2013-05-01 14:02:06Z mueller $
  \brief   Implemenation (inline) of class ReventLoop.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void ReventLoop::Stop()
{
  fLoopActive = false;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void ReventLoop::SetLogFile(const boost::shared_ptr<RlogFile>& splog)
{
  fspLog = splog;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void ReventLoop::SetTraceLevel(uint32_t level)
{
  fTraceLevel = level;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t ReventLoop::TraceLevel() const
{
  return fTraceLevel;
}

} // end namespace Retro

