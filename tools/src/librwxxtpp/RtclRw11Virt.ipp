// $Id: RtclRw11Virt.ipp 859 2017-03-11 22:36:45Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-03-11   859   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11Virt.ipp 859 2017-03-11 22:36:45Z mueller $
  \brief   Implemenation (inline) of RtclRw11Virt.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11Virt* RtclRw11Virt::Virt() const
{
  return fpVirt;
}

} // end namespace Retro
