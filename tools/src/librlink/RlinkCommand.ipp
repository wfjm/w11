// $Id: RlinkCommand.ipp 375 2011-04-02 07:56:47Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-03-27   374   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkCommand.ipp 375 2011-04-02 07:56:47Z mueller $
  \brief   Implemenation (inline) of class RlinkCommand.
*/

// all method definitions in namespace Retro (avoid using in includes...)
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommand::CmdRreg(uint16_t addr)
{
  SetCommand(kCmdRreg, addr);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommand::CmdWreg(uint16_t addr, uint16_t data)
{
  SetCommand(kCmdWreg, addr, data);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommand::CmdStat()
{
  SetCommand(kCmdStat);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommand::CmdAttn()
{
  SetCommand(kCmdAttn);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommand::CmdInit(uint16_t addr, uint16_t data)
{
  SetCommand(kCmdInit, addr, data);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommand::SetSeqNumber(uint8_t snum)
{
  fRequest = (snum<<3) | (fRequest&0x07);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommand::SetData(uint16_t data)
{
  fData = data;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommand::SetStatRequest(uint8_t ccmd)
{
  fStatRequest = ccmd;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommand::SetStatus(uint8_t stat)
{
  fStatus = stat;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommand::SetFlagBit(uint32_t mask)
{
  fFlags |= mask;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommand::ClearFlagBit(uint32_t mask)
{
  fFlags &= ~mask;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommand::SetRcvSize(size_t rsize)
{
  fRcvSize = rsize;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline uint8_t RlinkCommand::Request() const
{
  return fRequest;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline uint8_t RlinkCommand::Command() const
{
  return fRequest & 0x07;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline uint8_t RlinkCommand::SeqNumber() const
{
  return fRequest>>3;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline uint16_t RlinkCommand::Address() const
{
  return fAddress;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline uint16_t RlinkCommand::Data() const
{
  return fData;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline const std::vector<uint16_t>&  RlinkCommand::Block() const
{
  return fBlock;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline bool RlinkCommand::IsBlockExt() const
{
  return fpBlockExt != 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline uint16_t* RlinkCommand::BlockPointer()
{
  return IsBlockExt() ? fpBlockExt : (fBlock.size() ? &fBlock[0] : 0);
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline const uint16_t* RlinkCommand::BlockPointer() const
{
  return IsBlockExt() ? fpBlockExt : (fBlock.size() ? &fBlock[0] : 0);
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline size_t RlinkCommand::BlockSize() const
{
  return IsBlockExt() ? fBlockExtSize : fBlock.size();
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline uint8_t RlinkCommand::StatRequest() const
{
  return fStatRequest;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline uint8_t RlinkCommand::Status() const
{
  return fStatus;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline uint32_t RlinkCommand::Flags() const
{
  return fFlags;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline bool RlinkCommand::TestFlagAny(uint32_t mask) const
{
  return (fFlags & mask) != 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline bool RlinkCommand::TestFlagAll(uint32_t mask) const
{
  return (fFlags & mask) == fFlags;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline size_t RlinkCommand::RcvSize() const
{
  return fRcvSize;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline RlinkCommandExpect* RlinkCommand::Expect() const
{
  return fpExpect;
}

//------------------------------------------+-----------------------------------
/*! 
  \relates RlinkCommand
  \brief ostream insertion operator.
*/

inline std::ostream& operator<<(std::ostream& os, const RlinkCommand& obj)
{
  obj.Print(os);
  return os;
}

} // end namespace Retro

