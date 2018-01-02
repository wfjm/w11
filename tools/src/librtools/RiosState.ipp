// $Id: RiosState.ipp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2006-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-01-30   357   1.0    Adopted from CTBioState
// 2006-04-16     -   -      Last change on CTBioState
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (inline) of RiosState.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Get conversion type.

inline char RiosState::Ctype()
{
  return fCtype;
}

} // end namespace Retro
