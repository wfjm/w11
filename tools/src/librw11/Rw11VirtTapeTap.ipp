// $Id: Rw11VirtTapeTap.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11VirtTapeTap.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11VirtTapeTap::BytePadding(size_t rlen)
{
  return fPadOdd ? ((rlen+1) & 0xfffe) : rlen;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11VirtTapeTap::SetBad()
{
  fBad = true;
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11VirtTapeTap::IncPosRecord(int delta)
{
  if (fPosRecord != -1) fPosRecord += delta;
  return;
}  


} // end namespace Retro
