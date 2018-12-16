// $Id: Rw11CntlDL11.cpp 1082 2018-12-15 13:56:20Z mueller $
//
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-15  1082   1.3.2  use lambda instead of bind
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
  \file
  \brief   Implemenation of Rw11CntlDL11.
*/

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"

#include "Rw11CntlDL11.hpp"

using namespace std;

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

const uint16_t Rw11CntlDL11::kRCSR_M_RXRLIM;
const uint16_t Rw11CntlDL11::kRCSR_V_RXRLIM;
const uint16_t Rw11CntlDL11::kRCSR_B_RXRLIM;
const uint16_t Rw11CntlDL11::kRCSR_M_RDONE;
const uint16_t Rw11CntlDL11::kXCSR_M_XRDY;
const uint16_t Rw11CntlDL11::kXBUF_M_RRDY;
const uint16_t Rw11CntlDL11::kXBUF_M_XVAL;
const uint16_t Rw11CntlDL11::kXBUF_M_XBUF;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlDL11::Rw11CntlDL11()
  : Rw11CntlBase<Rw11UnitDL11,1>("dl11"),
    fPC_xbuf(0),
    fRxRlim(0)
{
  // must be here because Units have a back-ptr (not available at Rw11CntlBase)
  fspUnit[0].reset(new Rw11UnitDL11(this, 0)); // single unit controller
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

  // setup primary info clist
  fPrimClist.Clear();
  fPrimClist.AddAttn();
  fPC_xbuf = Cpu().AddRibr(fPrimClist, fBase+kXBUF);

  // add attn handler
  Server().AddAttnHandler([this](RlinkServer::AttnArgs& args)
                            { return AttnHandler(args); }, 
                          uint16_t(1)<<fLam, (void*)this);
  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::UnitSetup(size_t /*ind*/)
{
  Rw11Cpu& cpu  = Cpu();
  uint16_t rcsr = (fRxRlim<<kRCSR_V_RXRLIM) & kRCSR_M_RXRLIM;
  RlinkCommandList clist;
  cpu.AddWibr(clist, fBase+kRCSR, rcsr);
  Server().Exec(clist);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::Wakeup()
{
  if (!fspUnit[0]->RcvQueueEmpty()) {
    RlinkCommandList clist;
    size_t ircsr = Cpu().AddRibr(clist, fBase+kRCSR);
    Server().Exec(clist);
    uint16_t rcsr = clist[ircsr].Data();
    if ((rcsr & kRCSR_M_RDONE) == 0) RcvChar(); // send if RBUF not full
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::SetRxRlim(uint16_t rlim)
{
  if (rlim > kRCSR_B_RXRLIM)
    throw Rexception("Rw11CntlDL11::SetRxRlim","Bad args: rlim too large");

  fRxRlim = rlim;
  UnitSetup(0);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

uint16_t Rw11CntlDL11::RxRlim() const
{
  return fRxRlim;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlDL11 @ " << this << endl;
  os << bl << "  fPC_xbuf:        " << fPC_xbuf << endl;
  os << bl << "  fRxRlim:         " << fRxRlim  << endl;

  Rw11CntlBase<Rw11UnitDL11,1>::Dump(os, ind, " ^", detail);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlDL11::AttnHandler(RlinkServer::AttnArgs& args)
{
  fStats.Inc(kStatNAttnHdl);
  Server().GetAttnInfo(args, fPrimClist);

  uint16_t xbuf = fPrimClist[fPC_xbuf].Data();

  uint8_t ochr = xbuf & kXBUF_M_XBUF;
  bool xval = xbuf & kXBUF_M_XVAL;
  bool rrdy = xbuf & kXBUF_M_RRDY;

  if (fTraceLevel>0) TraceChar('t', xbuf, ochr);
  if (xval) fspUnit[0]->Snd(&ochr, 1);
  if (rrdy && !fspUnit[0]->RcvQueueEmpty()) RcvChar();

  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
// RcvQueueEmpty() must be false !!
  
void Rw11CntlDL11::RcvChar()
{
  uint8_t ichr = fspUnit[0]->RcvQueueNext();
  if (fTraceLevel>0) TraceChar('r', 0, ichr);
  RlinkCommandList clist;
  Cpu().AddWibr(clist, fBase+kRBUF, ichr);
  Server().Exec(clist);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDL11::TraceChar(char dir, uint16_t xbuf, uint8_t chr)
{
  bool xval = xbuf & kXBUF_M_XVAL;
  bool rrdy = xbuf & kXBUF_M_RRDY;
  RlogMsg lmsg(LogFile());
  lmsg << "-I " << Name() << ":" << ' ' << dir << 'x';
  if (dir == 't') {
    lmsg << " xbuf=" << RosPrintBvi(xbuf,8)
         << " xval=" << xval
         << " rrdy=" << rrdy;
  } else {
    lmsg << "                          ";
  }
  lmsg << " rcvq=" << RosPrintf(fspUnit[0]->RcvQueueSize(),"d",3);
  if (xval || dir != 't') {
    lmsg << " char=";
    if (chr>=040 && chr<0177) {
      lmsg << "'" << char(chr) << "'";
    } else {
      lmsg << RosPrintBvi(chr,8);
      lmsg << " " << ((chr&0200) ? "|" : " ");
      uint8_t chr7 = chr & 0177;
      if (chr7 < 040) {
        switch (chr7) {
        case 010: lmsg << "BS"; break;
        case 011: lmsg << "HT"; break;
        case 012: lmsg << "LF"; break;
        case 013: lmsg << "VT"; break;
        case 014: lmsg << "FF"; break;
        case 015: lmsg << "CR"; break;
        case 033: lmsg << "ESC"; break;
        default:  lmsg << "^" << char('@'+chr7);
        }
      } else {
        if (chr7 < 0177) {
          lmsg << "'" << char(chr7) << "'";
        } else {
          lmsg << "DEL";
        }
      }
    }
  }
  return;
}
  
} // end namespace Retro
