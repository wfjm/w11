// $Id: RlinkContext.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-03-16  1122   1.2    BUGFIX: use proper polarity of status mask
// 2015-03-28   660   1.1    add SetStatus(Value|Mask)()
// 2013-02-23   492   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of class RlinkContext.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkContext::SetStatus(uint8_t stat, uint8_t statmsk)
{
  fStatusVal = stat;
  fStatusMsk = statmsk;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkContext::SetStatusValue(uint8_t stat)
{
  fStatusVal = stat;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkContext::SetStatusMask(uint8_t statmsk)
{
  fStatusMsk = statmsk;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint8_t RlinkContext::StatusValue() const
{
  return fStatusVal;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint8_t RlinkContext::StatusMask() const
{
  return fStatusMsk;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkContext::StatusIsChecked() const
{
  return fStatusMsk != 0x00;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkContext::StatusCheck(uint8_t val) const
{
  return (val & fStatusMsk) == fStatusVal;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkContext::IncErrorCount(size_t inc)
{
  fErrCnt += inc;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkContext::ClearErrorCount()
{
  fErrCnt = 0;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkContext::ErrorCount() const
{
  return fErrCnt;
}

} // end namespace Retro
