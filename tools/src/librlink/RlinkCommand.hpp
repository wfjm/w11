// $Id: RlinkCommand.hpp 495 2013-03-06 17:13:48Z mueller $
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
// 2011-01-09   354   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkCommand.hpp 495 2013-03-06 17:13:48Z mueller $
  \brief   Declaration of class RlinkCommand.
*/

#ifndef included_Retro_RlinkCommand
#define included_Retro_RlinkCommand 1

#include <cstddef>
#include <cstdint>
#include <vector>
#include <ostream>

#include "librtools/Rtools.hpp"

#include "RlinkContext.hpp"
#include "RlinkAddrMap.hpp"
#include "RlinkCommandExpect.hpp"

#include "librtools/Rbits.hpp"

namespace Retro {

  class RlinkCommand : public Rbits {
    public:
                    RlinkCommand();
                    RlinkCommand(const RlinkCommand& rhs);
                    ~RlinkCommand();
 
      void          CmdRreg(uint16_t addr);
      void          CmdRblk(uint16_t addr, size_t size);
      void          CmdRblk(uint16_t addr, uint16_t* pblock, size_t size);
      void          CmdWreg(uint16_t addr, uint16_t data);
      void          CmdWblk(uint16_t addr, const std::vector<uint16_t>& block);
      void          CmdWblk(uint16_t addr, const uint16_t* pblock, size_t size);
      void          CmdStat();
      void          CmdAttn();
      void          CmdInit(uint16_t addr, uint16_t data);

      void          SetCommand(uint8_t cmd, uint16_t addr=0, uint16_t data=0);
      void          SetSeqNumber(uint8_t snum);   
      void          SetAddress(uint16_t addr);
      void          SetData(uint16_t data);
      void          SetBlockWrite(const std::vector<uint16_t>& block);
      void          SetBlockRead(size_t size) ;
      void          SetBlockExt(uint16_t* pblock, size_t size);
      void          SetStatRequest(uint8_t ccmd);
      void          SetStatus(uint8_t stat);
      void          SetFlagBit(uint32_t mask);
      void          ClearFlagBit(uint32_t mask);
      void          SetRcvSize(size_t rsize);
      void          SetExpect(RlinkCommandExpect* pexp);

      uint8_t       Request() const;
      uint8_t       Command() const;
      uint8_t       SeqNumber() const;
      uint16_t      Address() const;
      uint16_t      Data() const;
      const std::vector<uint16_t>& Block() const;
      bool          IsBlockExt() const;
      uint16_t*        BlockPointer();
      const uint16_t*  BlockPointer() const;
      size_t        BlockSize() const;
      uint8_t       StatRequest() const;
      uint8_t       Status() const;
      uint32_t      Flags() const;
      bool          TestFlagAny(uint32_t mask) const;
      bool          TestFlagAll(uint32_t mask) const;
      size_t        RcvSize() const;
      RlinkCommandExpect* Expect() const;

      void          Print(std::ostream& os, const RlinkContext& cntx,
                          const RlinkAddrMap* pamap=0, size_t abase=16, 
                          size_t dbase=16, size_t sbase=16) const;
      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;

      static const char* CommandName(uint8_t cmd);
      static const RflagName* FlagNames();

      RlinkCommand& operator=(const RlinkCommand& rhs);

    // some constants (also defined in cpp)
      static const uint8_t  kCmdRreg = 0;   //!< command code read register
      static const uint8_t  kCmdRblk = 1;   //!< command code read block
      static const uint8_t  kCmdWreg = 2;   //!< command code write register
      static const uint8_t  kCmdWblk = 3;   //!< command code write block
      static const uint8_t  kCmdStat = 4;   //!< command code get status
      static const uint8_t  kCmdAttn = 5;   //!< command code get attention
      static const uint8_t  kCmdInit = 6;   //!< command code send initialize

      static const uint32_t kFlagInit   = 1u<<0;  //!< cmd,addr,data setup
      static const uint32_t kFlagSend   = 1u<<1;  //!< command send
      static const uint32_t kFlagDone   = 1u<<2;  //!< command done

      static const uint32_t kFlagPktBeg = 1u<<4;  //!< command first in packet
      static const uint32_t kFlagPktEnd = 1u<<5;  //!< command last in packet
      static const uint32_t kFlagRecov  = 1u<<6;  //!< command stat recovered
      static const uint32_t kFlagResend = 1u<<7;  //!< command resend recovered

      static const uint32_t kFlagErrNak = 1u<<8;  //!< error: nak abort
      static const uint32_t kFlagErrMiss= 1u<<9;  //!< error: missing data
      static const uint32_t kFlagErrCmd = 1u<<10; //!< error: cmd or nblk check
      static const uint32_t kFlagErrCrc = 1u<<11; //!< error: crc check

      static const uint32_t kFlagChkStat= 1u<<12; //!< stat expect check failed
      static const uint32_t kFlagChkData= 1u<<13; //!< data expect check failed

      static const uint32_t kFlagVol    = 1u<<16; //!< volatile

      static const uint8_t  kStat_M_Stat  = 0xe0; //!< stat: external stat bits
      static const uint8_t  kStat_V_Stat  = 5; 
      static const uint8_t  kStat_B_Stat  = 0x07; 
      static const uint8_t  kStat_M_Attn  = kBBit04;//!< stat: attn flags set
      static const uint8_t  kStat_M_Cerr  = kBBit03;//!< stat: attn flags set
      static const uint8_t  kStat_M_Derr  = kBBit02;//!< stat: attn flags set
      static const uint8_t  kStat_M_RbNak = kBBit01;//!< stat: attn flags set
      static const uint8_t  kStat_M_RbErr = kBBit00;//!< stat: attn flags set

      static const uint16_t kRbaddr_IInt  = 0xff;   //!< iint: rbus address
      static const uint16_t kIInt_M_AnEna = kWBit15;//!< iint: attn notify
      static const uint16_t kIInt_M_ItoEna= kWBit14;//!< iint: attn/idle timeout
      static const uint16_t kIInt_M_ItoVal= 0x00ff; //!< iint: attn/idle timeout

    protected: 
      void          SetCmdSimple(uint8_t cmd, uint16_t addr, uint16_t data);

    protected: 
      uint8_t       fRequest;               //!< rlink request (cmd+seqnum)
      uint16_t      fAddress;               //!< rbus address
      uint16_t      fData;                  //!< data 
      std::vector<uint16_t> fBlock;         //!< data vector for blk commands 
      uint16_t*     fpBlockExt;             //!< external data for blk commands
      size_t        fBlockExtSize;          //!< transfer size if data external
      uint8_t       fStatRequest;           //!< stat command ccmd return field
      uint8_t       fStatus;                //!< rlink command status
      uint32_t      fFlags;                 //!< state bits
      size_t        fRcvSize;               //!< receive size for command
      RlinkCommandExpect* fpExpect;         //!< pointer to expect container
  };
  
} // end namespace Retro

#include "RlinkCommand.ipp"

#endif
