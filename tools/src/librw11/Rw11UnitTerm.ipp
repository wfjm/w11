// $Id: Rw11UnitTerm.ipp 504 2013-04-13 15:37:24Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-04-13   504   1.0    Initial version
// 2013-03-02   493   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitTerm.ipp 504 2013-04-13 15:37:24Z mueller $
  \brief   Implemenation (inline) of Rw11UnitTerm.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitTerm::SetRcv7bit(bool rcv7bit)
{
  fRcv7bit = rcv7bit;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitTerm::Rcv7bit() const
{
  return fRcv7bit;
}

} // end namespace Retro
