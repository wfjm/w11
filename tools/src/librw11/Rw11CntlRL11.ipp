// $Id: Rw11CntlRL11.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.0.1  RdmaStats() not longer const
// 2015-01-10   632   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11CntlRL11.
*/


// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11CntlRL11::SetChunkSize(size_t chunk)
{
  fRdma.SetChunkSize(chunk);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11CntlRL11::ChunkSize() const
{
  return fRdma.ChunkSize();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rstats& Rw11CntlRL11::RdmaStats()
{
  return fRdma.Stats();
}


} // end namespace Retro
