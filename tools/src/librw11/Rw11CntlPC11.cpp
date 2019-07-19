// $Id: Rw11CntlPC11.cpp 1185 2019-07-12 17:29:12Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-05-31  1156   1.5.2  size->fuse rename
// 2019-04-27  1140   1.5.1  use RtraceTools::
// 2019-04-20  1134   1.5    add pc11_buf readout
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
#include <algorithm>
#include <vector>

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"

#include "RtraceTools.hpp"
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
  
const uint16_t Rw11CntlPC11::kFifoMaxSize;

const uint16_t Rw11CntlPC11::kRCSR_M_ERROR;
const uint16_t Rw11CntlPC11::kRCSR_V_RLIM;
const uint16_t Rw11CntlPC11::kRCSR_B_RLIM;
const uint16_t Rw11CntlPC11::kRCSR_V_TYPE;
const uint16_t Rw11CntlPC11::kRCSR_B_TYPE;
const uint16_t Rw11CntlPC11::kRCSR_M_FCLR;  
const uint16_t Rw11CntlPC11::kRBUF_M_RBUSY;
const uint16_t Rw11CntlPC11::kRBUF_V_FUSE;
const uint16_t Rw11CntlPC11::kRBUF_B_FUSE;
const uint16_t Rw11CntlPC11::kRBUF_M_DATA;
  
