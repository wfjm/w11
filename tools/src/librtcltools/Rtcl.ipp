// $Id: Rtcl.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-02-26   364   1.0    Initial version
// 2011-02-18   362   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rtcl.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Tcl_Obj* Rtcl::NewLinesObj(std::ostringstream& sos)
{
  return NewLinesObj(sos.str());
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rtcl::SetResult(Tcl_Interp* interp, std::ostringstream& sos)
{
  SetResult(interp, sos.str());
  return;
}


} // end namespace Retro
