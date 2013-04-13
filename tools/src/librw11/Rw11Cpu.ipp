// $Id: Rw11Cpu.ipp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-04-12   504   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11Cpu.ipp 502 2013-04-02 19:29:30Z mu./librwxxtpp/Rwxxtpp_Init.cpp
eller $
  \brief   Implemenation (inline) of Rw11Cpu.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11& Rw11Cpu::W11() const
{
  return *fpW11;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkServer& Rw11Cpu::Server() const
{
  return fpW11->Server();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkConnect& Rw11Cpu::Connect() const
{
  return fpW11->Connect();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlogFile& Rw11Cpu::LogFile() const
{
  return fpW11->LogFile();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rw11Cpu::Type() const
{
  return fType;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11Cpu::Index() const
{
  return fIndex;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11Cpu::Base() const
{
  return fBase;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11Cpu::CpuStat() const
{
  return fCpuStat;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11Cpu::CpuGo() const
{
  return fCpuGo;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rstats& Rw11Cpu::Stats() const
{
  return fStats;
}

} // end namespace Retro
