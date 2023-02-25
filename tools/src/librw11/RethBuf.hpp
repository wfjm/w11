// $Id: RethBuf.hpp 1379 2023-02-24 09:17:23Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2023-02-24  1379   1.1.1  add copy constructor
// 2023-02-22  1378   1.1    improved Info/Dump methods
// 2018-12-22  1091   1.0.1  Dump() not longer virtual (-Wnon-virtual-dtor fix)
// 2017-04-17   880   1.0    Initial version
// 2017-02-12   850   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RethBuf.
*/

#ifndef included_Retro_RethBuf
#define included_Retro_RethBuf 1

#include <memory>
#include <string>

#include "librtools/Rtime.hpp"

namespace Retro {

  class RethBuf {
    public:
      typedef std::shared_ptr<RethBuf> pbuf_t;
    
                    RethBuf();
                    RethBuf(const RethBuf& src);
                   ~RethBuf();
    
      void          Clear();
      void          SetSize(uint16_t size);
      void          SetTime();
      void          SetTime(const Rtime& time);

      uint16_t      Size() const;
      const Rtime&  Time() const;

      const uint8_t*  Buf8() const;
      const uint16_t* Buf16() const;

      uint8_t*      Buf8();
      uint16_t*     Buf16();

      uint8_t       GetB(size_t boff) const;
      uint16_t      GetS(size_t boff) const;
      uint32_t      GetL(size_t boff) const;

      void          SetMacDestination(uint64_t mac);
      void          SetMacSource(uint64_t mac);

      uint64_t      MacDestination() const;
      uint64_t      MacSource() const;
      uint16_t      EType() const;
      bool          IsMcast() const;
      bool          IsBcast() const;

      ssize_t       Read(int fd);
      ssize_t       Write(int fd) const;

      std::string   FrameInfo() const;
      std::string   HeaderInfo1() const;
      std::string   HeaderInfo2() const;
      std::string   HeaderInfoAll(bool ext, int ind=0) const;

      void          Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // some constants
      static const size_t   kMaxSize  = 1514;  //!< max ethernet frame size
      static const size_t   kMinSize  =   60;  //!< min ethernet frame size
      static const size_t   kCrcSize  =    4;  //!< size of ethernet CRC
      static const size_t   kEOffDstMac =  0;  //!< Eth frame: offset dst MAC
      static const size_t   kEOffSrcMac =  6;  //!< Eth frame: offset src MAC
      static const size_t   kEOffEType  = 12;  //!< Eth frame: offset EtherType
      static const size_t   kElength    = 14;  //!< Eth frame: length
      static const size_t   kArpOffOper =  6;  //!< ARP: offset OPER
      static const size_t   kArpOffSha  =  8;  //!< ARP: offset SHA
      static const size_t   kArpOffSpa  = 14;  //!< ARP: offset SPA
      static const size_t   kArpOffTha  = 18;  //!< ARP: offset THA
      static const size_t   kArpOffTpa  = 24;  //!< ARP: offset TPA
      static const size_t   kIpOffLen   =  2;  //!< IP4 hdr: offset tot length
      static const size_t   kIpOffFlags =  6;  //!< IP4 hdr: offset flags
      static const size_t   kIpOffTTL   =  8;  //!< IP4 hdr: offset TimeToLive
      static const size_t   kIpOffProt  =  9;  //!< IP4 hdr: offset protocol
      static const size_t   kIpOffSrcIP = 12;  //!< IP4 hdr: offset src IP
      static const size_t   kIpOffDstIP = 16;  //!< IP4 hdr: offset dst IP
      static const size_t   kImcpType      =  0;  //!< IMCP hdr: offset type
      static const size_t   kImcpCode      =  1;  //!< IMCP hdr: offset code
      static const size_t   kImcpEchoSN    =  6;  //!< IMCP hdr: echo seq number
      static const size_t   kTcpOffSrcPort =  0;  //!< TCP  hdr: offset src port
      static const size_t   kTcpOffDstPort =  2;  //!< TCP  hdr: offset dst port
      static const size_t   kTcpOffSeqNum  =  4;  //!< TCP  hdr: offset seq num
      static const size_t   kTcpOffAckNum  =  8;  //!< TCP  hdr: offset ack num
      static const size_t   kTcpOffDatOff  = 12;  //!< TCP  hdr: offset data off
      static const size_t   kTcpOffFlags   = 13;  //!< TCP  hdr: offset flags
      static const size_t   kUdpOffSrcPort =  0;  //!< UDP  hdr: offset src port
      static const size_t   kUdpOffDstPort =  2;  //!< UDP  hdr: offset dst port
      static const size_t   kUdpOffLen     =  4;  //!< UDP hdr: dgram length
      static const size_t   kETypeIPv4  = 0x0800; //!< EtherType IPv4
      static const size_t   kETypeARP   = 0x0806; //!< EtherType ARP
      static const size_t   kIpProtICMP =  1;  //!< IP protocol: ICMP
      static const size_t   kIpProtTCP  =  6;  //!< IP protocol: TCP
      static const size_t   kIpProtUDP  = 17;  //!< IP protocol: UDP

    protected:
      Rtime         fTime;
      uint16_t      fSize;
      uint8_t       fBuf[kMaxSize+kCrcSize];
  };

} // end namespace Retro

#include "RethBuf.ipp"

#endif
