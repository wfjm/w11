// $Id: Rw11CntlLP11.cpp 1185 2019-07-12 17:29:12Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-05-30  1155   1.3.5  size->fuse rename
// 2019-04-27  1140   1.3.4  use RtraceTools::
// 2019-04-19  1133   1.3.3  use ExecWibr()
// 2019-04-14  1131   1.3.2  remove SetOnline(), use UnitSetup()
// 2019-04-07  1127   1.3.1  add fQueBusy, queue protection; fix logic;
//                           Start(): ensure unit offline; better tracing
// 2019-03-17  1123   1.3    add lp11_buf readout
// 2019-02-23  1114   1.2.6  use std::bind instead of lambda
// 2018-12-15  1082   1.2.5  use lambda instead of boost::bind
// 2018-12-09  1080   1.2.4  use HasVirt()
// 2017-04-02   865   1.2.3  Dump(): add detail arg
// 2017-03-03   858   1.2.2  use cntl name as message prefix
// 2017-02-25   855   1.2.1  shorten ctor code
// 2014-12-30   625   1.2    adopt to Rlink V4 attn logic
// 2014-12-25   621   1.1    adopt to 4k word ibus window
// 2013-05-04   515   1.0    Initial version
// 2013-05-01   513   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11CntlLP11.
*/

#include <functional>
#include <algorithm>

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"

#include "RtraceTools.hpp"
#include "Rw11CntlLP11.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::Rw11CntlLP11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint16_t Rw11CntlLP11::kIbaddr;
const int      Rw11CntlLP11::kLam;

const uint16_t Rw11CntlLP11::kCSR; 
const uint16_t Rw11CntlLP11::kBUF; 

const uint16_t Rw11CntlLP11::kProbeOff;
const bool     Rw11CntlLP11::kProbeInt;
const bool     Rw11CntlLP11::kProbeRem;
  
const uint16_t Rw11CntlLP11::kFifoMaxSize;

