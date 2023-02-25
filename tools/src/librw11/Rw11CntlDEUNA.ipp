// $Id: Rw11CntlDEUNA.ipp 1379 2023-02-24 09:17:23Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2023-02-21  1377   0.6    add EtherType filter
// 2017-02-25   856   0.5    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11CntlDEUNA.
*/

// all method definitions in namespace Retro
namespace Retro {

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline void Rw11CntlDEUNA::SetEtfEnable(bool etfena)
{
  fEtfEnable = etfena;
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline void Rw11CntlDEUNA::SetEtfTrace(bool etftra)
{
  fEtfTrace = etftra;
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline const Rtime& Rw11CntlDEUNA::RxPollTime() const
{
  return fRxPollTime;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline size_t Rw11CntlDEUNA::RxQueLimit() const
{
  return fRxQueLimit;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline bool Rw11CntlDEUNA::EtfEnable() const
{
  return fEtfEnable;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline bool Rw11CntlDEUNA::EtfTrace() const
{
  return fEtfTrace;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline float Rw11CntlDEUNA::TxLoss() const
{
  return fTxLoss;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline float Rw11CntlDEUNA::RxLoss() const
{
  return fRxLoss;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline bool Rw11CntlDEUNA::Running() const
{
  return fRunning;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline void Rw11CntlDEUNA::Wlist2UBAddr(const uint16_t wlist[2], uint32_t& addr)
{
  addr = uint32_t(wlist[0]) | uint32_t(wlist[1])<<16;
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline void Rw11CntlDEUNA::Wlist2UBAddrLen(const uint16_t wlist[2], 
                                           uint32_t& addr, uint16_t& len)
{
  addr = uint32_t(wlist[0]) | uint32_t(wlist[1] & 0xff)<<16;
  len  = (wlist[1]>>8) & 0xff;
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline void Rw11CntlDEUNA::UBAddrLen2Wlist(uint16_t wlist[2], 
                                           uint32_t addr, uint16_t len)
{
  wlist[0] = uint16_t(addr);
  wlist[1] = uint16_t(addr>>16) | ((len & 0xff)<<8);
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline uint16_t Rw11CntlDEUNA::RingIndexNext(uint16_t index, uint16_t size,
                                             uint16_t inc) const
{
  uint16_t next = index + inc;
  if (next >= size) next -= size;
  return next;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline uint16_t Rw11CntlDEUNA::TxRingIndexNext(uint16_t inc) const
{
  return RingIndexNext(fTxRingIndex, fTxRingSize, inc);
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline uint16_t Rw11CntlDEUNA::RxRingIndexNext(uint16_t inc) const
{
  return RingIndexNext(fRxRingIndex, fRxRingSize, inc);
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline uint32_t Rw11CntlDEUNA::RingDscAddr(uint32_t base, uint16_t elen, 
                                           uint16_t index) const
{
  return base + 2 * uint32_t(elen) * uint32_t(index);
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline uint32_t Rw11CntlDEUNA::TxRingDscAddr(uint16_t index) const
{
  return fTxRingBase + 2 * uint32_t(fTxRingELen) * uint32_t(index);
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline uint32_t Rw11CntlDEUNA::RxRingDscAddr(uint16_t index) const
{
  return fRxRingBase + 2 * uint32_t(fRxRingELen) * uint32_t(index);
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
inline void Rw11CntlDEUNA::SetRingDsc(uint16_t dst[4], const uint16_t src[4])
{
  dst[0] = src[0];
  dst[1] = src[1];
  dst[2] = src[2];
  dst[3] = src[3];
  return;
}

} // end namespace Retro
