// $Id: RtclProxyBase.ipp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-02-08   484   1.0.1  add CommandName()
// 2011-02-20   363   1.0    Initial version
// 2011-02-13   361   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
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
