// $Id: Rw11CntlTM11.ipp 1183 2019-07-10 18:48:41Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.0.1  RdmaStats() not longer const
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11CntlTM11.
*/


// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11CntlTM11::SetChunkSize(size_t chunk)
{
  fRdma.SetChunkSize(chunk);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11CntlTM11::ChunkSize() const
{
  return fRdma.ChunkSize();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rstats& Rw11CntlTM11::RdmaStats()
{
  return fRdma.Stats();
}


} // end namespace Retro