const uint16_t Rw11CntlPC11::kPCSR_M_ERROR;
const uint16_t Rw11CntlPC11::kPCSR_V_RLIM;
const uint16_t Rw11CntlPC11::kPCSR_B_RLIM;
const uint16_t Rw11CntlPC11::kPBUF_M_VAL;
const uint16_t Rw11CntlPC11::kPBUF_V_FUSE;
const uint16_t Rw11CntlPC11::kPBUF_B_FUSE;
const uint16_t Rw11CntlPC11::kPBUF_M_DATA;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlPC11::Rw11CntlPC11()
  : Rw11CntlBase<Rw11UnitPC11,2>("pc11"),
    fPC_pbuf(0),
    fPC_rbuf(0),
    fPrQlim(1),
    fPrRlim(0),
    fPpRlim(0),
    fItype(0),
    fFsize(0),
    fPpRblkSize(4),
    fPpQueBusy(false),
    fPrDrain(kPrDrain_Idle)
{
  // must be here because Units have a back-ptr (not available at Rw11CntlBase)
  for (size_t i=0; i<NUnit(); i++) {
    fspUnit[i].reset(new Rw11UnitPC11(this, i));
  }
  
  fStats.Define(kStatNPrBlk, "NPrBlk" , "wblk done");
  fStats.Define(kStatNPpQue, "NPpQue" , "rblk queued");
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

  // detect device type
  fItype  = (fProbe.DataRem()>>kRCSR_V_TYPE) & kRCSR_B_TYPE;
  fFsize  = (1<<fItype) - 1;
  fPrQlim = fFsize;
  
  // ensure unit status is initialized (online, rlim,...)
  UnitSetupAll();
  
  // setup primary info clist
  fPrimClist.Clear();
  fPrimClist.AddAttn();
  if (!Buffered()) {
    fPC_pbuf = Cpu().AddRibr(fPrimClist, fBase+kPBUF);
  } else {
    fPC_pbuf = Cpu().AddRbibr(fPrimClist, fBase+kPBUF, fPpRblkSize);
    fPrimClist[fPC_pbuf].SetExpectStatus(0, RlinkCommand::kStat_M_RbTout |
                                            RlinkCommand::kStat_M_RbNak);
  }
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

  if (ind == kUnit_PR) {                    // reader
    // reader is online when attached but not when virt in eof or error state
    // and the reader fifo has been emptied
    bool online = unit.HasVirt() && !
      ( (unit.Virt().Eof() || unit.Virt().Error()) &&
          ! (fPrDrain == kPrDrain_Pend) );    
    uint16_t rcsr  = (online ? 0 : kRCSR_M_ERROR) |              // err field
                     ((fPrRlim & kRCSR_B_RLIM) << kRCSR_V_RLIM); // rlim field
    Cpu().ExecWibr(fBase+kRCSR, rcsr);
    
  } else {                                  // puncher
    // puncher is online when attached and virt not in error state
    bool online = unit.HasVirt() && ! unit.Virt().Error();
    uint16_t pcsr  = (online ? 0 : kPCSR_M_ERROR) |              // err field
                     ((fPpRlim & kPCSR_B_RLIM) << kPCSR_V_RLIM); // rlim field
    Cpu().ExecWibr(fBase+kPCSR, pcsr);
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::SetPrQlim(uint16_t qlim)
{
  if (qlim == 0) qlim = fFsize;
  if (qlim > fFsize)
    throw Rexception("Rw11CntlPC11::SetPrQlim",
                     "Bad args: qlim larger than fifosize");

  fPrQlim = qlim;
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::SetPrRlim(uint16_t rlim)
{
  if (rlim > kRCSR_B_RLIM)
    throw Rexception("Rw11CntlPC11::SetPrRlim","Bad args: rlim too large");

  fPrRlim = rlim;
  UnitSetup(kUnit_PR);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::SetPpRlim(uint16_t rlim)
{
  if (rlim > kPCSR_B_RLIM)
    throw Rexception("Rw11CntlPC11::SetPpRlim","Bad args: rlim too large");

  fPpRlim = rlim;
  UnitSetup(kUnit_PP);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::AttachDone(size_t ind)
{
  // if reader is attached pre-fill the fifo
  if (ind == kUnit_PR && Buffered()) {
    fPrDrain = kPrDrain_Idle;               // clear drain state
    PrProcessBuf(kRBUF_M_RBUSY);            // and pre-fill
  }
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
  os << bl << "  fPrQlim:         " << RosPrintf(fPrQlim,"d",3)  << endl;
  os << bl << "  fPrRlim:         " << RosPrintf(fPrRlim,"d",3)  << endl;
  os << bl << "  fPpRlim:         " << RosPrintf(fPpRlim,"d",3)  << endl;
  os << bl << "  fItype:          " << RosPrintf(fItype,"d",3)  << endl;
  os << bl << "  fFsize:          " << RosPrintf(fFsize,"d",3) << endl;
  os << bl << "  fPpRblkSize:     " << RosPrintf(fPpRblkSize,"d",3) << endl;
  os << bl << "  fPpQueBusy:      " << RosPrintf(fPpQueBusy) << endl;
  os << bl << "  fPrDrain:        ";
  switch (fPrDrain) {
    case kPrDrain_Idle: os << "Idle";  break;
    case kPrDrain_Pend: os << "Pend";  break;
    case kPrDrain_Done: os << "Done";  break;
    default: os << "????";
  };
  os << endl;
  Rw11CntlBase<Rw11UnitPC11,2>::Dump(os, ind, " ^", detail);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlPC11::AttnHandler(RlinkServer::AttnArgs& args)
{
  fStats.Inc(kStatNAttnHdl);
  Server().GetAttnInfo(args, fPrimClist);
  
  if (!Buffered()) {                        // un-buffered iface -------------
    ProcessUnbuf(fPrimClist[fPC_rbuf].Data(),
                 fPrimClist[fPC_pbuf].Data());
  } else {                                  // buffered iface ----------------
    PpProcessBuf(fPrimClist[fPC_pbuf], true, fPrimClist[fPC_rbuf].Data());
    PrProcessBuf(fPrimClist[fPC_rbuf].Data());
  }
  
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::ProcessUnbuf(uint16_t rbuf, uint16_t pbuf)
{
  bool rbusy    = rbuf & kRBUF_M_RBUSY;
  bool pval     = pbuf & kPBUF_M_VAL;
  uint8_t ochr  = pbuf & kPBUF_M_DATA;
  
  if (pval) {                               // punch valid -------------------
    if (pval) PpWriteChar(ochr);
    if (fTraceLevel>0) {
      RlogMsg lmsg(LogFile());
      lmsg << "-I " << Name() << ": pp"
           << " pbuf=" << RosPrintBvi(pbuf,8)
           << " pval=" << pval
           << " rbusy=" << rbusy
           << " char=" << RosPrintBvi(ochr,8) << " ";
      RtraceTools::TraceChar(lmsg, ochr);
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
      UnitSetup(kUnit_PR);
      
    } else {
      if (fTraceLevel>0) {
        RlogMsg lmsg(LogFile());
        lmsg << "-I " << Name() << ": pr"
             << " rbusy=" << rbusy
             << " char=" << RosPrintBvi(ichr,8) << " ";
        RtraceTools::TraceChar(lmsg, ochr);
      }
      
      Cpu().ExecWibr(fBase+kRBUF, ichr);
    }
  }
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::PpWriteChar(uint8_t ochr)
{
  RerrMsg emsg;
  bool rc = fspUnit[kUnit_PP]->VirtWrite(&ochr, 1, emsg);
  if (!rc) {
    RlogMsg lmsg(LogFile());
    lmsg << "-E " << Name() << ":" << emsg;
    UnitSetup(kUnit_PP);
  }

  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::PrProcessBuf(uint16_t rbuf)
{
  bool     rbusy = rbuf & kRBUF_M_RBUSY;
  uint16_t rfuse = (rbuf >>kRBUF_V_FUSE) & kRBUF_B_FUSE;
  uint8_t ichr = 0;
  RerrMsg emsg;

  if (! rbusy) return;                // quit if no data requested
  
  if (fPrDrain == kPrDrain_Pend) {    // eof/err seen and draining
    if (rfuse == 0) {                 // draining done, last char read
      if (fTraceLevel>0) {
        RlogMsg lmsg(LogFile());
        lmsg << "-I " << Name() << ": set reader offline after fifo drained";  
      }
      fPrDrain = kPrDrain_Done;
      UnitSetup(kUnit_PR);
    }
    return;
  }
  
  if (fPrDrain == kPrDrain_Pend ||          // draining ongoing or done -> quit
      fPrDrain == kPrDrain_Done) return;
  if (rfuse >= fPrQlim) return;             // no space in fifo -> quit
  
  uint16_t nmax = fPrQlim - rfuse;
  vector<uint16_t> iblock;
  iblock.reserve(nmax);
  for (uint16_t i = 0; i<nmax; i++) {
    int irc = fspUnit[kUnit_PR]->VirtRead(&ichr, 1, emsg);
    if (irc <= 0) {
      if (irc < 0) {
        RlogMsg lmsg(LogFile());
        lmsg << "-E " << Name() << ":" << emsg;
      }
      if (irc == 0 && fTraceLevel>0) {
        RlogMsg lmsg(LogFile());
        lmsg << "-I " << Name() << ": eof seen on input stream";
      }
      fPrDrain = kPrDrain_Pend;
      break;
    } else {
      iblock.push_back(uint16_t(ichr));
    }
  }
  
  if (iblock.size() > 0) {
    if (fTraceLevel > 0) {
      RlogMsg lmsg(LogFile());
      lmsg << "-I " << Name() << ": pr"
           << " rfuse=" << RosPrintf(rfuse,"d",3)
             << " drain=" << fPrDrain
           << " size=" << RosPrintf(iblock.size(),"d",3);
      if (fTraceLevel > 1) RtraceTools::TraceBuffer(lmsg, iblock.data(),
                                                    iblock.size(), fTraceLevel);
    }
    
    fStats.Inc(kStatNPrBlk);
    RlinkCommandList clist;
    Cpu().AddWbibr(clist, fBase+kRBUF, move(iblock));
    Server().Exec(clist);
    
  } else {
    // if no byte to send, eof seen, and fifo empty --> go offline immediately
    if (rfuse == 0 && fPrDrain == kPrDrain_Pend) {
      if (fTraceLevel>0) {
        RlogMsg lmsg(LogFile());
        lmsg << "-I " << Name() << ": set reader offline immediately";
      }
      fPrDrain = kPrDrain_Done;
      UnitSetup(kUnit_PR);
    }
  }
  
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::PpProcessBuf(const RlinkCommand& cmd, bool prim,
                                uint16_t rbuf)
{
  const uint16_t* pbuf = cmd.BlockPointer();
  size_t done = cmd.BlockDone();
  if (done == 0) return;

  uint16_t fbeg  = 0;
  uint16_t fend  = 0;
  uint16_t fdel  = 0;
  uint16_t fumin = 0;
  uint16_t fumax = 0;

  fbeg  = (pbuf[0]     >>kPBUF_V_FUSE) & kPBUF_B_FUSE;
  fend  = (pbuf[done-1]>>kPBUF_V_FUSE) & kPBUF_B_FUSE;
  fdel  = fbeg-fend+1;
  fumin = kFifoMaxSize;
  
  for (size_t i=0; i < done; i++) {
    uint8_t  ochr =  pbuf[i]                & kPBUF_M_DATA;
    uint16_t fuse = (pbuf[i]>>kPBUF_V_FUSE) & kPBUF_B_FUSE;
    fumin = min(fumin,fuse);
    fumax = max(fumax,fuse);
    PpWriteChar(ochr);
  }

  // determine next chunk size from highest fifo 'fuse' field, at least 4
  fPpRblkSize = max(uint16_t(4), max(uint16_t(done),fumax));
  
  // queue further reads when queue idle and fifo not emptied
  // check for 'fuse==1' not seen in current read
  if ((!fPpQueBusy) && fumin > 1) {       // if fumin>1 no fuse==1 seen
    fStats.Inc(kStatNPpQue);
    fPpQueBusy = true;
    Server().QueueAction(bind(&Rw11CntlPC11::PpRcvHandler, this));
  }
  
  if (fTraceLevel > 0) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I " << Name() << ": pp"
         << " pr,si,do="  << prim
         << "," << RosPrintf(cmd.BlockSize(),"d",3)
         << "," << RosPrintf(done,"d",3)
         << "  fifo=" << RosPrintf(fbeg,"d",3)
         << "," << RosPrintf(fend,"d",3)
         << ";" << RosPrintf(fdel,"d",3)
         << "," << RosPrintf(done-fdel,"d",3)
         << ";" << RosPrintf(fumax,"d",3)
         << "," << RosPrintf(fumin,"d",3)
         << "  que="   << fPpQueBusy;
    if (prim) {
      uint16_t rfuse = (rbuf >>kRBUF_V_FUSE) & kRBUF_B_FUSE;
      lmsg << " rfuse=" << RosPrintf(rfuse,"d",3);
    }
    
    if (fTraceLevel > 1) RtraceTools::TraceBuffer(lmsg, pbuf,
                                                  done, fTraceLevel);
  }
  
  // re-sizing the prim rblk invalidates pbuf -> so must be done last
  if (prim) {                               // if primary list
    fPrimClist[fPC_pbuf].SetBlockRead(fPpRblkSize); // setup size for next attn
  }
  
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs
  
int Rw11CntlPC11::PpRcvHandler()
{
  fPpQueBusy = false;
  RlinkCommandList clist;
  Cpu().AddRbibr(clist, fBase+kPBUF, fPpRblkSize);
  clist[0].SetExpectStatus(0, RlinkCommand::kStat_M_RbTout |
                              RlinkCommand::kStat_M_RbNak);
  Server().Exec(clist);
  PpProcessBuf(clist[0], false, 0);
  return 0;
}

} // end namespace Retro
