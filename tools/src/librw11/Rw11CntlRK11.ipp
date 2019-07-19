// $Id: Rw11CntlRK11.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.0.1  Stats() not longer const
// 2015-01-03   627   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11CntlRK11.
*/


// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11CntlRK11::SetChunkSize(size_t chunk)
{
  fRdma.SetChunkSize(chunk);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11CntlRK11::ChunkSize() const
{
  return fRdma.ChunkSize();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rstats& Rw11CntlRK11::RdmaStats()
{
  return fRdma.Stats();
}


} // end namespace Retro
