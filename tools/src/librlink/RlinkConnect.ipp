// $Id: RlinkConnect.ipp 1079 2018-12-09 10:56:59Z mueller $
//
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-08  1079   2.7    add HasPort; return ref for Port()
// 2018-12-07  1078   2.6.1  use std::shared_ptr instead of boost
// 2018-12-01  1076   2.6    use unique_ptr instead of scoped_ptr
// 2017-04-22   883   2.5.2  add rbus monitor probe, add HasRbmon()
// 2017-04-09   871   2.5.1  LogFileName(): returns now const std::string&
// 2017-02-20   854   2.5    use Rtime, drop TimeOfDayAsDouble
// 2016-04-02   758   2.4    add USR_ACCESS register support (RLUA0/RLUA1)
// 2016-03-20   748   2.3    add fTimeout,(Set)Timeout();
// 2015-04-12   666   2.2    add LinkInit,LinkInitDone; transfer xon
// 2015-01-06   631   2.1    full rlink v4 implementation
// 2013-03-05   495   1.2.1  add Exec() without emsg (will send emsg to LogFile)
// 2013-02-23   492   1.2    use scoped_ptr for Port; Close allways allowed
//                           use RlinkContext, add Context(), Exec(..., cntx)
// 2013-02-22   491   1.1    use new RlogFile/RlogMsg interfaces
// 2013-02-03   481   1.0.1  add SetServer(),Server()
// 2011-04-02   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (inline) of RlinkConnect.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::IsOpen() const
{
  return fupPort && fupPort->IsOpen();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::HasPort() const
{
  return bool(fupPort);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkPort& RlinkConnect::Port()
{
  return *fupPort;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const RlinkPort& RlinkConnect::Port() const
{
  return *fupPort;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::LinkInitDone() const
{
  return fLinkInitDone;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkContext& RlinkConnect::Context()
{
  return fContext;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkConnect::SetServer(RlinkServer* pserv)
{
  fpServ = pserv;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkServer* RlinkConnect::Server() const
{
  return fpServ;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
inline bool RlinkConnect::Exec(RlinkCommandList& clist, RerrMsg& emsg)
{
  return Exec(clist, fContext, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
inline void RlinkConnect::Exec(RlinkCommandList& clist)
{
  Exec(clist, fContext);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
inline uint32_t RlinkConnect::SysId() const
{
  return fSysId;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
inline uint32_t RlinkConnect::UsrAcc() const
{
  return fUsrAcc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
inline size_t RlinkConnect::RbufSize() const
{
  return fRbufSize;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
inline size_t RlinkConnect::BlockSizeMax() const
{
  return (fRbufSize-kRbufBlkDelta)/2;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
inline size_t RlinkConnect::BlockSizePrudent() const
{
  return (fRbufSize-kRbufPrudentDelta)/2;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
inline bool RlinkConnect::HasRbmon() const
{
  return fHasRbmon;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::AddrMapInsert(const std::string& name, uint16_t addr)
{
  return fAddrMap.Insert(name, addr);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::AddrMapErase(const std::string& name)
{
  return fAddrMap.Erase(name);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkConnect::AddrMapErase(uint16_t addr)
{
  return fAddrMap.Erase(addr);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkConnect::AddrMapClear()
{
  return fAddrMap.Clear();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const RlinkAddrMap& RlinkConnect::AddrMap() const
{
  return fAddrMap;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rstats& RlinkConnect::Stats() const
{
  return fStats;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rstats& RlinkConnect::SndStats() const
{
  return fSndPkt.Stats();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rstats& RlinkConnect::RcvStats() const
{
  return fRcvPkt.Stats();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkConnect::LogBaseAddr() const
{
  return fLogBaseAddr;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkConnect::LogBaseData() const
{
  return fLogBaseData;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkConnect::LogBaseStat() const
{
  return fLogBaseStat;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkConnect::PrintLevel() const
{
  return fPrintLevel;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkConnect::DumpLevel() const
{
  return fDumpLevel;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkConnect::TraceLevel() const
{
  return fTraceLevel;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const Rtime& RlinkConnect::Timeout() const
{
  return fTimeout;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlogFile& RlinkConnect::LogFile() const
{
  return *fspLog;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::shared_ptr<RlogFile>& RlinkConnect::LogFileSPtr() const
{
  return fspLog;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& RlinkConnect::LogFileName() const
{
  return LogFile().Name();
}


} // end namespace Retro
