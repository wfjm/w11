// $Id: Rw11VirtEth.ipp 847 2017-01-29 22:38:42Z mueller $
//
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-01-29   847   1.0    Initial version
// 2014-06-09   561   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtEth.ipp 847 2017-01-29 22:38:42Z mueller $
  \brief   Implemenation (inline) of Rw11VirtEth.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rw11VirtEth::ChannelId() const
{
  return fChannelId;
}
  

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11VirtEth::SetupRcvCallback(const rcvcbfo_t& rcvcbfo)
{
  fRcvCb = rcvcbfo;
  return;
}

} // end namespace Retro
