// $Id: Rw11CntlLP11.cpp 1114 2019-02-23 18:01:55Z mueller $
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
  \file
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
const uint16_t Rw11CntlLP11::kBUF_M_VAL;
const uint16_t Rw11CntlLP11::kBUF_M_BUF;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlLP11::Rw11CntlLP11()
  : Rw11CntlBase<Rw11UnitLP11,1>("lp11"),
    fPC_buf(0)
{
  // must be here because Units have a back-ptr (not available at Rw11CntlBase)
  fspUnit[0].reset(new Rw11UnitLP11(this, 0)); // single unit controller
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

  // setup primary info clist
  fPrimClist.Clear();
  fPrimClist.AddAttn();
  fPC_buf = Cpu().AddRibr(fPrimClist, fBase+kBUF);

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

void Rw11CntlLP11::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlLP11 @ " << this << endl;
  os << bl << "  fPC_buf:         " << fPC_buf << endl;

  Rw11CntlBase<Rw11UnitLP11,1>::Dump(os, ind, " ^", detail);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlLP11::AttnHandler(RlinkServer::AttnArgs& args)
{
  fStats.Inc(kStatNAttnHdl);
  Server().GetAttnInfo(args, fPrimClist);

  uint16_t buf = fPrimClist[fPC_buf].Data();
  bool val     = buf & kBUF_M_VAL;
  uint8_t ochr = buf & kBUF_M_BUF;

  if (fTraceLevel>0) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I " << Name() << ":"
         << " buf=" << RosPrintBvi(buf,8)
         << " val=" << val;
    if (val) {
      lmsg << " char=";
      if (ochr>=040 && ochr<0177) {
        lmsg << "'" << char(ochr) << "'";
      } else {
        lmsg << RosPrintBvi(ochr,8);
      }
    }
  }
  
  if (val) {
    RerrMsg emsg;
    bool rc = fspUnit[0]->VirtWrite(&ochr, 1, emsg);
    if (!rc) {
      RlogMsg lmsg(LogFile());
      lmsg << emsg;
      SetOnline(false);
    }
    if (ochr == 014) {                      // ^L = FF = FormFeed seen ?
      rc = fspUnit[0]->VirtFlush(emsg);
    }
  }

  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlLP11::SetOnline(bool online)
{
  Rw11Cpu& cpu  = Cpu();
  uint16_t csr  = online ? 0 : kCSR_M_ERROR;
  RlinkCommandList clist;
  cpu.AddWibr(clist, fBase+kCSR, csr);
  Server().Exec(clist);
  return;
}
  
} // end namespace Retro
