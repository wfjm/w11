// $Id: Rw11CntlPC11.cpp 1131 2019-04-14 13:24:25Z mueller $
//
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-04-13  1131   1.4.1  BootCode(): boot loader rewritten
//                           remove SetOnline(), use UnitSetup()
// 2019-04-06  1126   1.4    pbuf.val in msb; rbusy in rbuf (new unbuf iface)
//                           Start(): ensure unit offline; BootCode(): 56k top
// 2019-02-23  1114   1.3.4  use std::bind instead of lambda
// 2018-12-15  1082   1.3.3  use lambda instead of boost::bind
// 2018-12-09  1080   1.3.2  use HasVirt(); Virt() returns ref
// 2018-10-28  1062   1.3.1  replace boost/foreach
// 2017-05-14   897   1.3    trace received chars
// 2017-04-02   865   1.2.2  Dump(): add detail arg
// 2017-03-03   858   1.2.1  use cntl name as message prefix
// 2014-12-30   625   1.2    adopt to Rlink V4 attn logic
// 2014-12-25   621   1.1    adopt to 4k word ibus window
// 2013-05-03   515   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11CntlPC11.
*/

#include <functional>

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"

#include "Rw11CntlPC11.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::Rw11CntlPC11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint16_t Rw11CntlPC11::kIbaddr;
const int      Rw11CntlPC11::kLam;

const uint16_t Rw11CntlPC11::kRCSR; 
const uint16_t Rw11CntlPC11::kRBUF; 
const uint16_t Rw11CntlPC11::kPCSR; 
const uint16_t Rw11CntlPC11::kPBUF; 

const uint16_t Rw11CntlPC11::kUnit_PR;
const uint16_t Rw11CntlPC11::kUnit_PP;

const uint16_t Rw11CntlPC11::kProbeOff;
const bool     Rw11CntlPC11::kProbeInt;
const bool     Rw11CntlPC11::kProbeRem;

const uint16_t Rw11CntlPC11::kRCSR_M_ERROR;
const uint16_t Rw11CntlPC11::kRCSR_V_RLIM;
const uint16_t Rw11CntlPC11::kRCSR_B_RLIM;
const uint16_t Rw11CntlPC11::kRCSR_V_TYPE;
const uint16_t Rw11CntlPC11::kRCSR_B_TYPE;
const uint16_t Rw11CntlPC11::kRCSR_M_FCLR;  
const uint16_t Rw11CntlPC11::kRBUF_M_RBUSY;
const uint16_t Rw11CntlPC11::kRBUF_V_SIZE;
const uint16_t Rw11CntlPC11::kRBUF_B_SIZE;
const uint16_t Rw11CntlPC11::kRBUF_M_BUF;
  
