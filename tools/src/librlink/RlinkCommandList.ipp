// $Id: RlinkCommandList.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2014-11-23   606   1.2    new rlink v4 iface
// 2013-05-06   495   1.0.1  add RlinkContext to Print() args; drop oper<<()
// 2011-03-05   366   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of class RlinkCommandList.
*/


// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommandList::SetLaboIndex(int ind)
{
  fLaboIndex = ind;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommandList::ClearLaboIndex()
{
  fLaboIndex = -1;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int RlinkCommandList::LaboIndex() const
{
  return fLaboIndex;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkCommandList::LaboActive() const
{
  return fLaboIndex >= 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkCommandList::Size() const
{
  return fList.size();
}

} // end namespace Retro
