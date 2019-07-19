// $Id: RlinkChannel.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-02-23   492   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of class RlinkChannel.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkConnect& RlinkChannel::Connect()
{
  return *fspConn;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkContext& RlinkChannel::Context()
{
  return fContext;
}

} // end namespace Retro
