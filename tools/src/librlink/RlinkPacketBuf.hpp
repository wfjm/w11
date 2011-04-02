// $Id: RlinkPacketBuf.hpp 375 2011-04-02 07:56:47Z mueller $
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
// 2011-04-02   375   1.0    Initial version
// 2011-03-05   366   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkPacketBuf.hpp 375 2011-04-02 07:56:47Z mueller $
  \brief   Declaration of class RlinkPacketBuf.
*/

#ifndef included_Retro_RlinkPacketBuf
#define included_Retro_RlinkPacketBuf 1

#include <cstdint>
#include <vector>

#include "RlinkPort.hpp"
#include "RlinkCrc8.hpp"

namespace Retro {

  class RlinkPacketBuf {
    public:

                    RlinkPacketBuf();
                    ~RlinkPacketBuf();

      void          Init();

      void          PutWithCrc(uint8_t data);
      void          PutWithCrc(uint16_t data);
      void          PutCrc();

      bool          SndPacket(RlinkPort* port, RerrMsg& emsg);
      bool          RcvPacket(RlinkPort* port, size_t nrcv, float timeout, 
                              RerrMsg& emsg);

      double        WaitAttn(RlinkPort* port, double timeout, RerrMsg& emsg);
      bool          SndOob(RlinkPort* port, uint16_t addr, uint16_t data, 
                           RerrMsg& emsg);
      bool          SndKeep(RlinkPort* port, RerrMsg& emsg);
    
      bool          CheckSize(size_t nbyte) const;
      uint8_t       Get8WithCrc();
      uint16_t      Get16WithCrc();
      bool          CheckCrc();

      size_t        PktSize() const;
      size_t        RawSize() const;

      uint32_t      Flags() const;
      bool          TestFlag(uint32_t mask) const;
      size_t        Nesc() const;
      size_t        Nattn() const;
      size_t        Nidle() const;
      size_t        Ndrop() const;

      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // flag bits
      static const uint32_t kFlagSopSeen  = 1<<0;  //!< sop was seen
      static const uint32_t kFlagEopSeen  = 1<<1;  //!< eop was seen
      static const uint32_t kFlagNakSeen  = 1<<2;  //!< nak was seen
      static const uint32_t kFlagAttnSeen = 1<<3;  //!< attn was seen
      static const uint32_t kFlagTout     = 1<<16; //!< timeout on read
      static const uint32_t kFlagDatDrop  = 1<<17; //!< data before sop dropped
      static const uint32_t kFlagDatMiss  = 1<<18; //!< eop before expected data

    // some constants
      static const uint8_t kCPREF = 0x80;   //!< VHDL def for comma prefix
      static const uint8_t kNCOMM = 0x04;   //!< VHDL def for number of commas
      static const uint8_t kCommaIdle = kCPREF+0; //!< IDLE comma
      static const uint8_t kCommaSop  = kCPREF+1; //!< SOP comma
      static const uint8_t kCommaEop  = kCPREF+2; //!< EOP comma
      static const uint8_t kCommaNak  = kCPREF+3; //!< NAK comma
      static const uint8_t kCommaAttn = kCPREF+4; //!< ATTN comma
      static const uint8_t kSymEsc    = kCPREF+0x0f;  //!< ESC symbol

    protected:
      bool          SndRaw(RlinkPort* port, RerrMsg& emsg);
      int           RcvRaw(RlinkPort* port, size_t size, float timeout, 
                           RerrMsg& emsg);

      void          SetFlagBit(uint32_t mask);
      void          ClearFlagBit(uint32_t mask);

    protected: 
      std::vector<uint8_t> fPktBuf;         //!< packet buffer
      std::vector<uint8_t> fRawBuf;         //!< raw data buffer
      size_t        fRawBufSize;            //!< # of valid bytes in RawBuf
      RlinkCrc8     fCrc;                   //!< crc accumulator
      uint32_t      fFlags;                 //!< request/response flags
      size_t        fNdone;                 //!< number of input bytes processed
      size_t        fNesc;                  //!< number of escapes handled
      size_t        fNattn;                 //!< number of ATTN commas seen
      size_t        fNidle;                 //!< number of IDLE commas seen
      size_t        fNdrop;                 //!< number of dropped input bytes
  };
  
} // end namespace Retro

#if !(defined(Retro_NoInline) || defined(Retro_RlinkPacketBuf_NoInline))
#include "RlinkPacketBuf.ipp"
#endif

#endif
