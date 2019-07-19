// $Id: Rw11Cntl.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.1.1  Stats() not longer const
// 2017-02-04   848   1.1    add ProbeFound(),ProbeDataInt,Rem()
// 2013-03-06   495   1.0    Initial version
// 2013-02-05   483   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11Cntl.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11Cntl::SetCpu(Rw11Cpu* pcpu)
{
  fpCpu = pcpu;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11Cpu& Rw11Cntl::Cpu() const
{
  return *fpCpu;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11& Rw11Cntl::W11() const
{
  return fpCpu->W11();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkServer& Rw11Cntl::Server() const
{
  return fpCpu->Server();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkConnect& Rw11Cntl::Connect() const
{
  return fpCpu->Connect();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlogFile& Rw11Cntl::LogFile() const
{
  return fpCpu->LogFile();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rw11Cntl::Type() const
{
  return fType;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rw11Cntl::Name() const
{
  return fName;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11Cntl::Base() const
{
  return fBase;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int Rw11Cntl::Lam() const
{
  return fLam;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11Cntl::Enable() const
{
  return fEnable;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11Cntl::ProbeFound() const
{
  return fProbe.Found();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11Cntl::ProbeDataInt() const
{
  return fProbe.DataInt();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11Cntl::ProbeDataRem() const
{
  return fProbe.DataRem();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rw11Probe& Rw11Cntl::ProbeStatus() const
{
  return fProbe;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11Cntl::IsStarted() const
{
  return fStarted;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11Cntl::SetTraceLevel(uint32_t level)
{
  fTraceLevel = level;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t Rw11Cntl::TraceLevel() const
{
  return fTraceLevel;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rstats& Rw11Cntl::Stats()
{
  return fStats;
}

} // end namespace Retro
