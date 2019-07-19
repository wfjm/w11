// $Id: Rw11Probe.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-02-04   848   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
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
