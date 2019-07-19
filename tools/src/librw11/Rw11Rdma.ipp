// $Id: Rw11Rdma.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.0.1  Stats() not longer const
// 2015-01-04   627   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11Rdma.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11Cntl& Rw11Rdma::CntlBase() const
{
  return *fpCntlBase;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11Cpu& Rw11Rdma::Cpu() const
{
  return fpCntlBase->Cpu();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11& Rw11Rdma::W11() const
{
  return fpCntlBase->W11();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkServer& Rw11Rdma::Server() const
{
  return fpCntlBase->Server();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkConnect& Rw11Rdma::Connect() const
{
  return fpCntlBase->Connect();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlogFile& Rw11Rdma::LogFile() const
{
  return fpCntlBase->LogFile();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11Rdma::ChunkSize() const
{
  return fChunksize;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11Rdma::IsActive() const
{
  return fStatus != kStatusDone;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rstats& Rw11Rdma::Stats()
{
  return fStats;
}

} // end namespace Retro
