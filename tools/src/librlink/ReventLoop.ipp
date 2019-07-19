// $Id: ReventLoop.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.2.1  use std::shared_ptr instead of boost
// 2015-04-04   662   1.2    BUGFIX: fix race in Stop(), add UnStop,StopPending
// 2013-05-01   513   1.1.1  fTraceLevel now uint32_t
// 2013-02-22   491   1.1    use new RlogFile/RlogMsg interfaces
// 2013-01-11   473   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of class ReventLoop.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void ReventLoop::Stop()
{
  fStopPending = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void ReventLoop::UnStop()
{
  fStopPending = false;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool ReventLoop::StopPending()
{
  return fStopPending;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void ReventLoop::SetLogFile(const std::shared_ptr<RlogFile>& splog)
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

