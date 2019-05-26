// $Id: Rw11CntlDZ11.cpp 1150 2019-05-19 17:52:54Z mueller $
//
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-05-19  1150   1.0    Initial version
// 2019-05-04  1146   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11CntlDZ11.
*/

#include <functional>
#include <algorithm>

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"

#include "RtraceTools.hpp"
#include "Rw11CntlDZ11.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::Rw11CntlDZ11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint16_t Rw11CntlDZ11::kIbaddr;
const int      Rw11CntlDZ11::kLam;

const uint16_t Rw11CntlDZ11::kCNTL;  
const uint16_t Rw11CntlDZ11::kSTAT;
const uint16_t Rw11CntlDZ11::kFUSE;
const uint16_t Rw11CntlDZ11::kFDAT;

const uint16_t Rw11CntlDZ11::kProbeOff;
const bool     Rw11CntlDZ11::kProbeInt;
const bool     Rw11CntlDZ11::kProbeRem;

const uint16_t Rw11CntlDZ11::kFifoMaxSize;
  
const uint16_t Rw11CntlDZ11::kCNTL_V_AWDTH;
const uint16_t Rw11CntlDZ11::kCNTL_B_AWDTH;
const uint16_t Rw11CntlDZ11::kCNTL_V_SSEL;
const uint16_t Rw11CntlDZ11::kCNTL_B_SSEL;
const uint16_t Rw11CntlDZ11::kCNTL_M_MSE;
const uint16_t Rw11CntlDZ11::kCNTL_M_MAINT;

const uint16_t Rw11CntlDZ11::kCNTL_V_DATA;
const uint16_t Rw11CntlDZ11::kCNTL_B_DATA;
const uint16_t Rw11CntlDZ11::kCNTL_V_RRLIM;
const uint16_t Rw11CntlDZ11::kCNTL_B_RRLIM;
const uint16_t Rw11CntlDZ11::kCNTL_V_TRLIM;
const uint16_t Rw11CntlDZ11::kCNTL_B_TRLIM;
const uint16_t Rw11CntlDZ11::kCNTL_M_RCLR;
const uint16_t Rw11CntlDZ11::kCNTL_M_TCLR;
const uint16_t Rw11CntlDZ11::kCNTL_M_FUNC;
  
const uint16_t Rw11CntlDZ11::kSSEL_DTLE;
const uint16_t Rw11CntlDZ11::kSSEL_BRRK;
const uint16_t Rw11CntlDZ11::kSSEL_CORI;
const uint16_t Rw11CntlDZ11::kSSEL_RLCN;

const uint16_t Rw11CntlDZ11::kFUNC_NOOP;
const uint16_t Rw11CntlDZ11::kFUNC_SCO;
const uint16_t Rw11CntlDZ11::kFUNC_SRING;
const uint16_t Rw11CntlDZ11::kFUNC_SRLIM;

const uint16_t Rw11CntlDZ11::kCAL_DTR;
const uint16_t Rw11CntlDZ11::kCAL_BRK;
const uint16_t Rw11CntlDZ11::kCAL_RXON;
const uint16_t Rw11CntlDZ11::kCAL_CSR;

const uint16_t Rw11CntlDZ11::kFUSE_V_RFUSE;
const uint16_t Rw11CntlDZ11::kFUSE_B_RFUSE;
const uint16_t Rw11CntlDZ11::kFUSE_M_TFUSE;
  
const uint16_t Rw11CntlDZ11::kFDAT_M_VAL;
const uint16_t Rw11CntlDZ11::kFDAT_M_LAST;
const uint16_t Rw11CntlDZ11::kFDAT_M_FERR;
const uint16_t Rw11CntlDZ11::kFDAT_M_CAL;
const uint16_t Rw11CntlDZ11::kFDAT_V_LINE;
const uint16_t Rw11CntlDZ11::kFDAT_B_LINE;
const uint16_t Rw11CntlDZ11::kFDAT_M_BUF;

