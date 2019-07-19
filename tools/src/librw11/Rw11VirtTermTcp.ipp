// $Id: Rw11VirtTermTcp.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-04-20   508   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11VirtTermTcp.
*/

#include "Rw11VirtTermTcp.hpp"

/*!
  \class Retro::Rw11VirtTermTcp
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11VirtTermTcp::Connected() const
{
  return fFd > 2;
}

} // end namespace Retro
