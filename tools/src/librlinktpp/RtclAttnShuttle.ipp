// $Id: RtclAttnShuttle.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-03-01   493   1.0    Initial version
// 2013-01-14   475   0.5    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of class RtclAttnShuttle.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t RtclAttnShuttle::Mask() const
{
  return fMask;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Tcl_Obj* RtclAttnShuttle::Script() const
{
  return fpScript;
}

} // end namespace Retro

