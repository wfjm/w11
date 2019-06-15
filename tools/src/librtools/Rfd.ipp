// $Id: Rfd.ipp 1161 2019-06-08 11:52:01Z mueller $
//
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-06-07  1161   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of class Rfd.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int Rfd::Fd() const
{
  return fFd;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rfd::IsOpen() const
{
  return fFd >= 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rfd::IsOpenNonStd() const
{
  return fFd > 2;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rfd::operator bool() const
{
  return IsOpen();
}

} // end namespace Retro


