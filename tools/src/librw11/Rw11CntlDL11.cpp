// $Id: Rw11CntlDL11.cpp 1157 2019-05-31 18:32:14Z mueller $
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
// 2019-05-31  1156   1.5.1  size->fuse rename; use unit.StatInc[RT]x
// 2019-04-27  1139   1.5    add dl11_buf readout
// 2019-04-19  1133   1.4.2  use ExecWibr(),ExecRibr()
// 2019-04-14  1131   1.4.1  proper unit init, call UnitSetupAll() in Start()
// 2019-04-06  1126   1.4    xbuf.val in msb; rrdy in rbuf (new iface)
// 2019-02-23  1114   1.3.2  use std::bind instead of lambda
// 2018-12-15  1082   1.3.1  use lambda instead of boost::bind
// 2017-05-14   897   1.3    add RcvChar(),TraceChar(); trace received chars
// 2017-04-02   865   1.2.3  Dump(): add detail arg
// 2017-03-03   858   1.2.2  use cntl name as message prefix
// 2017-02-25   855   1.2.1  shorten ctor code; RcvNext() --> RcvQueueNext()
// 2014-12-30   625   1.2    adopt to Rlink V4 attn logic
// 2014-12-25   621   1.1    adopt to 4k word ibus window and 
// 2013-05-04   516   1.0.2  add RxRlim support (receive interrupt rate limit)
// 2013-04-20   508   1.0.1  add trace support
// 2013-03-06   495   1.0    Initial version
// 2013-02-05   483   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11CntlDL11.
*/

#include <functional>
#include <algorithm>

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"

#include "RtraceTools.hpp"
#include "Rw11CntlDL11.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::Rw11CntlDL11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint16_t Rw11CntlDL11::kIbaddr;
const int      Rw11CntlDL11::kLam;

const uint16_t Rw11CntlDL11::kRCSR; 
const uint16_t Rw11CntlDL11::kRBUF; 
const uint16_t Rw11CntlDL11::kXCSR; 
const uint16_t Rw11CntlDL11::kXBUF; 

const uint16_t Rw11CntlDL11::kProbeOff;
const bool     Rw11CntlDL11::kProbeInt;
const bool     Rw11CntlDL11::kProbeRem;

const uint16_t Rw11CntlDL11::kFifoMaxSize;

const uint16_t Rw11CntlDL11::kRCSR_V_RLIM;
const uint16_t Rw11CntlDL11::kRCSR_B_RLIM;
const uint16_t Rw11CntlDL11::kRCSR_V_TYPE;
const uint16_t Rw11CntlDL11::kRCSR_B_TYPE;
const uint16_t Rw11CntlDL11::kRCSR_M_RDONE;
const uint16_t Rw11CntlDL11::kRCSR_M_FCLR;
const uint16_t Rw11CntlDL11::kRBUF_V_RFUSE;
const uint16_t Rw11CntlDL11::kRBUF_B_RFUSE;
const uint16_t Rw11CntlDL11::kRBUF_M_DATA;
  
