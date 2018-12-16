// $Id: Rw11VirtTerm.ipp 1083 2018-12-15 19:19:16Z mueller $
//
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-15  1083   1.0.1  SetupRcvCallback(): use rval ref and move semantics
// 2013-03-06   495   1.0    Initial version
// 2013-02-19   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
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
