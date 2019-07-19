// $Id: RtimerFd.ipp 1185 2019-07-12 17:29:12Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-08  1161   1.1    derive from Rfd, inherit IsOpen,Close,Fd
// 2017-02-18   851   1.0    Initial version
// 2013-01-11   473   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of class RtimerFd.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RtimerFd::SetRelative(double dt)
{
  return SetRelative(Rtime(dt));
}

} // end namespace Retro


