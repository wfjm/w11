// $Id: Rw11Probe.ipp 848 2017-02-04 14:55:30Z mueller $
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
// 2017-02-04   848   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11Probe.ipp 848 2017-02-04 14:55:30Z mueller $
  \brief   Implemenation (inline) of Rw11Probe.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11Probe::DataInt() const
{
  return fDataInt;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11Probe::DataRem() const
{
  return fDataRem;
}

} // end namespace Retro
