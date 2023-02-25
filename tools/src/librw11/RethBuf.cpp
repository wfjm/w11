// $Id: RethBuf.cpp 1379 2023-02-24 09:17:23Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2023-02-24  1379   1.1.1  add copy constructor
// 2023-02-22  1378   1.1    improved Info/Dump methods
// 2017-04-16   880   1.0    Initial version
// 2017-02-12   850   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RethBuf.
*/

#include <stdlib.h>
#include <unistd.h>

#include <arpa/inet.h>

#include <sstream>
#include <cstring>

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"

#include "RethBuf.hpp"
#include "RethTools.hpp"

using namespace std;

/*!
  \class Retro::RethBuf
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions
const size_t RethBuf::kMaxSize;
const size_t RethBuf::kMinSize;
const size_t RethBuf::kCrcSize;
const size_t RethBuf::kEOffDstMac;
const size_t RethBuf::kEOffSrcMac;
const size_t RethBuf::kEOffEType;
const size_t RethBuf::kElength;
const size_t RethBuf::kArpOffOper;
const size_t RethBuf::kArpOffSha;
const size_t RethBuf::kArpOffSpa;
const size_t RethBuf::kArpOffTha;
const size_t RethBuf::kArpOffTpa;
const size_t RethBuf::kIpOffLen;
const size_t RethBuf::kIpOffFlags;
const size_t RethBuf::kIpOffTTL;
const size_t RethBuf::kIpOffProt;
const size_t RethBuf::kIpOffSrcIP;
const size_t RethBuf::kIpOffDstIP;
const size_t RethBuf::kImcpType;
const size_t RethBuf::kImcpCode;
const size_t RethBuf::kImcpEchoSN;
const size_t RethBuf::kTcpOffSrcPort;
const size_t RethBuf::kTcpOffDstPort;
const size_t RethBuf::kTcpOffSeqNum;
const size_t RethBuf::kTcpOffAckNum;
const size_t RethBuf::kTcpOffDatOff;
const size_t RethBuf::kTcpOffFlags;
const size_t RethBuf::kUdpOffSrcPort;
const size_t RethBuf::kUdpOffDstPort;
const size_t RethBuf::kUdpOffLen;
const size_t RethBuf::kETypeIPv4;
const size_t RethBuf::kETypeARP;
const size_t RethBuf::kIpProtICMP;
const size_t RethBuf::kIpProtTCP;
const size_t RethBuf::kIpProtUDP;

//------------------------------------------+-----------------------------------
//! Default constructor
RethBuf::RethBuf()
  : fTime(),
    fSize(0)
{}

//------------------------------------------+-----------------------------------
//! Copy constructor
RethBuf::RethBuf(const RethBuf& src)
  : fTime(src.fTime),
    fSize(src.fSize)
{
  memcpy(fBuf, src.fBuf, src.fSize);
}

//------------------------------------------+-----------------------------------
//! Destructor
RethBuf::~RethBuf()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

uint8_t RethBuf::GetB(size_t boff) const
{
  return fBuf[boff];
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

uint16_t RethBuf::GetS(size_t boff) const
{
  uint8_t*  pdatb = const_cast<uint8_t*>(fBuf+boff);
  uint16_t* pdats = reinterpret_cast<uint16_t*>(pdatb);
  return ntohs(*pdats);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

uint32_t RethBuf::GetL(size_t boff) const
{
  uint8_t*  pdatb = const_cast<uint8_t*>(fBuf+boff);
  uint32_t* pdatl = reinterpret_cast<uint32_t*>(pdatb);
  return ntohl(*pdatl);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

uint16_t RethBuf::EType() const
{
  return ntohs(Buf16()[kEOffEType/2]);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

ssize_t RethBuf::Read(int fd)
{
  ssize_t irc = ::read(fd, fBuf, kMaxSize);
  fSize = (irc > 0) ? irc : 0;
  return irc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

ssize_t RethBuf::Write(int fd) const
{
  return ::write(fd, fBuf, fSize);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string RethBuf::FrameInfo() const
{
  auto etype = EType();
  ostringstream sos;
  sos << RethTools::Mac2String(MacSource())
      << " > " << RethTools::Mac2String(MacDestination())
      << " typ: " << RosPrintBvi(etype,16);
  if (etype == kETypeIPv4) {
    sos << "/" << RosPrintf(Buf8()[kElength+kIpOffProt],"d",3);
  }
  sos << " siz: " << RosPrintf(Size(),"d",4);
  return sos.str();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string RethBuf::HeaderInfo1() const
{
  auto etype = EType();
  if (etype != kETypeARP && etype != kETypeIPv4) string("");

  ostringstream sos;
  if (etype == kETypeARP) {
    auto oper = GetS(kElength+kArpOffOper);
    auto sha  = RethTools::WList2Mac(Buf16()+(kElength+kArpOffSha)/2);
    sos << "ARP: "
        << (oper==1 ? "req" : "res")
        << " sha: " << RethTools::Mac2String(sha);
    if (oper == 1) {
      sos << " tpa: " << RethTools::IpAddr2String(Buf8()+kElength+kArpOffTpa);
    } else {
      sos << " spa: " << RethTools::IpAddr2String(Buf8()+kElength+kArpOffSpa);
    }

  } else if (etype == kETypeIPv4) {
    auto prot  = GetB(kElength+kIpOffProt);
    auto tlen  = GetS(kElength+kIpOffLen);
    auto flags = GetB(kElength+kIpOffFlags);
    auto ipsrc = RethTools::IpAddr2String(Buf8()+kElength+kIpOffSrcIP);
    auto ipdst = RethTools::IpAddr2String(Buf8()+kElength+kIpOffDstIP);
    sos << "IPv4: prot " << RosPrintf(prot,"d",3)
        << ": " << RosPrintf(ipsrc.c_str(),"-s", 15)
        << " > " << RosPrintf(ipdst.c_str(),"-s", 15)
        << " siz: " << RosPrintf(tlen,"d", 4);
    if (flags & 0x04) sos << " DF";
    if (flags & 0x08) sos << " MF";
  }
  return sos.str();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string RethBuf::HeaderInfo2() const
{
  auto etype = EType();
  if (etype != kETypeIPv4) return string("");
  auto prot = Buf8()[kElength+kIpOffProt];
  if (prot != kIpProtICMP && prot != kIpProtTCP &&
      prot != kIpProtUDP) return string("");

  ostringstream sos;
  size_t iphlen = 4 * (Buf8()[kElength] & 0x0f);  // IP header length
  size_t hdroff   = kElength + iphlen;            // offset to next header
  if (prot == kIpProtICMP) {
    auto type =  GetB(hdroff+kImcpType);
    auto code =  GetB(hdroff+kImcpCode);
    sos << "IMCP: type: " << RosPrintf(type,"d", 3)
        << " code: " << RosPrintf(code,"d", 3);
    if (type == 0 || type == 8) {
      auto seqnum = ntohs(Buf16()[(hdroff+kImcpEchoSN)/2]);
      sos << " echo snum: " << RosPrintf(seqnum,"d", 5)
          << (type == 0 ? " reply (ping)" : " request (ping)");
    }

  } else if (prot == kIpProtTCP) {
    auto iptlen  = GetS(kElength+kIpOffLen);
    auto srcport = GetS(hdroff+kTcpOffSrcPort);
    auto dstport = GetS(hdroff+kTcpOffDstPort);
    auto seqnum  = GetL(hdroff+kTcpOffSeqNum);
    auto acknum  = GetL(hdroff+kTcpOffAckNum);
    auto flags   = GetB(hdroff+kTcpOffFlags);
    auto datoff  = GetB(hdroff+kTcpOffDatOff);
    size_t tcplen = iptlen - iphlen - 4*(datoff>>4 & 0x0f);
    sos << "TCP: " << RosPrintf(srcport,"d", 5)
        << " > " << RosPrintf(dstport,"d", 5)
        << " n:" << RosPrintf(seqnum,"d", 10)
        << "," << RosPrintf(acknum,"d", 10)
        << " siz: " << RosPrintf(tcplen,"d", 4);
    if (flags & 0x01) sos << " FIN";
    if (flags & 0x02) sos << " SYN";
    if (flags & 0x04) sos << " RST";
    if (flags & 0x08) sos << " PSH";
    if (flags & 0x10) sos << " ACK";
    if (flags & 0x20) sos << " URG";
    if (flags & 0x40) sos << " ECE";
    if (flags & 0x80) sos << " CWR";

  } else if (prot == kIpProtUDP) {
    auto srcport = GetS(hdroff+kUdpOffSrcPort);
    auto dstport = GetS(hdroff+kUdpOffDstPort);
    auto udplen  = GetS(hdroff+kUdpOffLen);
    sos << "UDP: " << RosPrintf(srcport,"d", 5)
        << " > " << RosPrintf(dstport,"d", 5)
        << " siz: " << RosPrintf(udplen,"d", 4);
    if (srcport ==   53 || dstport ==   53) sos << " DNS";
    if (srcport ==   67 || dstport ==   67) sos << " BOOTP";
    if (srcport ==   68 || dstport ==   68) sos << " BOOTP";
    if (srcport ==   69 || dstport ==   69) sos << " TFTP";
    if (srcport ==  138 || dstport ==  138) sos << " NETBIOS";
    if (srcport == 5353 || dstport == 5353) sos << " mDNS";
  }
  return sos.str();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string RethBuf::HeaderInfoAll(bool ext, int ind) const
{
  if (!ext) return FrameInfo();
  RosFill bl(ind);
  ostringstream sos;
  sos << FrameInfo();
  string info = HeaderInfo1();
  if (info.size()) {
    sos << endl << bl << info;
    info = HeaderInfo2();
    if (info.size()) {
      sos << endl << bl << info;
    }
  }
  return sos.str();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RethBuf::Dump(std::ostream& os, int ind, const char* text,
                   int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RethBuf @ " << this << endl;
  os << bl << "  fTime: " << fTime << endl;
  os << bl << "  fBuf:  " << HeaderInfoAll(detail>0, ind+9) << endl;

  if (detail <= 1) return;                  // detail<=1 --> info only

  int ibeg  = 0;
  int imax  = int(Size())-1;
  for (int iline=0; ; iline++) {
    if (ibeg > imax) break;
    if (detail <= 2 && iline >= 6) break;   // detail>2 --> full buffer
    int iend  = ibeg + 15;
    int igap  = 0;
    if (iend > imax) {
      igap = iend - imax;
      iend = imax;
    }
    os << bl << "    " << RosPrintf(ibeg,"x0", 4) << ":";
    // print hex
    for (int i=ibeg; i<=iend; i++) os << " " << RosPrintf(Buf8()[i],"x0", 2);
    for (int i=0;    i<igap;  i++) os << "   ";
    // print ascii
    os << "  ";
    for (int i=ibeg; i<=iend; i++) {
      char c = char(Buf8()[i]);
      if (c < 0x20 || c >= 0x7F) c = '.';
      os << RosPrintf(char(c),"c");
    }
    os << endl;
    ibeg += 16;
  }
  
  return;
}

} // end namespace Retro