const uint16_t Rw11CntlPC11::kPCSR_M_ERROR;
const uint16_t Rw11CntlPC11::kPCSR_V_RLIM;
const uint16_t Rw11CntlPC11::kPCSR_B_RLIM;
const uint16_t Rw11CntlPC11::kPBUF_M_VAL;
const uint16_t Rw11CntlPC11::kPBUF_V_SIZE;
const uint16_t Rw11CntlPC11::kPBUF_B_SIZE;
const uint16_t Rw11CntlPC11::kPBUF_M_BUF;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlPC11::Rw11CntlPC11()
  : Rw11CntlBase<Rw11UnitPC11,2>("pc11"),
    fPC_pbuf(0),
    fPC_rbuf(0)
{
  // must be here because Units have a back-ptr (not available at Rw11CntlBase)
  for (size_t i=0; i<NUnit(); i++) {
    fspUnit[i].reset(new Rw11UnitPC11(this, i));
  }
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11CntlPC11::~Rw11CntlPC11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::Config(const std::string& name, uint16_t base, int lam)
{
  ConfigCntl(name, base, lam, kProbeOff, kProbeInt, kProbeRem);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::Start()
{
  if (fStarted || fLam<0 || !fEnable || !fProbe.Found())
    throw Rexception("Rw11CntlPC11::Start",
                     "Bad state: started, no lam, not enable, not found");
  
  // add device register address ibus and rbus mappings
  // done here because now Cntl bound to Cpu and Cntl probed
  Cpu().AllIAddrMapInsert(Name()+".rcsr", Base() + kRCSR);
  Cpu().AllIAddrMapInsert(Name()+".rbuf", Base() + kRBUF);
  Cpu().AllIAddrMapInsert(Name()+".pcsr", Base() + kPCSR);
  Cpu().AllIAddrMapInsert(Name()+".pbuf", Base() + kPBUF);

  // ensure unit status is initialized (online, rlim,...)
  UnitSetupAll();
  
  // setup primary info clist
  fPrimClist.Clear();
  fPrimClist.AddAttn();
  fPC_pbuf = Cpu().AddRibr(fPrimClist, fBase+kPBUF);
  fPC_rbuf = Cpu().AddRibr(fPrimClist, fBase+kRBUF);

  // add attn handler
  Server().AddAttnHandler(bind(&Rw11CntlPC11::AttnHandler, this, _1), 
                          uint16_t(1)<<fLam, this);

  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11CntlPC11::BootCode(size_t /*unit*/, std::vector<uint16_t>& code, 
                            uint16_t& aload, uint16_t& astart)
{
  uint16_t bootcode[] = {      // papertape lda loader (see pc11boot.mac)
    0000000,                   //         halt
    0010706,                   // start:  mov     pc,sp       ; setup stack
    0024646,                   //         cmp     -(sp),-(sp)
    0012705, 0177550,          //         mov     #pr.csr,r5
    0005715,                   // 1$:     tst     (r5)        ; error bit set ?
    0100776,                   //         bmi     1$          ; if mi yes, wait
    0005002,                   // rdrec:  clr     r2          ; check checksum
    0004767, 0000142,          // 1$:     jsr     pc,rdbyte   ; read 000 or 001
    0105700,                   //         tstb    r0          ; is zero ?
    0001774,                   //         beq     1$          ; if eq yes, retry
    0005300,                   //         dec     r0          ; test for 001
    0001030,                   //         bne     err1        ; if ne not, quit
    0004767, 0000126,          //         jsr     pc,rdbyte   ; read 000
    0105700,                   //         tstb    r0          ; is zero ?
    0001024,                   //         bne     err1        ; if ne not, quit
    0004767, 0000076,          //         jsr     pc,rdword   ; read count
    0010104,                   //         mov     r1,r4       ; store count
    0004767, 0000070,          //         jsr     pc,rdword   ; read addr
    0010103,                   //         mov     r1,r3       ; store addr
    0162704, 0000006,          //         sub     #6,r4       ; sub 6 from count
    0002414,                   //         blt     err2        ; if <6 halt
    0003016,                   //         bgt     rddata      ; if >6 read data
    0004767, 0000072,          //         jsr     pc,rdbyte   ; read checksum
    0105702,                   //         tstb    r2          ; test checksum
    0001010,                   //         bne     err3        ; if ne bad, quit
    0032703, 0000001,          //         bit     #1,r3       ; address odd ?
    0001402,                   //         beq     2$          ; if eq not
    0012703, 0000200,          //         mov     #200,r3     ; else use #200
    0000113,                   // 2$:     jmp     (r3)        ; start code
    0000000,                   // err1:   halt                ; halt: bad frame
    0000000,                   // err2:   halt                ; halt: bad count
    0000000,                   // err3:   halt                ; halt: bad chksum
    0000000,                   // err4:   halt                ; halt: csr.err
    0004767, 0000036,          // rddata: jsr     pc,rdbyte   ; read byte
    0110023,                   //         movb    r0,(r3)+    ; store byte
    0077404,                   //         sob     r4,rddata   ; loop till done
    0004767, 0000026,          //         jsr     pc,rdbyte   ; read checksum
    0105702,                   //         tstb    r2          ; test checksum
    0001366,                   //         bne     err3        ; if ne bad, quit
    0000724,                   //         br      rdrec       ; next record
    0004767, 0000014,          // rdword: jsr     pc,rdbyte   ; read low  byte
    0010001,                   //         mov     r0,r1       ; low byte to r1
    0004767, 0000006,          //         jsr     pc,rdbyte   ; read high byte
    0000300,                   //         swab    r0
    0050001,                   //         bis     r0,r1       ; high byte to r1
    0000207,                   //         rts     pc
    0005215,                   // rdbyte: inc     (r5)        ; set enable
    0005715,                   // 1$:     tst     (r5)        ; error set ?
    0100753,                   //         bmi     err4        ; if mi yes, quit
    0105715,                   //         tstb    (r5)        ; done set ?
    0100374,                   //         bpl     1$          ; if pl not, retry
    0016500, 0000002,          //         mov     2(r5),r0    ; read byte
    0060002,                   //         add     r0,r2       ; sum checksum
    0000207                    //         rts     pc
  };
  
  code.clear();
  code.insert(code.end(), std::begin(bootcode), std::end(bootcode));

  uint32_t memsize = Cpu().MemSize();
  uint16_t boottop = (memsize > 56*1024) ? 56*1024 : memsize;
  aload  = boottop - sizeof(bootcode);
  astart = aload+2;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::UnitSetup(size_t ind)
{
  Rw11UnitPC11& unit = *fspUnit[ind];
  bool online = unit.HasVirt() && ! (unit.Virt().Error() ||
                                     unit.Virt().Eof());

  Rw11Cpu& cpu  = Cpu();
  RlinkCommandList clist;
  if (ind == kUnit_PR) {                    // reader on/offline
    uint16_t rcsr  = online ? 0 : kRCSR_M_ERROR;
    cpu.AddWibr(clist, fBase+kRCSR, rcsr);
  } else {                                  // puncher on/offline
    uint16_t pcsr  = online ? 0 : kPCSR_M_ERROR;
    cpu.AddWibr(clist, fBase+kPCSR, pcsr);
  }
  Server().Exec(clist);  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlPC11 @ " << this << endl;
  os << bl << "  fPC_pbuf:        " << fPC_pbuf << endl;
  os << bl << "  fPC_rbuf:        " << fPC_rbuf << endl;

  Rw11CntlBase<Rw11UnitPC11,2>::Dump(os, ind, " ^", detail);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlPC11::AttnHandler(RlinkServer::AttnArgs& args)
{
  fStats.Inc(kStatNAttnHdl);
  Server().GetAttnInfo(args, fPrimClist);

  uint16_t pbuf = fPrimClist[fPC_pbuf].Data();
  uint16_t rbuf = fPrimClist[fPC_rbuf].Data();
  bool rbusy    = rbuf & kRBUF_M_RBUSY;
  bool pval     = pbuf & kPBUF_M_VAL;
  uint8_t ochr  = pbuf & kPBUF_M_BUF;
  
  if (pval) {                               // punch valid -------------------
    if (fTraceLevel>0) {
      RlogMsg lmsg(LogFile());
      lmsg << "-I " << Name() << ": pp"
           << " pbuf=" << RosPrintBvi(pbuf,8)
           << " pval=" << pval
           << " rbusy=" << rbusy
           << " char=" << RosPrintBvi(ochr,8);
      if (ochr>=040 && ochr<0177)  lmsg << "  '" << char(ochr) << "'";
    }
    
    RerrMsg emsg;
    bool rc = fspUnit[kUnit_PP]->VirtWrite(&ochr, 1, emsg);
    if (!rc) {
      RlogMsg lmsg(LogFile());
      lmsg << "-E " << Name() << ":" << emsg;
      UnitSetup(1);
    }
  }

  if (rbusy) {                              // reader busy -------------------
    uint8_t ichr = 0;
    RerrMsg emsg;
    int irc = fspUnit[kUnit_PR]->VirtRead(&ichr, 1, emsg);
    if (irc < 0) {
      RlogMsg lmsg(LogFile());
      lmsg << "-E " << Name() << ":" << emsg;
    }
    
    if (irc <= 0) {
      if (fTraceLevel>0) {
        RlogMsg lmsg(LogFile());
        lmsg << "-I " << Name() << ": set reader offline";  
      }  
      UnitSetup(0);
      
    } else {
      if (fTraceLevel>0) {
        RlogMsg lmsg(LogFile());
        lmsg << "-I " << Name() << ": pr"
             << " rbusy=" << rbusy
             << " char=" << RosPrintBvi(ichr,8);
        if (ichr>=040 && ichr<0177) lmsg << "  '" << char(ichr) << "'";
      }
      
      RlinkCommandList clist;
      Cpu().AddWibr(clist, fBase+kRBUF, ichr);
      Server().Exec(clist);
    }
  }
  
  return 0;
}

  
} // end namespace Retro