const uint16_t Rw11CntlDZ11::kCALCSR_M_MSE;
const uint16_t Rw11CntlDZ11::kCALCSR_M_CLR;
const uint16_t Rw11CntlDZ11::kCALCSR_M_MAINT;  

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlDZ11::Rw11CntlDZ11()
  : Rw11CntlBase<Rw11UnitDZ11,8>("dz11"),
    fPC_fdat(0),
    fPC_fuse(0),
    fRxQlim(0),
    fRxRlim(0),
    fTxRlim(0),
    fModCntl(false),
    fItype(0),
    fFsize(0),
    fTxRblkSize(4),
    fTxQueBusy(false),
    fRxCurUnit(0),
    fLastFuse(0),
    fCurDtr(0),
    fCurBrk(0),
    fCurRxon(0),
    fCurCsr(0)
{
  // must be here because Units have a back-ptr (not available at Rw11CntlBase)
  for (size_t i=0; i<NUnit(); i++) {
    fspUnit[i].reset(new Rw11UnitDZ11(this, i));
  }
  
  fStats.Define(kStatNRxBlk,    "NRxBlk"    , "wblk done");
  fStats.Define(kStatNTxQue,    "NTxQue"    , "rblk queued");
  fStats.Define(kStatNCalDtr,   "NCalDtr"   , "cal dtr  received");
  fStats.Define(kStatNCalBrk,   "NCalBrk"   , "cal brk  received");
  fStats.Define(kStatNCalRxon,  "NCalRxon"  , "cal rxon received");
  fStats.Define(kStatNCalCsr,   "NCalCsr"   , "cal csr  received");
  fStats.Define(kStatNCalBad,   "NCalBad"   , "cal invalid");
  fStats.Define(kStatNDropMse,  "NDropMse"  , "drop because mse=0");
  fStats.Define(kStatNDropMaint,"NDropMaint", "drop because maint=1");
  fStats.Define(kStatNDropRxon, "NDropRxon" , "drop because rxon=0");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11CntlDZ11::~Rw11CntlDZ11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDZ11::Config(const std::string& name, uint16_t base, int lam)
{
  ConfigCntl(name, base, lam, kProbeOff, kProbeInt, kProbeRem);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDZ11::Start()
{
  if (fStarted || fLam<0 || !fEnable || !fProbe.Found())
    throw Rexception("Rw11CntlDZ11::Start",
                     "Bad state: started, no lam, not enable, not found");
  
  // add device register address ibus and rbus mappings
  // done here because now Cntl bound to Cpu and Cntl probed
  Cpu().AllIAddrMapInsert(Name()+".csr",  Base() + kCNTL);
  Cpu().AllIAddrMapInsert(Name()+".rbuf", Base() + kSTAT);
  Cpu().AllIAddrMapInsert(Name()+".tcr",  Base() + kFUSE);
  Cpu().AllIAddrMapInsert(Name()+".tdr",  Base() + kFDAT);

  // detect device type
  fItype  = (fProbe.DataRem()>>kCNTL_V_AWDTH) & kCNTL_B_AWDTH;
  fFsize  = (1<<fItype) - 1;
  fRxQlim = fFsize;

  // ensure unit status is initialized
  Cpu().ExecWibr(fBase+kCNTL, kCNTL_M_RCLR|kCNTL_M_TCLR); // clear rx,tx fifo
  UnitSetupAll();                                // setup rlim,...

  // setup primary info clist
  fPrimClist.Clear();
  fPrimClist.AddAttn();
  fPC_fdat = Cpu().AddRbibr(fPrimClist, fBase+kFDAT, fTxRblkSize);
  fPrimClist[fPC_fdat].SetExpectStatus(0, RlinkCommand::kStat_M_RbTout |
                                          RlinkCommand::kStat_M_RbNak);
  fPC_fuse = Cpu().AddRibr(fPrimClist, fBase+kFUSE);

  // add attn handler
  Server().AddAttnHandler(bind(&Rw11CntlDZ11::AttnHandler, this, _1), 
                          uint16_t(1)<<fLam, this);
  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

  void Rw11CntlDZ11::UnitSetup(size_t /*ind*/)
{
  UnitSetupAll();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDZ11::UnitSetupAll()
{
  uint16_t srlim = ((fRxRlim & kCNTL_B_RRLIM) << kCNTL_V_RRLIM) |
                   ((fTxRlim & kCNTL_B_TRLIM) << kCNTL_V_TRLIM) | kFUNC_SRLIM;
  // if no modem control co is all ones, otherwise the attach pattern
  uint8_t co = 0;
  if (fModCntl) {
    for (size_t i=0; i<NUnit(); i++) {
      if (fspUnit[i]->HasVirt()) co |= uint8_t(1)<<i;
    }
  } else {
    co = 0xff;
  }
  uint16_t sco = (uint16_t(co) << kCNTL_V_DATA) | kFUNC_SCO;
  
  Cpu().ExecWibr(fBase+kCNTL, srlim, fBase+kCNTL, sco);
  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDZ11::Wakeup()
{
  // is last know rfuse more than half fifo size get an update
  // in most cases no update will be needed
  uint16_t rfuse = (fLastFuse >>kFUSE_V_RFUSE) & kFUSE_B_RFUSE;
  if (rfuse > fFsize/2) {
    fLastFuse = Cpu().ExecRibr(fBase+kFUSE);
  }
  
  RxProcess(fLastFuse);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDZ11::SetRxQlim(uint16_t qlim)
{
  if (qlim == 0) qlim = fFsize;
  if (qlim > fFsize)
    throw Rexception("Rw11CntlDZ11::SetRxQlim",
                     "Bad args: qlim larger than fifosize");

  fRxQlim = qlim;
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDZ11::SetRxRlim(uint16_t rlim)
{
  if (rlim > kCNTL_B_RRLIM)
    throw Rexception("Rw11CntlDZ11::SetRxRlim","Bad args: rlim too large");

  fRxRlim = rlim;
  UnitSetupAll();
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDZ11::SetTxRlim(uint16_t rlim)
{
  if (rlim > kCNTL_B_TRLIM)
    throw Rexception("Rw11CntlDZ11::SetTxRlim","Bad args: rlim too large");

  fTxRlim = rlim;
  UnitSetupAll();
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDZ11::SetModCntl(bool modcntl)
{
  fModCntl = modcntl;
  UnitSetupAll();  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDZ11::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlDZ11 @ " << this << endl;
  os << bl << "  fPC_fdat:        " << fPC_fdat << endl;
  os << bl << "  fPC_fuse:        " << fPC_fuse << endl;
  os << bl << "  fRxQlim:         " << RosPrintf(fRxQlim,"d",3)  << endl;
  os << bl << "  fRxRlim:         " << RosPrintf(fRxRlim,"d",3)  << endl;
  os << bl << "  fTxRlim:         " << RosPrintf(fTxRlim,"d",3)  << endl;
  os << bl << "  fModCntl:        " << RosPrintf(fModCntl)  << endl;
  os << bl << "  fItype:          " << RosPrintf(fItype,"d",3)  << endl;
  os << bl << "  fFsize:          " << RosPrintf(fFsize,"d",3) << endl;
  os << bl << "  fTxRblkSize:     " << RosPrintf(fTxRblkSize,"d",3) << endl;
  os << bl << "  fTxQueBusy:      " << RosPrintf(fTxQueBusy) << endl;
  os << bl << "  fRxCurUnit:      " << RosPrintf(fRxCurUnit,"d",3) << endl;
  os << bl << "  fLastFuse:       " << RosPrintf(fLastFuse,"d",3) << endl;
  os << bl << "  fCurDtr:         " << RosPrintBvi(fCurDtr,2) << endl;
  os << bl << "  fCurBrk:         " << RosPrintBvi(fCurBrk,2) << endl;
  os << bl << "  fCurRxon:        " << RosPrintBvi(fCurRxon,2) << endl;
  os << bl << "  fCurCsr:         " << RosPrintBvi(fCurCsr,2)
             << "  mse="   << ((fCurCsr&kCALCSR_M_MSE)!=0)
             << "  maint=" << ((fCurCsr&kCALCSR_M_MAINT)!=0) << endl;

  Rw11CntlBase<Rw11UnitDZ11,8>::Dump(os, ind, " ^", detail);
  return;
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlDZ11::AttnHandler(RlinkServer::AttnArgs& args)
{
  fStats.Inc(kStatNAttnHdl);
  Server().GetAttnInfo(args, fPrimClist);

  fLastFuse = fPrimClist[fPC_fuse].Data();

  TxProcess(fPrimClist[fPC_fdat], true, fLastFuse);
  RxProcess(fLastFuse);
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDZ11::RxProcess(uint16_t fuse)
{
  uint16_t rfuse = (fuse >>kFUSE_V_RFUSE) & kFUSE_B_RFUSE;
  
  if (rfuse >= fRxQlim) return;           // no space in fifo  -> quit
  uint16_t nmax = fRxQlim - rfuse;        // limit is fifo space  
  vector<uint16_t> iblock;
  iblock.reserve(nmax);
  while (iblock.size() < nmax) {
    if (!NextBusyRxUnit()) break;           // find busy unit, quit if none
    size_t qsize = fspUnit[fRxCurUnit]->RcvQueueSize();
    if (qsize > nmax-iblock.size()) qsize = nmax-iblock.size();
    for (size_t i=0; i<qsize; i++) {
      uint8_t  ichr = fspUnit[fRxCurUnit]->RcvQueueNext();
      uint16_t iwrd = ((uint16_t(fRxCurUnit) & kFDAT_B_LINE) << kFDAT_V_LINE) |
                      ichr;
      if (!(fCurCsr & kCALCSR_M_MSE)) {                      // drop if mse=0
        fStats.Inc(kStatNDropMse);
      } else if (fCurCsr & kCALCSR_M_MAINT) {                // drop if maint=1
        fStats.Inc(kStatNDropMaint);
      } else if (!(fCurRxon & (uint8_t(1)<<fRxCurUnit))) {   // drop if rxon=0
        fStats.Inc(kStatNDropRxon);
      } else {
        iblock.push_back(iwrd);
        fspUnit[fRxCurUnit]->StatIncRx(ichr);
      }
    }
  }

  if (iblock.size() == 0) return;           // nothing found
  
  if (fTraceLevel > 0) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I " << Name() << ": rx "
         << " rfuse=" << RosPrintf(rfuse,"d",3)
         << " size=" << RosPrintf(iblock.size(),"d",3);
    if (fTraceLevel > 1) RtraceTools::TraceBuffer(lmsg, iblock.data(),
                                                  iblock.size(), fTraceLevel);
  }
  
  fStats.Inc(kStatNRxBlk);
  RlinkCommandList clist;
  Cpu().AddWbibr(clist, fBase+kFDAT, move(iblock));
  int ifuse = Cpu().AddRibr(clist, fBase+kFUSE);
  Server().Exec(clist);

  fLastFuse = clist[ifuse].Data();          // remember fuse after fifo write

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDZ11::TxProcess(const RlinkCommand& cmd, bool prim, uint16_t fuse)
{
  size_t done = cmd.BlockDone();
  if (done == 0) return;
  
  uint16_t tfuse =  fuse                  & kFUSE_M_TFUSE;
  uint16_t rfuse = (fuse >>kFUSE_V_RFUSE) & kFUSE_B_RFUSE;
  const uint16_t* xbuf = cmd.BlockPointer();
  bool lastseen = false;
  
  uint8_t sndbuf[kNUnit][kFifoMaxSize+1];
  size_t  sndcnt[kNUnit] = {};
  
  for (size_t i=0; i < done; i++) {
    uint16_t xwrd = xbuf[i];
    bool     last = (xwrd & kFDAT_M_LAST) != 0;
    bool     ferr = (xwrd & kFDAT_M_FERR) != 0;
    bool     cal  = (xwrd & kFDAT_M_CAL)  != 0;
    uint16_t line = (xwrd>>kFDAT_V_LINE) & kFDAT_B_LINE;
    uint8_t  ochr = xwrd                 & kFDAT_M_BUF;
    if (last) lastseen = true;
    if (ferr) {
      fspUnit[line]->StatIncTx(0, true);    // count
      continue;                             // and ignore
    }
    if (cal) {
      switch (line) {
      case kCAL_DTR:
        fCurDtr = ochr;
        fStats.Inc(kStatNCalDtr);
        if (fTraceLevel > 0) {
          RlogMsg lmsg(LogFile());
          lmsg << "-I " << Name() << ": cal dtr=" << RosPrintBvi(ochr,2);
        }
        break;
      case kCAL_BRK:
        fCurBrk = ochr;
        fStats.Inc(kStatNCalBrk);
        if (fTraceLevel > 0) {
          RlogMsg lmsg(LogFile());
          lmsg << "-I " << Name() << ": cal brk=" << RosPrintBvi(ochr,2);
        }
        break;
      case kCAL_RXON:
        fCurRxon = ochr;
        fStats.Inc(kStatNCalRxon);
        if (fTraceLevel > 0) {
          RlogMsg lmsg(LogFile());
          lmsg << "-I " << Name() << ": cal rxon=" << RosPrintBvi(ochr,2);
        }
        break;
      case kCAL_CSR:
        fCurCsr = ochr;
        fStats.Inc(kStatNCalCsr);
        if (ochr & kCALCSR_M_CLR) {
          fCurRxon = 0;
          fCurBrk  = 0;
        }
        if (fTraceLevel > 0) {
          RlogMsg lmsg(LogFile());
          lmsg << "-I " << Name() << ": cal csr=" << RosPrintBvi(ochr,2)
               << "  mse=" << ((ochr&kCALCSR_M_MSE)!=0)
               << "  clr=" << ((ochr&kCALCSR_M_CLR)!=0)
               << "  maint=" << ((ochr&kCALCSR_M_MAINT)!=0);
        }
        break;
      default:
        fStats.Inc(kStatNCalBad);
        if (fTraceLevel > 0) {
          RlogMsg lmsg(LogFile());
          lmsg << "-E " << Name() << ": cal code bad:" << RosPrintf(line,"d");
        }
        break;
      }
    } else {
      fspUnit[line]->StatIncTx(ochr);
      sndbuf[line][sndcnt[line]++] = ochr;
    }
  }

  for (size_t i = 0; i < kNUnit; i++) {
    if (sndcnt[i]) fspUnit[i]->Snd(sndbuf[i], sndcnt[i]);
  }  
 
  // determine next chunk size: done+tfuse, at least 4, at most fFsize
  fTxRblkSize = uint16_t(done)+tfuse;
  fTxRblkSize = max(uint16_t(4), min(fTxRblkSize, fFsize));
  
  // queue further reads when queue idle and fifo not emptied
  if ((!fTxQueBusy) && done > 0 && (!lastseen)) {
    fStats.Inc(kStatNTxQue);
    fTxQueBusy = true;
    Server().QueueAction(bind(&Rw11CntlDZ11::TxRcvHandler, this));
  }
  
  if (fTraceLevel > 0) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I " << Name() << ": tx "
         << " prim=" << prim
         << " size=" << RosPrintf(cmd.BlockSize(),"d",3)
         << " done=" << RosPrintf(done,"d",3)
         << " last=" << lastseen
         << " tfuse=" << RosPrintf(tfuse,"d",3)
         << "  que=" << fTxQueBusy;
    if (prim) {
      lmsg << " rfuse=" << RosPrintf(rfuse,"d",3);
    }
    if (fTraceLevel > 1) RtraceTools::TraceBuffer(lmsg, xbuf,
                                                  done, fTraceLevel);
  }
  
  // re-sizing the prim rblk invalidates pbuf -> so must be done last
  if (prim) {                               // if primary list
    fPrimClist[fPC_fdat].SetBlockRead(fTxRblkSize); // setup size for next attn
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlDZ11::TxRcvHandler()
{
  fTxQueBusy = false;
  RlinkCommandList clist;
  int ifdat = Cpu().AddRbibr(clist, fBase+kFDAT, fTxRblkSize);
  clist[ifdat].SetExpectStatus(0, RlinkCommand::kStat_M_RbTout |
                                  RlinkCommand::kStat_M_RbNak);
  int ifuse = Cpu().AddRibr(clist, fBase+kFUSE);

  Server().Exec(clist);

  fLastFuse = clist[ifuse].Data();
  TxProcess(clist[ifdat], false, fLastFuse);

  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11CntlDZ11::NextBusyRxUnit()
{
  for (size_t i=0; i<NUnit(); i++) {
    fRxCurUnit += 1;
    if (fRxCurUnit >= NUnit()) fRxCurUnit = 0;
    if (!fspUnit[fRxCurUnit]->RcvQueueEmpty()) return true;
  }
  return false;
}
  
} // end namespace Retro
