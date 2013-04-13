// $Id: Rw11CntlDL11.cpp 504 2013-04-13 15:37:24Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-03-06   495   1.0    Initial version
// 2013-02-05   483   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11CntlDL11.cpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Implemenation of Rw11CntlDL11.
*/

#include "boost/bind.hpp"

#include "librtools/RosFill.hpp"
#include "librtools/Rexception.hpp"

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

const uint16_t Rw11CntlDL11::kRCSR_M_RDONE;
const uint16_t Rw11CntlDL11::kXCSR_M_XRDY;
const uint16_t Rw11CntlDL11::kXBUF_M_RRDY;
const uint16_t Rw11CntlDL11::kXBUF_M_XVAL;
const uint16_t Rw11CntlDL11::kXBUF_M_XBUF;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlDL11::Rw11CntlDL11()
  : Rw11CntlBase<Rw11UnitDL11,1>("dl11"),
    fPC_xbuf(0)
{
  // must here because Unit have a back-pointer (not available at Rw11CntlBase)
  for (size_t i=0; i<NUnit(); i++) {
    fspUnit[i].reset(new Rw11UnitDL11(this, i));
  }
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
  
  // setup primary info clist
  fPrimClist.Clear();
  Cpu().AddIbrb(fPrimClist, fBase);
  fPC_xbuf = Cpu().AddRibr(fPrimClist, fBase+kXBUF);

  // add attn handler
  Server().AddAttnHandler(boost::bind(&Rw11CntlDL11::AttnHandler, this, _1), 
                          uint16_t(1)<<fLam, (void*)this);
  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::Wakeup()
{
  if (!fspUnit[0]->RcvQueueEmpty()) {
    RlinkCommandList clist;
    Cpu().AddIbrb(clist, fBase);
    size_t ircsr = Cpu().AddRibr(clist, fBase+kRCSR);
    Server().Exec(clist);
    // FIXME_code: handle errors
    uint16_t rcsr = clist[ircsr].Data();
    if ((rcsr & kRCSR_M_RDONE) == 0) {      // RBUF not full
      uint8_t ichr = fspUnit[0]->RcvNext();
      clist.Clear();
      Cpu().AddWibr(clist, fBase+kRBUF, ichr);
      Server().Exec(clist);
      // FIXME_code: handle errors
    }
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlDL11 @ " << this << endl;
  Rw11CntlBase<Rw11UnitDL11,1>::Dump(os, ind, " ^");
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlDL11::AttnHandler(const RlinkServer::AttnArgs& args)
{
  RlinkCommandList* pclist;
  size_t off;
  
  GetPrimInfo(args, pclist, off);  

  uint16_t xbuf = (*pclist)[off+fPC_xbuf].Data();

  uint8_t ochr = xbuf & kXBUF_M_XBUF;
  bool xval = xbuf & kXBUF_M_XVAL;
  bool rrdy = xbuf & kXBUF_M_RRDY;

  if (xval) {
    fspUnit[0]->Snd(&ochr, 1);
  }

  if (rrdy && !fspUnit[0]->RcvQueueEmpty()) {
    uint8_t ichr = fspUnit[0]->RcvNext();
    RlinkCommandList clist;
    Cpu().AddWibr(clist, fBase+kRBUF, ichr);
    Server().Exec(clist);
    // FIXME_code: handle errors
  }

  return 0;
}

} // end namespace Retro
