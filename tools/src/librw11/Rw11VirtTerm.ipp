// $Id: Rw11VirtTerm.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-15  1083   1.0.1  SetupRcvCallback(): use rval ref and move semantics
// 2013-03-06   495   1.0    Initial version
// 2013-02-19   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11VirtTerm.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rw11VirtTerm::ChannelId() const
{
  return fChannelId;
}
  

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11VirtTerm::SetupRcvCallback(rcvcbfo_t&& rcvcbfo)
{
  fRcvCb = move(rcvcbfo);
  return;
}

} // end namespace Retro
