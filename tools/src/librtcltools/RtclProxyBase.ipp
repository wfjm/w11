// $Id: RtclProxyBase.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-02-08   484   1.0.1  add CommandName()
// 2011-02-20   363   1.0    Initial version
// 2011-02-13   361   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of RtclProxyBase.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& RtclProxyBase::Type() const
{
  return fType;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Tcl_Command RtclProxyBase::Token() const
{
  return fCmdToken;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RtclProxyBase::SetType(const std::string& type)
{
  fType = type;
  return;
}

} // end namespace Retro
