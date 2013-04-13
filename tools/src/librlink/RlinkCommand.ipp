// $Id: RlinkCommand.ipp 495 2013-03-06 17:13:48Z mueller $
//
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-05-06   495   1.0.1  add RlinkContext to Print() args; drop oper<<()
// 2011-03-27   374   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkCommand.ipp 495 2013-03-06 17:13:48Z mueller $
  \brief   Implemenation (inline) of class RlinkCommand.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommand::CmdRreg(uint16_t addr)
{
  SetCommand(kCmdRreg, addr);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommand::CmdWreg(uint16_t addr, uint16_t data)
{
  SetCommand(kCmdWreg, addr, data);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommand::CmdStat()
{
  SetCommand(kCmdStat);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommand::CmdAttn()
{
  SetCommand(kCmdAttn);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommand::CmdInit(uint16_t addr, uint16_t data)
{
  SetCommand(kCmdInit, addr, data);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommand::SetSeqNumber(uint8_t snum)
{
  fRequest = (snum<<3) | (fRequest&0x07);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommand::SetData(uint16_t data)
{
  fData = data;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommand::SetStatRequest(uint8_t ccmd)
{
  fStatRequest = ccmd;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommand::SetStatus(uint8_t stat)
{
  fStatus = stat;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommand::SetFlagBit(uint32_t mask)
{
  fFlags |= mask;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommand::ClearFlagBit(uint32_t mask)
{
  fFlags &= ~mask;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommand::SetRcvSize(size_t rsize)
{
  fRcvSize = rsize;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint8_t RlinkCommand::Request() const
{
  return fRequest;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint8_t RlinkCommand::Command() const
{
  return fRequest & 0x07;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint8_t RlinkCommand::SeqNumber() const
{
  return fRequest>>3;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t RlinkCommand::Address() const
{
  return fAddress;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t RlinkCommand::Data() const
{
  return fData;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::vector<uint16_t>&  RlinkCommand::Block() const
{
  return fBlock;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkCommand::IsBlockExt() const
{
  return fpBlockExt != 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t* RlinkCommand::BlockPointer()
{
  return IsBlockExt() ? fpBlockExt : (fBlock.size() ? &fBlock[0] : 0);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const uint16_t* RlinkCommand::BlockPointer() const
{
  return IsBlockExt() ? fpBlockExt : (fBlock.size() ? &fBlock[0] : 0);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkCommand::BlockSize() const
{
  return IsBlockExt() ? fBlockExtSize : fBlock.size();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint8_t RlinkCommand::StatRequest() const
{
  return fStatRequest;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint8_t RlinkCommand::Status() const
{
  return fStatus;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t RlinkCommand::Flags() const
{
  return fFlags;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkCommand::TestFlagAny(uint32_t mask) const
{
  return (fFlags & mask) != 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkCommand::TestFlagAll(uint32_t mask) const
{
  return (fFlags & mask) == fFlags;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkCommand::RcvSize() const
{
  return fRcvSize;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RlinkCommandExpect* RlinkCommand::Expect() const
{
  return fpExpect;
}

} // end namespace Retro

