// $Id: RlinkPort.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.3.2  Stats() not longer const
// 2018-12-07  1078   1.3.1  use std::shared_ptr instead of boost
// 2015-04-11   666   1.3    add fXon, XonEnable()
// 2013-05-01   513   1.2.1  fTraceLevel now uint32_t
// 2013-02-23   492   1.2    use RparseUrl
// 2013-02-22   491   1.1    use new RlogFile/RlogMsg interfaces
// 2011-03-27   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of RlinkPort.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkPort::IsOpen() const
{
  return fIsOpen;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Retro::RparseUrl& RlinkPort::Url() const
{
  return fUrl;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkPort::XonEnable() const
{
  return fXon;
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

inline void RlinkPort::SetLogFile(const std::shared_ptr<RlogFile>& splog)
{
  fspLog = splog;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPort::SetTraceLevel(uint32_t level)
{
  fTraceLevel = level;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkPort::TraceLevel() const
{
  return fTraceLevel;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rstats& RlinkPort::Stats()
{
  return fStats;
}

} // end namespace Retro