const uint16_t Rw11CntlLP11::kCSR_M_ERROR;
const uint16_t Rw11CntlLP11::kCSR_V_RLIM;
const uint16_t Rw11CntlLP11::kCSR_B_RLIM;
const uint16_t Rw11CntlLP11::kCSR_V_TYPE;
const uint16_t Rw11CntlLP11::kCSR_B_TYPE;
const uint16_t Rw11CntlLP11::kBUF_M_VAL;
const uint16_t Rw11CntlLP11::kBUF_V_FUSE;
const uint16_t Rw11CntlLP11::kBUF_B_FUSE;  
const uint16_t Rw11CntlLP11::kBUF_M_DATA;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlLP11::Rw11CntlLP11()
  : Rw11CntlBase<Rw11UnitLP11,1>("lp11"),
  fPC_buf(0),
  fRlim(0),
  fItype(0),
  fFsize(0),
  fRblkSize(4),
  fQueBusy(false)
{
  // must be here because Units have a back-ptr (not available at Rw11CntlBase)
  fspUnit[0].reset(new Rw11UnitLP11(this, 0)); // single unit controller

  fStats.Define(kStatNQue  , "NQue"   , "rblk queued");
  fStats.Define(kStatNNull , "NNull"  , "null char send");
  fStats.Define(kStatNChar , "NChar"  , "char send (non-null)");
  fStats.Define(kStatNLine , "NLine"  , "lines send");
  fStats.Define(kStatNPage , "NPage"  , "pages send");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11CntlLP11::~Rw11CntlLP11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlLP11::Config(const std::string& name, uint16_t base, int lam)
{
  ConfigCntl(name, base, lam, kProbeOff, kProbeInt, kProbeRem);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlLP11::Start()
{
  if (fStarted || fLam<0 || !fEnable || !fProbe.Found())
    throw Rexception("Rw11CntlLP11::Start",
                     "Bad state: started, no lam, not enable, not found");
  
  // add device register address ibus and rbus mappings
  // done here because now Cntl bound to Cpu and Cntl probed
  Cpu().AllIAddrMapInsert(Name()+".csr", Base() + kCSR);
  Cpu().AllIAddrMapInsert(Name()+".buf", Base() + kBUF);

  // detect device type
  fItype = (fProbe.DataRem()>>kCSR_V_TYPE) & kCSR_B_TYPE;
  fFsize = (1<<fItype) - 1;
  
  // ensure unit status is initialized (online, rlim,...)
  UnitSetupAll();
  
  // setup primary info clist
  fPrimClist.Clear();
  fPrimClist.AddAttn();
  if (!Buffered()) {
    fPC_buf = Cpu().AddRibr(fPrimClist, fBase+kBUF);
  } else {
    fPC_buf = Cpu().AddRbibr(fPrimClist, fBase+kBUF, fRblkSize);
    fPrimClist[fPC_buf].SetExpectStatus(0, RlinkCommand::kStat_M_RbTout |
                                           RlinkCommand::kStat_M_RbNak);
  }
  
  // add attn handler
  Server().AddAttnHandler(bind(&Rw11CntlLP11::AttnHandler, this, _1), 
                          uint16_t(1)<<fLam, this);

  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlLP11::UnitSetup(size_t ind)
{
  Rw11UnitLP11& unit = *fspUnit[ind];
  bool online  = unit.HasVirt() && ! unit.Virt().Error();
  uint16_t csr = (online ? 0 : kCSR_M_ERROR) |             //  err field
                 ((fRlim & kCSR_B_RLIM) << kCSR_V_RLIM);   // rlim field
  Cpu().ExecWibr(fBase+kCSR, csr);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlLP11::SetRlim(uint16_t rlim)
{
  if (rlim > kCSR_B_RLIM)
    throw Rexception("Rw11CntlLP11::SetRlim","Bad args: rlim too large");

  fRlim = rlim;
  UnitSetup(0);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlLP11::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlLP11 @ " << this << endl;
  os << bl << "  fPC_buf:         " << fPC_buf << endl;
  os << bl << "  fRlim:           " << RosPrintf(fRlim,"d",3)  << endl;
  os << bl << "  fItype:          " << RosPrintf(fItype,"d",3)  << endl;
  os << bl << "  fFsize:          " << RosPrintf(fFsize,"d",3) << endl;
  os << bl << "  fRblkSize:       " << RosPrintf(fRblkSize,"d",3) << endl;
  os << bl << "  fQueBusy:        " << RosPrintf(fQueBusy) << endl;

  Rw11CntlBase<Rw11UnitLP11,1>::Dump(os, ind, " ^", detail);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlLP11::AttnHandler(RlinkServer::AttnArgs& args)
{
  fStats.Inc(kStatNAttnHdl);
  Server().GetAttnInfo(args, fPrimClist);

  if (!Buffered()) {                        // un-buffered iface -------------
    ProcessUnbuf(fPrimClist[fPC_buf].Data());
  } else {                                  // buffered iface ----------------
    ProcessBuf(fPrimClist[fPC_buf], true);
  }
  
  return 0;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlLP11::ProcessUnbuf(uint16_t buf)
{
  bool     val  =  buf & kBUF_M_VAL;
  uint8_t  ochr =  buf & kBUF_M_DATA;

  if (val) WriteChar(ochr);
    
  if (fTraceLevel>0) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I " << Name() << ":"
         << " buf=" << RosPrintBvi(buf,8)
         << " val=" << val;
    if (val) {
      lmsg << " char=" << RosPrintBvi(ochr,8) << " ";
      RtraceTools::TraceChar(lmsg, ochr);
    }
  }
  
  return;
}

  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlLP11::WriteChar(uint8_t ochr)
{
  if (ochr == 0) {                          // count NULL char
    fStats.Inc(kStatNNull);
    return;
  }
  
  fStats.Inc(kStatNChar);
  RerrMsg emsg;
  bool rc = fspUnit[0]->VirtWrite(&ochr, 1, emsg);
  if (!rc) {
    RlogMsg lmsg(LogFile());
    lmsg << emsg;
    UnitSetup(0);
  }
  if (ochr == '\f') {                     // ^L = FF = FormFeed seen ?
    fStats.Inc(kStatNPage);
    rc = fspUnit[0]->VirtFlush(emsg);
  } else if (ochr == '\n') {              // ^J = LF = LineFeed seen ?
    fStats.Inc(kStatNLine);
  }
  return;  
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlLP11::ProcessBuf(const RlinkCommand& cmd, bool prim)
{
  const uint16_t* pbuf = cmd.BlockPointer();
  size_t done = cmd.BlockDone();

  if (fQueBusy && prim) {
    RlogMsg lmsg(LogFile());
    lmsg <<  "-E " << Name()
         << ": prim=1 call and queue busy";
  }

  uint16_t fbeg  = 0;
  uint16_t fend  = 0;
  uint16_t fdel  = 0;
  uint16_t fumin  = 0;
  uint16_t fumax  = 0;

  if (done > 0) {
    fbeg  = (pbuf[0]     >>kBUF_V_FUSE) & kBUF_B_FUSE;
    fend  = (pbuf[done-1]>>kBUF_V_FUSE) & kBUF_B_FUSE;
    fdel  = fbeg-fend+1;
    fumin = kFifoMaxSize;
  }
  
  for (size_t i=0; i < done; i++) {
    uint8_t  ochr =  pbuf[i]               & kBUF_M_DATA;
    uint16_t fuse = (pbuf[i]>>kBUF_V_FUSE) & kBUF_B_FUSE;
    fumin = min(fumin,fuse);
    fumax = max(fumax,fuse);
    WriteChar(ochr);
  }

  // determine next chunk size from highest fifo 'fuse' field, at least 4
  fRblkSize = max(uint16_t(4), max(uint16_t(done),fumax));

  // queue further reads when fifo not emptied
  // check for 'fuse==1' not seen in current read
  if (fumin > 1) {                          // if fumin>1 no fuse==1 seen
    if (fQueBusy) {
      RlogMsg lmsg(LogFile());
      lmsg <<  "-E " << Name()
           << ": queue attempt while queue busy, prim=" << prim;
    } else {
      fStats.Inc(kStatNQue);
      fQueBusy = true;
      Server().QueueAction(bind(&Rw11CntlLP11::RcvHandler, this));
    }
  }

  if (fTraceLevel > 0) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I " << Name() << ":"
         << " pr,si,do="  << prim
         << "," << RosPrintf(cmd.BlockSize(),"d",3)
         << "," << RosPrintf(done,"d",3)
         << "  fifo=" << RosPrintf(fbeg,"d",3)
         << "," << RosPrintf(fend,"d",3)
         << ";" << RosPrintf(fdel,"d",3)
         << "," << RosPrintf(done-fdel,"d",3)
         << ";" << RosPrintf(fumax,"d",3)
         << "," << RosPrintf(fumin,"d",3)
         << "  que="   << fQueBusy;
    
    if (fTraceLevel > 1) RtraceTools::TraceBuffer(lmsg, pbuf,
                                                  done, fTraceLevel);
  }
  
  
  // re-sizing the prim rblk invalidates pbuf -> so must be done last
  if (prim) {                               // if primary list
    fPrimClist[fPC_buf].SetBlockRead(fRblkSize);   // setup size for next attn
  }
  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
int Rw11CntlLP11::RcvHandler()
{
  fQueBusy = false;
  RlinkCommandList clist;
  Cpu().AddRbibr(clist, fBase+kBUF, fRblkSize);
  clist[0].SetExpectStatus(0, RlinkCommand::kStat_M_RbTout |
                              RlinkCommand::kStat_M_RbNak);
  Server().Exec(clist);
  ProcessBuf(clist[0], false);
  return 0;
}

} // end namespace Retro
