// $Id: RiosState.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2006-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-01-30   357   1.0    Adopted from CTBioState
// 2006-04-16     -   -      Last change on CTBioState
// ---------------------------------------------------------------------------

/*!
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
