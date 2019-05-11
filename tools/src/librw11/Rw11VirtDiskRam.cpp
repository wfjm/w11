// $Id: Rw11VirtDiskRam.cpp 1143 2019-05-01 13:25:51Z mueller $
//
// Copyright 2018-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-05-01  1143   1.1    add noboot option 
// 2018-10-28  1063   1.0    Initial version
// 2018-10-27  1061   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of Rw11VirtDiskRam.
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include <sstream>

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"

#include "Rw11VirtDiskRam.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtDiskRam
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtDiskRam::Rw11VirtDiskRam(Rw11Unit* punit)
  : Rw11VirtDisk(punit),
    fNoBoot(false),
    fPatTyp(kPatZero),
    fBlkMap()
{
  fStats.Define(kStatNVDReadRam,   "NVDReadRam",   "ram: blocks read from ram");
  fStats.Define(kStatNVDWriteOver, "NVDWriteOver", "ram: blocks overwritten");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtDiskRam::~Rw11VirtDiskRam()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskRam::Open(const std::string& url, RerrMsg& emsg)
{
  return Open(url, "file", emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskRam::Open(const std::string& url, const std::string& scheme,
                            RerrMsg& emsg)
{
  if (!fUrl.Set(url, "|wpro|noboot|pat=|", scheme, emsg)) return false;
  fWProt  = fUrl.FindOpt("wpro");
  fNoBoot = fUrl.FindOpt("noboot");

  string pat;
  fPatTyp = kPatZero;
  if (fUrl.FindOpt("pat", pat)) {
    if (pat == "zero") {
      fPatTyp = kPatZero;
    } else if (pat == "ones") {
      fPatTyp = kPatOnes;
    } else if (pat == "dead") {
      fPatTyp = kPatDead;
    } else if (pat == "test") {
      fPatTyp = kPatTest;
    } else {
      emsg.Init("Rw11VirtDiskRam::Open()",
                string("invalid pattern name '") + pat + "'");
      return false;
    }
  }
  
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskRam::Read(size_t lba, size_t nblk, uint8_t* data, 
                           RerrMsg& /*emsg*/)
{
  fStats.Inc(kStatNVDRead);
  fStats.Inc(kStatNVDReadBlk, double(nblk));
  
  for (size_t i=0; i<nblk; i++) {
    auto it = fBlkMap.find(lba+i);
    if (it == fBlkMap.end()) {
      ReadPattern(lba+i, data+i*fBlkSize);
    } else {
      fStats.Inc(kStatNVDReadRam);
      (it->second).Read(data+i*fBlkSize);
    }
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskRam::Write(size_t lba, size_t nblk, const uint8_t* data, 
                            RerrMsg& /*emsg*/)
{
  fStats.Inc(kStatNVDWrite);
  fStats.Inc(kStatNVDWriteBlk, double(nblk));
  
  for (size_t i=0; i<nblk; i++) {
    auto it = fBlkMap.find(lba+i);
    if (it == fBlkMap.end()) {
      auto rc = fBlkMap.emplace(lba+i, Rw11VirtDiskBuffer(fBlkSize));
      it = rc.first;
    } else {
      fStats.Inc(kStatNVDWriteOver, double(nblk));
    }
    
    (it->second).Write(data+i*fBlkSize);
  }
  
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtDiskRam::List(std::ostream& os) const
{
  if (fBlkMap.empty()) return;

  uint32_t lbabeg = fBlkMap.begin()->first; // first lba
  uint32_t nwrite = 0;
  for (auto it=fBlkMap.begin(); it!=fBlkMap.end(); ) {
    nwrite += (it->second).NWrite();
    auto itnext = next(it);
    if (itnext == fBlkMap.end() || itnext->first != (it->first)+1) {
      os << RosPrintf(lbabeg,"d",8) 
         << " .. " << RosPrintf(it->first,"d",8)
         << " : nb=" << RosPrintf(it->first-lbabeg+1,"d",8)
         << " nw=" << RosPrintf(nwrite,"d",8) << endl;
      if (itnext != fBlkMap.end()) lbabeg = itnext->first;
      nwrite = 0;
    }
    it = itnext;
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtDiskRam::Dump(std::ostream& os, int ind, const char* text,
                            int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtDiskRam @ " << this << endl;

  os << bl << "  fNoBoot:         " << fNoBoot << endl;
  os << bl << "  fPatTyp:         " << fPatTyp << endl;
  os << bl << "  fBlkMap.size:    " << fBlkMap.size() << endl;
  Rw11VirtDisk::Dump(os, ind, " ^", detail);
  return;
}
 
//------------------------------------------+-----------------------------------
//! FIXME_doc

void Rw11VirtDiskRam::ReadPattern(size_t lba, uint8_t* data)
{

  if (lba == 0 && fNoBoot) {                // block 0 with 'not bootable' msg
    uint16_t bootcode[] = {
      0012700, 0000026,       // start:  mov     #text, r0
      0105710,                // 1$:     tstb    (r0)
      0001406,                //         beq     3$
      0105737, 0177564,       // 2$:     tstb    @#to.csr
      0100375,                //         bpl     2$
      0112037, 0177566,       //         movb    (r0)+,@#to.buf
      0000770,                //         br      1$
      0000000                 // 3$:     halt
                              // text:   .ascii  ....
    };

    uint16_t* pdata = reinterpret_cast<uint16_t*>(data);
    for (uint16_t& o : bootcode) *pdata++ = o;
    
    ostringstream boottext;
    boottext << "\r\n";
    boottext << "++======================================++\r\n";
    boottext << "|| This is not a hardware bootable disk ||\r\n";
    boottext << "++======================================++\r\n";
    boottext << "\r\n";
    boottext << "Virtual disk: CHS="
             << fNCyl << "," << fNHead << "," << fNSect;
    boottext << " blocks=" << fNBlock << "(" << fBlkSize << ")";
    boottext << " name=" << fUrl.Path();
    boottext << "\r\n";
    boottext << "CPU WILL HALT\r\n";
    boottext << "\r\n";

    char* pchar = reinterpret_cast<char*>(pdata);
    char* pend  = reinterpret_cast<char*>(data+fBlkSize);
    for (char& o : boottext.str()) {        // append boot text
      *pchar++ = o;
      if (pchar >= pend) break;             // ensure block isn't overrrun
    }
    while (pchar < pend) { *pchar++ = '\0'; } // zero fill rest
    pend[-1] = '\0';                          // ensure text 0 terminated
    
    return;
  }
  
  uint16_t* p     = reinterpret_cast<uint16_t*>(data);
  uint16_t* pend  = reinterpret_cast<uint16_t*>(data+fBlkSize);
  size_t    addr  = lba*fBlkSize;

  switch (fPatTyp) {
  case kPatZero:
    while (p < pend) { *p++ = 0x0000; }
    break;
  case kPatOnes:
    while (p < pend) { *p++ = 0xffff; }
    break;
  case kPatDead:
    while (p < pend) { *p++ = 0xdead; *p++ = 0xbeaf; }
    break;
  case kPatTest:
    while(p < pend) {
      *p++ =  addr      & 0xffff;           // byte address, LSB
      *p++ = (addr>>16) & 0xffff;           // byte address, MSB
      *p++ = lba / (fNSect*fNHead);         // current cylinder
      *p++ = (lba/fNSect) % fNHead;         // current head
      *p++ = lba % fNSect;                  // current sector
      *p++ = fNCyl;                         // total number of cylinders
      *p++ = fNHead;                        // total number of heads
      *p++ = fNSect;                        // total number of sectors
      addr += 16;
     }
    break;
  default:
    break;
  }
  
  return;
}

} // end namespace Retro
