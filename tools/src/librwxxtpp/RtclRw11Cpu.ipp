// $Id: RtclRw11Cpu.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-04-02   502   1.0    Initial version
// 2013-02-02   480   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of RtclRw11Cpu.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkServer& RtclRw11Cpu::Server() 
{
  return Obj().Server();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkConnect& RtclRw11Cpu::Connect() 
{
  return Obj().Connect();
}

} // end namespace Retro
