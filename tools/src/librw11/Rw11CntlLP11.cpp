// $Id: Rw11CntlLP11.cpp 1123 2019-03-17 17:55:12Z mueller $
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

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"

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

const uint16_t Rw11CntlLP11::kCSR_M_ERROR;
const uint16_t Rw11CntlLP11::kCSR_V_RLIM;
const uint16_t Rw11CntlLP11::kCSR_B_RLIM;
const uint16_t Rw11CntlLP11::kCSR_V_TYPE;
const uint16_t Rw11CntlLP11::kCSR_B_TYPE;
const uint16_t Rw11CntlLP11::kBUF_M_VAL;
const uint16_t Rw11CntlLP11::kBUF_V_SIZE;
const uint16_t Rw11CntlLP11::kBUF_B_SIZE;  
const uint16_t Rw11CntlLP11::kBUF_M_BUF;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlLP11::Rw11CntlLP11()
  : Rw11CntlBase<Rw11UnitLP11,1>("lp11"),
  fPC_buf(0),
  fRlim(0),
  fItype(0),
  fFsize(0),
  fRblkSize(4)
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
  SetOnline(unit.HasVirt());                // online if stream attached
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlLP11::SetRlim(uint16_t rlim)
{
  if (rlim > kCSR_B_RLIM)
    throw Rexception("Rw11CntlLP11::SetRlim","Bad args: rlim too large");

  fRlim = rlim;
  
  Rw11UnitLP11& unit = *fspUnit[0];
  SetOnline(unit.HasVirt());
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
    ProcessChar(fPrimClist[fPC_buf].Data());
  } else {                                  // buffered iface ----------------
    ProcessCmd(fPrimClist[fPC_buf], true);
  }
  
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlLP11::SetOnline(bool online)
{
  Rw11Cpu& cpu  = Cpu();
  uint16_t csr  = (online ? 0 : kCSR_M_ERROR) |             //  err field 
                  ((fRlim & kCSR_B_RLIM) << kCSR_V_RLIM);   // rlim field
  RlinkCommandList clist;
  cpu.AddWibr(clist, fBase+kCSR, csr);
  Server().Exec(clist);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlLP11::ProcessChar(uint16_t buf)
{
  bool     val  =  buf               & kBUF_M_VAL;
  uint16_t size = (buf>>kBUF_V_SIZE) & kBUF_B_SIZE;
  uint8_t  ochr =  buf               & kBUF_M_BUF;
    
  if (fTraceLevel>0) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I " << Name() << ":"
         << " buf=" << RosPrintBvi(buf,8)
         << " val=" << val;
    if (Buffered()) lmsg << " size=" << RosPrintf(size,"d",3);
    if (val) {
      lmsg << " char=";
      if (ochr>=040 && ochr<0177) {
        lmsg << "'" << char(ochr) << "'";
      } else {
        lmsg << RosPrintBvi(ochr,8);
      }
    }
  }
    
  if (val) {                                // valid chars
    if (ochr == 0) {                          // count NULL char
      fStats.Inc(kStatNNull);
    } else {                                  // forward only non-NULL char
      fStats.Inc(kStatNChar);
      RerrMsg emsg;
      bool rc = fspUnit[0]->VirtWrite(&ochr, 1, emsg);
      if (!rc) {
        RlogMsg lmsg(LogFile());
        lmsg << emsg;
        SetOnline(false);
      }
      if (ochr == '\f') {                     // ^L = FF = FormFeed seen ?
        fStats.Inc(kStatNPage);
        rc = fspUnit[0]->VirtFlush(emsg);
      } else if (ochr == '\n') {              // ^J = LF = LineFeed seen ?
        fStats.Inc(kStatNLine);
      }
    }
  }
  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlLP11::ProcessCmd(const RlinkCommand& cmd, bool prim)
{
  const uint16_t* pbuf = cmd.BlockPointer();
  size_t done = cmd.BlockDone();
  for (size_t i=0; i < done; i++) {
    ProcessChar(pbuf[i]);
  }

  // determine next chunk size from fifo 'size' field of first item
  uint16_t buf  = pbuf[0];
  uint16_t size = (buf>>kBUF_V_SIZE) & kBUF_B_SIZE;
  fRblkSize = size;                         // use last size
  if (fRblkSize < 4)      fRblkSize = 4;
  if (fRblkSize > fFsize) fRblkSize = fFsize;
  
  // check whether last entry emptied fifo -> check whether 'size=1'
  buf  = pbuf[done-1];
  size = (buf>>kBUF_V_SIZE) & kBUF_B_SIZE;
  if (size > 1) {                           // fifo not emptied, continue
    fStats.Inc(kStatNQue);
    Server().QueueAction(bind(&Rw11CntlLP11::RcvHandler, this));
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
  RlinkCommandList clist;
  Cpu().AddRbibr(clist, fBase+kBUF, fRblkSize);
  clist[0].SetExpectStatus(0, RlinkCommand::kStat_M_RbTout |
                              RlinkCommand::kStat_M_RbNak);
  Server().Exec(clist);
  ProcessCmd(clist[0], false);
  return 0;
}

} // end namespace Retro
