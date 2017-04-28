// $Id: RtimerFd.ipp 887 2017-04-28 19:32:52Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-02-18   851   1.0    Initial version
// 2013-01-11   473   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (inline) of class RtimerFd.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RtimerFd::IsOpen() const
{
  return fFd >= 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RtimerFd::SetRelative(double dt)
{
  return SetRelative(Rtime(dt));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int RtimerFd::Fd() const
{
  return fFd;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RtimerFd::operator bool() const
{
  return IsOpen();
}

} // end namespace Retro