const uint16_t Rw11CntlDL11::kXCSR_V_RLIM;
const uint16_t Rw11CntlDL11::kXCSR_B_RLIM;
const uint16_t Rw11CntlDL11::kXCSR_M_XRDY;
const uint16_t Rw11CntlDL11::kXCSR_M_FCLR;
const uint16_t Rw11CntlDL11::kXBUF_M_VAL;
const uint16_t Rw11CntlDL11::kXBUF_V_FUSE;
const uint16_t Rw11CntlDL11::kXBUF_B_FUSE;
const uint16_t Rw11CntlDL11::kXBUF_M_DATA;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlDL11::Rw11CntlDL11()
  : Rw11CntlBase<Rw11UnitDL11,1>("dl11"),
    fPC_xbuf(0),
    fPC_rbuf(0),
    fRxQlim(0),
    fRxRlim(0),
    fTxRlim(0),
    fItype(0),
    fFsize(0),
    fTxRblkSize(4),
    fTxQueBusy(false),
    fLastRbuf(0)
{
  // must be here because Units have a back-ptr (not available at Rw11CntlBase)
  fspUnit[0].reset(new Rw11UnitDL11(this, 0)); // single unit controller
  
  fStats.Define(kStatNRxBlk,  "NRxBlk" , "wblk done");
  fStats.Define(kStatNTxQue,  "NTxQue" , "rblk queued");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11CntlDL11::~Rw11CntlDL11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::Config(const std::string& name, uint16_t base, int lam)
{
  ConfigCntl(name, base, lam, kProbeOff, kProbeInt, kProbeRem);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::Start()
{
  if (fStarted || fLam<0 || !fEnable || !fProbe.Found())
    throw Rexception("Rw11CntlDL11::Start",
                     "Bad state: started, no lam, not enable, not found");
  
  // add device register address ibus and rbus mappings
  // done here because now Cntl bound to Cpu and Cntl probed
  Cpu().AllIAddrMapInsert(Name()+".rcsr", Base() + kRCSR);
  Cpu().AllIAddrMapInsert(Name()+".rbuf", Base() + kRBUF);
  Cpu().AllIAddrMapInsert(Name()+".xcsr", Base() + kXCSR);
  Cpu().AllIAddrMapInsert(Name()+".xbuf", Base() + kXBUF);

  // detect device type
  fItype  = (fProbe.DataRem()>>kRCSR_V_TYPE) & kRCSR_B_TYPE;
  fFsize  = (1<<fItype) - 1;
  fRxQlim = fFsize;

  // ensure unit status is initialized
  Cpu().ExecWibr(fBase+kRCSR, kRCSR_M_FCLR,      // clear rx fifo 
                 fBase+kXCSR, kXCSR_M_FCLR);     // clear tx fifo
  UnitSetupAll();                                // setup rlim,...

  // setup primary info clist
  fPrimClist.Clear();
  fPrimClist.AddAttn();
  if (!Buffered()) {
    fPC_xbuf = Cpu().AddRibr(fPrimClist, fBase+kXBUF);
  } else {
    fPC_xbuf = Cpu().AddRbibr(fPrimClist, fBase+kXBUF, fTxRblkSize);
    fPrimClist[fPC_xbuf].SetExpectStatus(0, RlinkCommand::kStat_M_RbTout |
                                            RlinkCommand::kStat_M_RbNak);
  }
  fPC_rbuf = Cpu().AddRibr(fPrimClist, fBase+kRBUF);

  // add attn handler
  Server().AddAttnHandler(bind(&Rw11CntlDL11::AttnHandler, this, _1), 
                          uint16_t(1)<<fLam, this);
  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::UnitSetup(size_t /*ind*/)
{
  uint16_t rcsr = (fRxRlim & kRCSR_B_RLIM) << kRCSR_V_RLIM;
  uint16_t xcsr = (fTxRlim & kXCSR_B_RLIM) << kXCSR_V_RLIM;
  Cpu().ExecWibr(fBase+kRCSR, rcsr, fBase+kXCSR, xcsr);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::Wakeup()
{
  if (fspUnit[0]->RcvQueueEmpty()) return;  // spurious call 

  if (!Buffered()) {
    uint16_t rbuf  = Cpu().ExecRibr(fBase+kRBUF);
    uint16_t rfuse = (rbuf >>kRBUF_V_RFUSE) & kRBUF_B_RFUSE;
    if (rfuse == 0) RxProcessUnbuf();
  } else {
    uint16_t rfuse = (fLastRbuf>>kRBUF_V_RFUSE) & kRBUF_B_RFUSE;
    if (rfuse > fFsize/2) {
      fLastRbuf = Cpu().ExecRibr(fBase+kRBUF);
    }
    RxProcessBuf(fLastRbuf);
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::SetRxQlim(uint16_t qlim)
{
  if (qlim == 0) qlim = fFsize;
  if (qlim > fFsize)
    throw Rexception("Rw11CntlDL11::SetRxQlim",
                     "Bad args: qlim larger than fifosize");

  fRxQlim = qlim;
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::SetRxRlim(uint16_t rlim)
{
  if (rlim > kRCSR_B_RLIM)
    throw Rexception("Rw11CntlDL11::SetRxRlim","Bad args: rlim too large");

  fRxRlim = rlim;
  UnitSetup(0);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::SetTxRlim(uint16_t rlim)
{
  if (rlim > kXCSR_B_RLIM)
    throw Rexception("Rw11CntlDL11::SetTxRlim","Bad args: rlim too large");

  fTxRlim = rlim;
  UnitSetup(0);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlDL11 @ " << this << endl;
  os << bl << "  fPC_xbuf:        " << fPC_xbuf << endl;
  os << bl << "  fPC_rbuf:        " << fPC_rbuf << endl;
  os << bl << "  fRxQlim:         " << RosPrintf(fRxQlim,"d",3)  << endl;
  os << bl << "  fRxRlim:         " << RosPrintf(fRxRlim,"d",3)  << endl;
  os << bl << "  fTxRlim:         " << RosPrintf(fTxRlim,"d",3)  << endl;
  os << bl << "  fItype:          " << RosPrintf(fItype,"d",3)  << endl;
  os << bl << "  fFsize:          " << RosPrintf(fFsize,"d",3) << endl;
  os << bl << "  fTxRblkSize:     " << RosPrintf(fTxRblkSize,"d",3) << endl;
  os << bl << "  fTxQueBusy:      " << RosPrintf(fTxQueBusy) << endl;
  os << bl << "  fTLastRbuf:      " << RosPrintf(fLastRbuf) << endl;

  Rw11CntlBase<Rw11UnitDL11,1>::Dump(os, ind, " ^", detail);
  return;
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlDL11::AttnHandler(RlinkServer::AttnArgs& args)
{
  fStats.Inc(kStatNAttnHdl);
  Server().GetAttnInfo(args, fPrimClist);

  if (!Buffered()) {                        // un-buffered iface -------------
    ProcessUnbuf(fPrimClist[fPC_rbuf].Data(),
                 fPrimClist[fPC_xbuf].Data());
  } else {                                  // buffered iface ----------------
    fLastRbuf = fPrimClist[fPC_rbuf].Data();
    TxProcessBuf(fPrimClist[fPC_xbuf], true, fLastRbuf);
    RxProcessBuf(fLastRbuf);
  }

  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::ProcessUnbuf(uint16_t rbuf, uint16_t xbuf)
{
  uint8_t  ochr  = xbuf & kXBUF_M_DATA;
  uint16_t rfuse = (rbuf >>kRBUF_V_RFUSE) & kRBUF_B_RFUSE;
  bool xval = xbuf & kXBUF_M_VAL;

  if (fTraceLevel>0) TraceChar('t', xbuf, ochr);
  if (xval) {
    fspUnit[0]->Snd(&ochr, 1);
    fspUnit[0]->StatIncTx(ochr);
  }
  if (rfuse==0 && !fspUnit[0]->RcvQueueEmpty()) RxProcessUnbuf();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
// RcvQueueEmpty() must be false !!
  
void Rw11CntlDL11::RxProcessUnbuf()
{
  uint8_t ichr = fspUnit[0]->RcvQueueNext();
  fspUnit[0]->StatIncRx(ichr);
  if (fTraceLevel>0) TraceChar('r', 0, ichr);
  Cpu().ExecWibr(fBase+kRBUF, ichr);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::RxProcessBuf(uint16_t rbuf)
{
  uint16_t rfuse = (rbuf >>kRBUF_V_RFUSE) & kRBUF_B_RFUSE;
  
  if (rfuse >= fRxQlim) return;             // no space in fifo  -> quit
  if (fspUnit[0]->RcvQueueEmpty()) return;  // no data available -> quit
  
  uint16_t qsiz = fspUnit[0]->RcvQueueSize();
  uint16_t nmax = fRxQlim - rfuse;          // limit is fifo space
  if (qsiz < nmax) nmax = qsiz;             //       or avail data

  vector<uint16_t> iblock;
  iblock.reserve(nmax);
  for (uint16_t i = 0; i<nmax; i++) {
    uint8_t ichr = fspUnit[0]->RcvQueueNext();
    iblock.push_back(uint16_t(ichr));
    fspUnit[0]->StatIncRx(ichr);
  }
  
  if (fTraceLevel > 0) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I " << Name() << ": rx"
         << " rfuse=" << RosPrintf(rfuse,"d",3)
         << " size=" << RosPrintf(iblock.size(),"d",3);
    if (fTraceLevel > 1) RtraceTools::TraceBuffer(lmsg, iblock.data(),
                                                  iblock.size(), fTraceLevel);
  }
    
  fStats.Inc(kStatNRxBlk);
  RlinkCommandList clist;
  Cpu().AddWbibr(clist, fBase+kRBUF, move(iblock));
  int irbuf = Cpu().AddRibr(clist, fBase+kRBUF);
  Server().Exec(clist);
  
  fLastRbuf = clist[irbuf].Data();          // remember rbuf after fifo write

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::TxProcessBuf(const RlinkCommand& cmd, bool prim,
                                uint16_t rbuf)
{
  const uint16_t* xbuf = cmd.BlockPointer();
  size_t done = cmd.BlockDone();
  if (done == 0) return;

  uint16_t fbeg = 0;
  uint16_t fend = 0;
  uint16_t fdel = 0;
  uint16_t fumin = 0;
  uint16_t fumax = 0;

  fbeg  = (xbuf[0]     >>kXBUF_V_FUSE) & kXBUF_B_FUSE;
  fend  = (xbuf[done-1]>>kXBUF_V_FUSE) & kXBUF_B_FUSE;
  fdel  = fbeg-fend+1;
  fumin = kFifoMaxSize;

  uint8_t ochr[kFifoMaxSize];
  for (size_t i=0; i < done; i++) {
    uint16_t fuse = (xbuf[i]>>kXBUF_V_FUSE) & kXBUF_B_FUSE;
    ochr[i]       =  xbuf[i]                & kXBUF_M_DATA;
    fumin = min(fumin,fuse);
    fumax = max(fumax,fuse);
    fspUnit[0]->StatIncTx(ochr[i]);
  }
  fspUnit[0]->Snd(ochr, done);

  // determine next chunk size from highest fifo 'fuse' field, at least 4
  fTxRblkSize = max(uint16_t(4), max(uint16_t(done),fumax));
  
  // queue further reads when queue idle and fifo not emptied
  // check for 'size==1' not seen in current read
  if ((!fTxQueBusy) && fumin > 1) {       // if fumin>1 no fuse==1 seen
    fStats.Inc(kStatNTxQue);
    fTxQueBusy = true;
    Server().QueueAction(bind(&Rw11CntlDL11::TxRcvHandler, this));
  }
  
  if (fTraceLevel > 0) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I " << Name() << ": tx"
         << " pr,si,do="  << prim
         << "," << RosPrintf(cmd.BlockSize(),"d",3)
         << "," << RosPrintf(done,"d",3)
         << "  fifo=" << RosPrintf(fbeg,"d",3)
         << "," << RosPrintf(fend,"d",3)
         << ";" << RosPrintf(fdel,"d",3)
         << "," << RosPrintf(done-fdel,"d",3)
         << ";" << RosPrintf(fumax,"d",3)
         << "," << RosPrintf(fumin,"d",3)
         << "  que="   << fTxQueBusy;
    if (prim) {
      uint16_t rfuse = (rbuf >>kRBUF_V_RFUSE) & kRBUF_B_RFUSE;
      lmsg << " rfuse=" << RosPrintf(rfuse,"d",3);
    }
    
    if (fTraceLevel > 1) RtraceTools::TraceBuffer(lmsg, xbuf,
                                                  done, fTraceLevel);
  }
  
  // re-sizing the prim rblk invalidates pbuf -> so must be done last
  if (prim) {                               // if primary list
    fPrimClist[fPC_xbuf].SetBlockRead(fTxRblkSize); // setup size for next attn
  }
   
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
  
int Rw11CntlDL11::TxRcvHandler()
{
  fTxQueBusy = false;
  RlinkCommandList clist;
  Cpu().AddRbibr(clist, fBase+kXBUF, fTxRblkSize);
  clist[0].SetExpectStatus(0, RlinkCommand::kStat_M_RbTout |
                              RlinkCommand::kStat_M_RbNak);
  int irbuf = Cpu().AddRibr(clist, fBase+kRBUF);
  
  Server().Exec(clist);
  
  fLastRbuf = clist[irbuf].Data();
  TxProcessBuf(clist[0], false, fLastRbuf);
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDL11::TraceChar(char dir, uint16_t xbuf, uint8_t chr)
{
  bool xval = xbuf & kXBUF_M_VAL;
  RlogMsg lmsg(LogFile());
  lmsg << "-I " << Name() << ":" << ' ' << dir << 'x';
  if (dir == 't') {
    lmsg << " xbuf=" << RosPrintBvi(xbuf,8)
         << " xval=" << xval;
  } else {
    lmsg << "                          ";
  }
  lmsg << " rcvq=" << RosPrintf(fspUnit[0]->RcvQueueSize(),"d",3);
  if (xval || dir != 't') {
    lmsg << " char=" << RosPrintBvi(chr,8) << " ";
    RtraceTools::TraceChar(lmsg, chr);
  }
  return;
}
  
} // end namespace Retro
