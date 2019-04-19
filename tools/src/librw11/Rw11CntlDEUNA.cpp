// $Id: Rw11CntlDEUNA.cpp 1133 2019-04-19 18:43:00Z mueller $
//
// Copyright 2014-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-04-19  1133   0.5.9  use ExecWibr()
// 2019-02-23  1114   0.5.8  use std::bind instead of lambda
// 2018-12-19  1090   0.5.7  use RosPrintf(bool)
// 2018-12-17  1087   0.5.6  use std::lock_guard instead of boost
// 2018-12-15  1082   0.5.5  use lambda instead of boost::bind
// 2018-12-09  1080   0.5.4  use HasVirt(); Virt() returns ref
// 2018-12-08  1078   0.5.3  BUGFIX: Start(Tx|Rx)Ring, was broken in r1049
//                             when fixing -Wunused-variable warnings
// 2018-11-30  1075   0.5.2  use list-init
// 2018-09-22  1048   0.5.1  BUGFIX: coverity (resource leak)
// 2017-04-17   880   0.5    Initial version (minimal functions, 211bsd ready)
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of Rw11CntlDEUNA.
*/

#include <string.h>
#include <fcntl.h>
#include <unistd.h>

#include <sstream>
#include <functional>

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"
#include "librtools/Rtools.hpp"

#include "RethTools.hpp"

#include "Rw11CntlDEUNA.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::Rw11CntlDEUNA
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint16_t Rw11CntlDEUNA::kIbaddr;
const int      Rw11CntlDEUNA::kLam;

const uint16_t Rw11CntlDEUNA::kPR0;
const uint16_t Rw11CntlDEUNA::kPR1;
const uint16_t Rw11CntlDEUNA::kPR2;
const uint16_t Rw11CntlDEUNA::kPR3;

const uint16_t Rw11CntlDEUNA::kProbeOff;
const bool     Rw11CntlDEUNA::kProbeInt;
const bool     Rw11CntlDEUNA::kProbeRem;

const uint16_t Rw11CntlDEUNA::kPR0_M_SERI;  
const uint16_t Rw11CntlDEUNA::kPR0_M_PCEI;
const uint16_t Rw11CntlDEUNA::kPR0_M_RXI;
const uint16_t Rw11CntlDEUNA::kPR0_M_TXI;
const uint16_t Rw11CntlDEUNA::kPR0_M_DNI;
const uint16_t Rw11CntlDEUNA::kPR0_M_RCBI;
const uint16_t Rw11CntlDEUNA::kPR0_M_USCI;
const uint16_t Rw11CntlDEUNA::kPR0_M_INTR;
const uint16_t Rw11CntlDEUNA::kPR0_M_INTE;
const uint16_t Rw11CntlDEUNA::kPR0_M_RSET;
const uint16_t Rw11CntlDEUNA::kPR0_M_BRST;
const uint16_t Rw11CntlDEUNA::kPR0_M_PCMD;

const uint16_t Rw11CntlDEUNA::kPR0_V_PCMDBP;
const uint16_t Rw11CntlDEUNA::kPR0_B_PCMDBP;
const uint16_t Rw11CntlDEUNA::kPR0_M_PDMDWB;
const uint16_t Rw11CntlDEUNA::kPR0_M_PCWWB;
  
const uint16_t Rw11CntlDEUNA::kPCMD_NOOP;  
const uint16_t Rw11CntlDEUNA::kPCMD_GETPCBB;
const uint16_t Rw11CntlDEUNA::kPCMD_GETCMD;
const uint16_t Rw11CntlDEUNA::kPCMD_SELFTST;
const uint16_t Rw11CntlDEUNA::kPCMD_START;
const uint16_t Rw11CntlDEUNA::kPCMD_BOOT;
const uint16_t Rw11CntlDEUNA::kPCMD_PDMD;
const uint16_t Rw11CntlDEUNA::kPCMD_HALT;
const uint16_t Rw11CntlDEUNA::kPCMD_STOP;

const uint16_t Rw11CntlDEUNA::kPR1_M_XPWR;
const uint16_t Rw11CntlDEUNA::kPR1_M_ICAB;
const uint16_t Rw11CntlDEUNA::kPR1_M_PCTO;
const uint16_t Rw11CntlDEUNA::kPR1_M_DELUA;  
const uint16_t Rw11CntlDEUNA::kPR1_M_STATE;

const uint16_t Rw11CntlDEUNA::kSTATE_RESET;  
const uint16_t Rw11CntlDEUNA::kSTATE_PLOAD;
const uint16_t Rw11CntlDEUNA::kSTATE_READY;
const uint16_t Rw11CntlDEUNA::kSTATE_RUN;
const uint16_t Rw11CntlDEUNA::kSTATE_UHALT;
const uint16_t Rw11CntlDEUNA::kSTATE_NHALT;
const uint16_t Rw11CntlDEUNA::kSTATE_NUHALT;
const uint16_t Rw11CntlDEUNA::kSTATE_PHALT;
const uint16_t Rw11CntlDEUNA::kSTATE_SLOAD;

const uint16_t Rw11CntlDEUNA::kPC0_M_FUNC;
const uint16_t Rw11CntlDEUNA::kPC0_M_MBZ;

const uint16_t Rw11CntlDEUNA::kFUNC_NOOP;
const uint16_t Rw11CntlDEUNA::kFUNC_RDPA;
const uint16_t Rw11CntlDEUNA::kFUNC_RPA;
const uint16_t Rw11CntlDEUNA::kFUNC_WPA;
const uint16_t Rw11CntlDEUNA::kFUNC_RMAL;
const uint16_t Rw11CntlDEUNA::kFUNC_WMAL;
const uint16_t Rw11CntlDEUNA::kFUNC_RRF;
const uint16_t Rw11CntlDEUNA::kFUNC_WRF;
const uint16_t Rw11CntlDEUNA::kFUNC_RCTR;
const uint16_t Rw11CntlDEUNA::kFUNC_RCCTR;
const uint16_t Rw11CntlDEUNA::kFUNC_RMODE;
const uint16_t Rw11CntlDEUNA::kFUNC_WMODE;
const uint16_t Rw11CntlDEUNA::kFUNC_RSTAT;
const uint16_t Rw11CntlDEUNA::kFUNC_RCSTAT;
const uint16_t Rw11CntlDEUNA::kFUNC_RSID;
const uint16_t Rw11CntlDEUNA::kFUNC_WSID;

const uint16_t Rw11CntlDEUNA::kSTAT_M_ERRS;
const uint16_t Rw11CntlDEUNA::kSTAT_M_MERR;
const uint16_t Rw11CntlDEUNA::kSTAT_M_BABL;
const uint16_t Rw11CntlDEUNA::kSTAT_M_CERR;
const uint16_t Rw11CntlDEUNA::kSTAT_M_TMOT;
const uint16_t Rw11CntlDEUNA::kSTAT_M_RRNG;
const uint16_t Rw11CntlDEUNA::kSTAT_M_TRNG;
const uint16_t Rw11CntlDEUNA::kSTAT_M_PTCH;
const uint16_t Rw11CntlDEUNA::kSTAT_M_RRAM;
const uint16_t Rw11CntlDEUNA::kSTAT_M_RREV;

const uint16_t Rw11CntlDEUNA::kMODE_M_PROM;
const uint16_t Rw11CntlDEUNA::kMODE_M_ENAL;
const uint16_t Rw11CntlDEUNA::kMODE_M_DRDC;
const uint16_t Rw11CntlDEUNA::kMODE_M_TPAD;
const uint16_t Rw11CntlDEUNA::kMODE_M_ECT;
const uint16_t Rw11CntlDEUNA::kMODE_M_DMNT;
const uint16_t Rw11CntlDEUNA::kMODE_M_INTL;
const uint16_t Rw11CntlDEUNA::kMODE_M_DTCR;
const uint16_t Rw11CntlDEUNA::kMODE_M_LOOP;
const uint16_t Rw11CntlDEUNA::kMODE_M_HDPX;
const uint16_t Rw11CntlDEUNA::kMODE_M_MBZ_DEUNA;
const uint16_t Rw11CntlDEUNA::kMODE_M_MBZ_DELUA;

const uint16_t Rw11CntlDEUNA::kTXR2_M_OWN;
const uint16_t Rw11CntlDEUNA::kTXR2_M_ERRS;
const uint16_t Rw11CntlDEUNA::kTXR2_M_MTCH;
const uint16_t Rw11CntlDEUNA::kTXR2_M_MORE;
const uint16_t Rw11CntlDEUNA::kTXR2_M_ONE;
const uint16_t Rw11CntlDEUNA::kTXR2_M_DEF;
const uint16_t Rw11CntlDEUNA::kTXR2_M_STF;
const uint16_t Rw11CntlDEUNA::kTXR2_M_ENF;
const uint16_t Rw11CntlDEUNA::kTXR2_M_SEGB;
const uint16_t Rw11CntlDEUNA::kTXR3_M_BUFL;
const uint16_t Rw11CntlDEUNA::kTXR3_M_UBTO;
const uint16_t Rw11CntlDEUNA::kTXR3_M_UFLO;
const uint16_t Rw11CntlDEUNA::kTXR3_M_LCOL;
const uint16_t Rw11CntlDEUNA::kTXR3_M_LCAR;
const uint16_t Rw11CntlDEUNA::kTXR3_M_RTRY;
const uint16_t Rw11CntlDEUNA::kTXR3_M_TDR;

const uint16_t Rw11CntlDEUNA::kRXR2_M_OWN;
const uint16_t Rw11CntlDEUNA::kRXR2_M_ERRS;
const uint16_t Rw11CntlDEUNA::kRXR2_M_FRAM;
const uint16_t Rw11CntlDEUNA::kRXR2_M_OFLO;
const uint16_t Rw11CntlDEUNA::kRXR2_M_CRC;
const uint16_t Rw11CntlDEUNA::kRXR2_M_STF;
const uint16_t Rw11CntlDEUNA::kRXR2_M_ENF;
const uint16_t Rw11CntlDEUNA::kRXR2_M_SEGB;
const uint16_t Rw11CntlDEUNA::kRXR3_M_BUFL;
const uint16_t Rw11CntlDEUNA::kRXR3_M_UBTO;
const uint16_t Rw11CntlDEUNA::kRXR3_M_NCHN;
const uint16_t Rw11CntlDEUNA::kRXR3_M_OVRN;
const uint16_t Rw11CntlDEUNA::kRXR3_M_MLEN;

const uint32_t Rw11CntlDEUNA::kUBA_M;  
const uint32_t Rw11CntlDEUNA::kUBAODD_M;  
const uint16_t Rw11CntlDEUNA::kDimMcast;
const uint16_t Rw11CntlDEUNA::kDimCtrDeuna;
const uint16_t Rw11CntlDEUNA::kDimCtrDelua;
const uint16_t Rw11CntlDEUNA::kDimCtr;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlDEUNA::Rw11CntlDEUNA()
  : Rw11CntlBase<Rw11UnitDEUNA,1>("deuna"),
    fPC_rdpr0(0),
    fPC_rdpcb(0),
    fPC_lapcb(0),
    fPC_rdtxdsccur(0),
    fPC_latxdsccur(0),
    fPC_rdtxdscnxt(0),
    fPC_latxdscnxt(0),
    fPC_rdrxdsccur(0),
    fPC_larxdsccur(0),
    fPC_rdrxdscnxt(0),
    fPcbbValid(false),
    fPcbb(0),
    fPcb{},
    fRingValid(false),
    fTxRingBase(0),
    fTxRingSize(0),
    fTxRingELen(0),
    fRxRingBase(0),
    fRxRingSize(0),
    fRxRingELen(0),
    fMacDefault(RethTools::String2Mac("08:00:2b:00:00:00")),
    fPr0Last(0),
    fPr1Pcto(false),
    fPr1Delua(false),
    fPr1State(kSTATE_RESET),
    fRunning(false),
    fMode(0),
    fStatus(0),
    fTxRingIndex(0),
    fRxRingIndex(0),
    fTxDscCurPC{},
    fTxDscNxtPC{},
    fRxDscCurPC{},
    fRxDscNxtPC{},
    fTxRingState(kStateTxIdle),
    fTxDscCur{},
    fTxDscNxt{},
    fTxBuf(),
    fTxBufOffset(0),
    fRxRingState(kStateRxIdle),
    fRxDscCur{},
    fRxDscNxt{},
    fRxPollTime(0.01),
    fRxQueLimit(1000),
    fRxPollTimer(),
    fRxBufQueue(),
    fRxBufCurr(),
    fRxBufOffset(0)
{
  // must be here because Units have a back-ptr (not available at Rw11CntlBase)
  fspUnit[0].reset(new Rw11UnitDEUNA(this, 0)); // single unit controller

  ClearMacList();
  ClearCtr();

  // setup fStats
  fStats.Define(kStatNPcmdNoop   , "NPcmdNoop"   , "pcmd NOOP (spurious)");
  fStats.Define(kStatNPcmdGetpcbb, "NPcmdGetpcbb", "pcmd GETPCBB");
  fStats.Define(kStatNPcmdGetcmd , "NPcmdGetcmd" , "pcmd GETCMD");
  fStats.Define(kStatNPcmdSelftst, "NPcmdSelftst", "pcmd SELFTST");
  fStats.Define(kStatNPcmdStart  , "NPcmdStart"  , "pcmd START");
  fStats.Define(kStatNPcmdPdmd   , "NPcmdPdmd"   , "pcmd PDMD");
  fStats.Define(kStatNPcmdStop   , "NPcmdStop"   , "pcmd STOP");
  fStats.Define(kStatNPcmdHalt   , "NPcmdHalt"   , "pcmd HALT");
  fStats.Define(kStatNPcmdRsrvd  , "NPcmdRsrvd"  , "pcmd reserved");
  fStats.Define(kStatNPcmdUimpl  , "NPcmdUimpl"  , "pcmd not implemented");
  fStats.Define(kStatNPcmdWBPdmd , "NPcmdWBPdmd" , "pcmd write w/ busy: pdmd");
  fStats.Define(kStatNPcmdWBOther, "NPcmdWBOther", "pcmd write w/ busy: other");
  fStats.Define(kStatNPdmdRestart, "NPdmdRestart", "pcmd pdmd restart");
  fStats.Define(kStatNFuncNoop   , "NFuncNoop"   , "func NOOP");
  fStats.Define(kStatNFuncRdpa   , "NFuncRdpa"   , "func RDPA");
  fStats.Define(kStatNFuncRpa    , "NFuncRpa"    , "func PRA");
  fStats.Define(kStatNFuncWpa    , "NFuncWpa"    , "func WPA");
  fStats.Define(kStatNFuncRmal   , "NFuncRmal"   , "func RMAL");
  fStats.Define(kStatNFuncWmal   , "NFuncWmal"   , "func WMAL");
  fStats.Define(kStatNFuncRrf    , "NFuncRrf"    , "func RRF");
  fStats.Define(kStatNFuncWrf    , "NFuncWrf"    , "func WRF");
  fStats.Define(kStatNFuncRctr   , "NFuncRctr"   , "func RCTR");
  fStats.Define(kStatNFuncRcctr  , "NFuncRcctr"  , "func RCCTR");
  fStats.Define(kStatNFuncRmode  , "NFuncRmode"  , "func RMODE");
  fStats.Define(kStatNFuncWmode  , "NFuncWmode"  , "func WMODE");
  fStats.Define(kStatNFuncRstat  , "NFuncRstat"  , "func RSTAT");
  fStats.Define(kStatNFuncRcstat , "NFuncRcstat" , "func RCSTAT");
  fStats.Define(kStatNFuncRsid   , "NFuncRsid"   , "func RSID");
  fStats.Define(kStatNFuncWsid   , "NFuncWsid"   , "func WSID");
  fStats.Define(kStatNFuncUimpl  , "NFuncUimpl"  , "func not implemented");
  fStats.Define(kStatNRxFraSeen  , "NRxFraSeen"  , "in frames seen");
  fStats.Define(kStatNRxFraFDst  , "NRxFraFDst"  , "in frames match dst mac");
  fStats.Define(kStatNRxFraFBcast, "NRxFraFBcast", "in frames match bcast");
  fStats.Define(kStatNRxFraFMcast, "NRxFraFMcast", "in frames match mcast");
  fStats.Define(kStatNRxFraFProm , "NRxFraFProm" , "in frames promiscous");
  fStats.Define(kStatNRxFraFUDrop, "NRxFraFUDrop", "in frames drop miss mac");
  fStats.Define(kStatNRxFraFMDrop, "NRxFraFMDrop", "in frames drop miss mcast");
  fStats.Define(kStatNRxFraQLDrop, "NRxFraQLDrop", "in frames drop drop");
  fStats.Define(kStatNRxFraNRDrop, "NRxFraNRDrop", "in frames drop not running");
  fStats.Define(kStatNRxFra      , "NRxFra"      , "rcvd frames");
  fStats.Define(kStatNRxFraMcast , "NRxFraMcast" , "rcvd bcast+mcast frames");
  fStats.Define(kStatNRxFraBcast , "NRxFraBcast" , "rcvd bcast frames");
  fStats.Define(kStatNRxByt      , "NRxByt"      , "rcvd bytes");
  fStats.Define(kStatNRxBytMcast , "NRxBytMcast" , "rcvd mcast bytes");
  fStats.Define(kStatNRxFraLoInt , "NRxFraLoInt" , "lost frames int err ");
  fStats.Define(kStatNRxFraLoBuf , "NRxFraLoBuf" , "lost frames buffer");
  fStats.Define(kStatNRxFraPad   , "NRxFraPad"   , "rcvd padded frames");
  fStats.Define(kStatNTxFra      , "NTxFra"      , "xmit frames");
  fStats.Define(kStatNTxFraMcast , "NTxFraMcast" , "xmit bcast+mcast frames");
  fStats.Define(kStatNTxFraBcast , "NTxFraBcast" , "xmit bcast frames");
  fStats.Define(kStatNTxByt      , "NTxByt"      , "xmit bytes");
  fStats.Define(kStatNTxBytMcast , "NTxBytMcast" , "xmit mcast bytes");
  fStats.Define(kStatNTxFraAbort , "NTxFraAbort" , "xmit aborted frames");
  fStats.Define(kStatNTxFraPad   , "NTxFraPad"   , "xmit padded frames");
  fStats.Define(kStatNFraLoop    , "NFraLoop"    , "loopback frames");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11CntlDEUNA::~Rw11CntlDEUNA()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDEUNA::Config(const std::string& name, uint16_t base, int lam)
{
  ConfigCntl(name, base, lam, kProbeOff, kProbeInt, kProbeRem);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDEUNA::Start()
{
  if (fStarted || fLam<0 || !fEnable || !fProbe.Found())
    throw Rexception("Rw11CntlDEUNA::Start",
                     "Bad state: started, no lam, not enabled, not found");
  
  // add device register address ibus and rbus mappings
  // done here because now Cntl bound to Cpu and Cntl probed
  Cpu().AllIAddrMapInsert(Name()+".pr0", Base() + kPR0);
  Cpu().AllIAddrMapInsert(Name()+".pr1", Base() + kPR1);
  Cpu().AllIAddrMapInsert(Name()+".pr2", Base() + kPR2);
  Cpu().AllIAddrMapInsert(Name()+".pr3", Base() + kPR3);

  // setup primary info clist
  SetupPrimClist();

  // ensure unit status is initialized
  fPr1State = kSTATE_READY;
  UnitSetupAll();

  // add attn handler
  Server().AddAttnHandler(bind(&Rw11CntlDEUNA::AttnHandler, this, _1), 
                          uint16_t(1)<<fLam, this);
  fStarted = true;

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDEUNA::UnitSetup(size_t /*ind*/)
{
  Cpu().ExecWibr(fBase+kPR1, GetPr1());
  // FIXME_code !!! Is that all ???
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDEUNA::SetType(const std::string& type)
{
  if (fPr1State != kSTATE_READY || fspUnit[0]->HasVirt())
    throw Rexception("Rw11CntlDEUNA::SetType", 
                     string("Bad state: not in READY state or attached"));

  if (type == "deuna") {
    fPr1Delua = false;
  } else if (type == "delua") {
    fPr1Delua = true;
  } else {
    throw Rexception("Rw11CntlDEUNA::SetType",
                     string("Bad args: only deuna or delua supported"));
  }
  fType = type;
  UnitSetup(0);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
//  allow xx:xx:xx:xx:xx:xx
//        random        --> random mac, with 1st bit=0; 2nd bit=1 (LAA)
//        dec:xx:xx:xx  --> 08:00:0b:xx:xx:xx --> DEC OUI
//        retro::xx     --> 52:65:74:72:6f:xx --> ascii 'Retro'
//          'R' = 52 -> 2nd bit = 1 -> locally administered address

void Rw11CntlDEUNA::SetMacDefault(const std::string& mac)
{
  string machex = mac;
  uint64_t bmac;
  const uint64_t macbit1 = 0x1;
  const uint64_t macbit2 = 0x2;

  if (mac == "random") {
    int fd = ::open("/dev/urandom",O_RDONLY);
    if (fd < 0)
      throw Rexception("Rw11CntlDEUNA::SetMacDefault",
                       "open() for '/dev/urandom' failed: ", errno);
    
    if (::read(fd, &bmac, sizeof(bmac)) != sizeof(bmac)) {
      int rd_errno = errno;
      ::close(fd);
      throw Rexception("Rw11CntlDEUNA::SetMacDefault",
                       "read() for '/dev/random' failed: ", rd_errno);
    }
    bmac &= ~macbit1;                       // ensure bcast bit is clear
    bmac |=  macbit2;                       // ensure laa   bit is set
    ::close(fd);

  } else {
    if (mac.substr(0,4) == "dec:") {
      machex  = "08:00:0b:";                  // DEC OUI
      machex += mac.substr(4);
    } else if (mac.substr(0,6) == "retro:") {
      machex  = "52:65:74:72:6f:";            // ascii 'Retro'; 52 -> LAA
      machex += mac.substr(6);
    }

    bmac = RethTools::String2Mac(machex);
  }
  
  if (bmac & macbit1) 
    throw Rexception("Rw11CntlDEUNA::SetMacDefault", 
                     string("Bad args: mcast address given, lsb not 0"));
  if (fPr1State == kSTATE_READY &&          // if not running
      (!fspUnit[0]->HasVirt()) &&           // and not attached
      fMacList[0] == fMacDefault) {         // and old pa was old dpa
    fMacList[0] = bmac;                     // update also pa !
  }
  fMacDefault = bmac;                       // and always dpa !
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDEUNA::SetRxPollTime(const Rtime& time)
{
  if (!time.IsPositive()) 
    throw Rexception("Rw11CntlDEUNA::SetRxPollTime", 
                     string("Bad args: time <= 0"));
  fRxPollTime = time;
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDEUNA::SetRxQueLimit(size_t rxqlim)
{
  if (rxqlim <= 0) 
    throw Rexception("Rw11CntlDEUNA::SetRxQueLimit", 
                     string("Bad args: rxqlim <= 0"));
  fRxQueLimit = rxqlim;
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs

std::string Rw11CntlDEUNA::MacDefault() const
{
  return RethTools::Mac2String(fMacDefault);
}

//--------------------------------------+-----------------------------------
//! FIXME_docs

const char* Rw11CntlDEUNA::MnemoPcmd(uint16_t pcmd) const
{
  static const char* mnemopcmd[16] = {"noop  ","getpcb","getcmd","slftst",
                                      "start ","boot  ","rsrv06","rsrv07",
                                      "pdmd  ","rsrv11","rsrv12","rsrv13",
                                      "rsrv14","rsrv15","halt  ","stop  "};
  if (pcmd >= 16) return "??????";
  return mnemopcmd[pcmd];
}

//--------------------------------------+-----------------------------------
//! FIXME_docs

const char* Rw11CntlDEUNA::MnemoFunc(uint16_t func) const
{
  static const char* mnemofunc[32] = {"noop  ","uimp01","rdpa  ","noop03",
                                      "rpa   ","wpa   ","rmal  ","wmal  ",
                                      "rrf   ","wrf   ","rctr  ","rcctr ",
                                      "rmode ","wmode ","rstat ","rcstat",
                                      "uimp20","uimp21","rsid  ","wsid  ",
                                      "uimp24","uimp25","uimp26","uimp27",
                                      "uimp30","uimp31","uimp32","uimp33",
                                      "uimp34","uimp35","uimp36","uimp37"};
  if (func >= 32) return "??????";
  return mnemofunc[func];
}

//--------------------------------------+-----------------------------------
//! FIXME_docs

const char* Rw11CntlDEUNA::MnemoState(uint16_t state) const
{
  static const char* mnemostate[16] = {"reset ","pload ","ready ","run   ",
                                       "rsrv04","uhalt ","nhalt ","nuhalt",
                                       "phalt ","rsrv11","rsrv12","rsrv13",
                                       "rsrv14","rsrv15","rsrv16","sload "};
  if (state >= 16) return "??????";
  return mnemostate[state];
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11CntlDEUNA::RcvCallback(RethBuf::pbuf_t& pbuf)
{
  // lock connect to protect rxqueue
  lock_guard<RlinkConnect> lock(Connect());

  fStats.Inc(kStatNRxFraSeen);
  if (!Running()) {                         // drop if not running
    fStats.Inc(kStatNRxFraNRDrop);
    return true;
  }

  uint64_t macdst = pbuf->MacDestination();
  int matchdst = MacFilter(macdst);

  if (matchdst < 0) {                       // not matched ?
    if (fMode & kMODE_M_PROM) {               // promiscous mode
      fStats.Inc(kStatNRxFraFProm);             // count and accept
    } else {                                  // otherwise drop
      if (matchdst & 0x1) {                     // mcast address 
        fStats.Inc(kStatNRxFraFMDrop);
      } else {
        fStats.Inc(kStatNRxFraFUDrop);
      }
      if (fTraceLevel>1) {
        RlogMsg lmsg(LogFile());
        lmsg << "-I " << Name() << ": fdrop " << pbuf->FrameInfo() << endl;
      }
      return true;
    }
  } else {                                  // machted
    if (matchdst == 0) {
      fStats.Inc(kStatNRxFraFDst);
    } else if (matchdst == 1) {
      fStats.Inc(kStatNRxFraFBcast);
    } else {
      fStats.Inc(kStatNRxFraFMcast);
    }
  }

  if (fRxBufQueue.size() >= fRxQueLimit) {  // drop if queue too long
    fStats.Inc(kStatNRxFraQLDrop);
    if (fTraceLevel>0) {
      RlogMsg lmsg(LogFile());
      lmsg << "-I " << Name() << ": qdrop " << pbuf->FrameInfo() << endl;
    }
    return true;
  }

  fRxBufQueue.push_back(pbuf);

  // FIXME_code: can we (should we) use last cached dscs ???
  if (fTxRingState == kStateTxIdle) StartRxRing();

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDEUNA::Dump(std::ostream& os, int ind, const char* text,
                         int detail) const
{
  // lock connect to protect, e.g fRxBufQueue access
  lock_guard<RlinkConnect> lock(Connect());

  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlDEUNA @ " << this << endl;
  os << bl << "  fPC_rdpr0:        " << fPC_rdpr0 << endl;
  os << bl << "  fPC_rdpcb:        " << fPC_rdpcb << endl;
  os << bl << "  fPC_lapcb:        " << fPC_lapcb << endl;
  os << bl << "  fPC_rdtxdsccur:   " << fPC_rdtxdsccur << endl;
  os << bl << "  fPC_latxdsccur:   " << fPC_latxdsccur << endl;
  os << bl << "  fPC_rdtxdscnxt:   " << fPC_rdtxdscnxt << endl;
  os << bl << "  fPC_latxdscnxt:   " << fPC_latxdscnxt << endl;
  os << bl << "  fPC_rdrxdsccur:   " << fPC_rdrxdsccur << endl;
  os << bl << "  fPC_larxdsccur:   " << fPC_larxdsccur << endl;
  os << bl << "  fPC_rdrxdscnxt:   " << fPC_rdrxdscnxt << endl;
  os << bl << "  fPcbbValid:       " << RosPrintf(fPcbbValid) << endl;
  os << bl << "  fPcbb:            " << RosPrintf(fPcbb,"o0", 6) << endl;
  os << bl << "  fPcb:            ";
  for (auto& v : fPcb) os << " " << RosPrintf(v,"o0", 6);
  os << endl;

  os << bl << "  fRingValid:       " << RosPrintf(fRingValid) << endl;
  os << bl << "  fTxRing format:   " << RosPrintf(fTxRingBase,"o0", 7) 
     << "," << RosPrintf(fTxRingSize,"d", 3) 
     << "," << RosPrintf(fTxRingELen,"d", 3) << endl;
  os << bl << "  fRxRing format:   " << RosPrintf(fRxRingBase,"o0", 7) 
     << "," << RosPrintf(fRxRingSize,"d", 3) 
     << "," << RosPrintf(fRxRingELen,"d", 3) << endl;

  os << bl << "  fMacDefault:      " 
     << RosPrintf(fMacDefault,"x0",12)   << "  "
     << RethTools::Mac2String(fMacDefault) << endl;
  os << bl << "  fMacList[0]:      " 
     << RosPrintf(fMacList[0],"x0",12) << "  "
     << RethTools::Mac2String(fMacList[0]) << endl;
  os << bl << "  fMacList[1]:      " 
     << RosPrintf(fMacList[1],"x0",12)  << "  "
     << RethTools::Mac2String(fMacList[1]) << endl;
  os << bl << "  fMacastCnt:       " << RosPrintf(fMcastCnt,"d", 2) << endl;
  for (int i=0; i<fMcastCnt; i++) {
    os << bl << "  fMacList[" << RosPrintf(i,"d",2) << "]:    " 
       << RosPrintf(fMacList[2+i],"x0",12)  << "  "
       << RethTools::Mac2String(fMacList[2+i]) << endl;
  }

  os << bl << "  fPr0Last*:       " << RosPrintf(fPr0Last,"o0", 6) << endl;
  os << bl << "  fPr1*:           " 
     << " Pcto="  << RosPrintf(fPr1Pcto)
     << " Delua=" << RosPrintf(fPr1Delua)
     << " State=" << RosPrintf(fPr1State,"o0", 2) << ":" << MnemoState(fPr1State)
     << " GetPr1()=" << RosPrintf(GetPr1(),"o0", 6) << endl;
  os << bl << "  fRunning:         " << RosPrintf(fRunning) << endl;
  os << bl << "  fMode:            " << RosPrintf(fMode,"o0", 6) << endl;
  os << bl << "  fStatus:          " << RosPrintf(fStatus,"o0", 6) << endl;

  os << bl << "  fTxRingIndex:     " << RosPrintf(fTxRingIndex,"d", 3) << endl;
  os << bl << "  fRxRingIndex:     " << RosPrintf(fRxRingIndex,"d", 3) << endl;
  os << bl << "  fTxDscCurPC:      " << RingDsc2String(fTxDscCurPC,'t') << endl;
  os << bl << "  fTxDscNxtPC:      " << RingDsc2String(fTxDscNxtPC,'t') << endl;
  os << bl << "  fRxDscCurPC:      " << RingDsc2String(fRxDscCurPC,'r') << endl;
  os << bl << "  fRxDscNxtPC:      " << RingDsc2String(fRxDscNxtPC,'r') << endl;
  os << bl << "  fTxRingState:     " << fTxRingState << endl;
  os << bl << "  fTxDscCur:        " << RingDsc2String(fTxDscCur,'t') << endl;
  os << bl << "  fTxDscNxt:        " << RingDsc2String(fTxDscNxt,'t') << endl;
  fTxBuf.Dump(os, ind+2, "fTxBuf:", detail);
  os << bl << "  fRxRingState:     " << fRxRingState << endl;
  os << bl << "  fRxDscCur:        " << RingDsc2String(fRxDscCur,'r') << endl;
  os << bl << "  fRxDscNxt:        " << RingDsc2String(fRxDscNxt,'r') << endl;

  os << bl << "  fRxPollTime:      " << fRxPollTime << endl;
  os << bl << "  fRxQueLimit:      " << RosPrintf(fRxQueLimit,"d", 4)  << endl;
  size_t rxquesize = fRxBufQueue.size();
  os << bl << "  fRxBufQueue.size: " << RosPrintf(rxquesize,"d", 4) << endl;
  for (size_t i=0; i<rxquesize; i++) {
    os << bl << "  fRxBufQueue[" << RosPrintf(i,"d", 4)
       << "]: " << fRxBufQueue[i]->FrameInfo() << endl;
  }
  if (fRxBufCurr) {
    fRxBufCurr->Dump(os, ind+2, "fRxBufCurr:", detail);
  } else {
    os << bl << "  fRxBufCurr:       " << "null" << endl;
  }
  os << bl << "  fCtrTimeCleared:  " 
     << RosPrintf(fCtrTimeCleared.Age(CLOCK_MONOTONIC),"f",10,2) << endl;
  os << bl << "  fCtrRxFra:        " 
     << RosPrintf(fCtrRxFra,"d",10) << endl;
  os << bl << "  fCtrRxFraMcast:   "
     << RosPrintf(fCtrRxFraMcast,"d",10) << endl;
  os << bl << "  fCtrRxByt:        "
     << RosPrintf(fCtrRxByt,"d",10) << endl;
  os << bl << "  fCtrRxBytMcast:   "
     << RosPrintf(fCtrRxBytMcast,"d",10) << endl;
  os << bl << "  fCtrRxFraLoInt:   "
     << RosPrintf(fCtrRxFraLoInt,"d",10) << endl;
  os << bl << "  fCtrRxFraLoBuf:   "
     << RosPrintf(fCtrRxFraLoBuf,"d",10) << endl;
  os << bl << "  fCtrTxFra:        "
     << RosPrintf(fCtrTxFra,"d",10) << endl;
  os << bl << "  fCtrTxFraMcast:   "
     << RosPrintf(fCtrTxFraMcast,"d",10) << endl;
  os << bl << "  fCtrTxByt:        "
     << RosPrintf(fCtrTxByt,"d",10) << endl;
  os << bl << "  fCtrTxBytMcast:   "
     << RosPrintf(fCtrTxBytMcast,"d",10) << endl;
  os << bl << "  fCtrTxFraAbort:   "
     << RosPrintf(fCtrTxFraAbort,"d",10) << endl;
  os << bl << "  fCtrFramesLoop:   "
     << RosPrintf(fCtrFraLoop,"d",10) << endl;
  Rw11CntlBase<Rw11UnitDEUNA,1>::Dump(os, ind, " ^", detail);
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs

// summary of log entry
// handler lines
// -I xua: cmd pr0=oooooo rset=b brst=b
// -I xua: cmd pr0=000110 cmd=......
// -I xua: cmd pr0=000110 cmd=pdmd   t00,OSE,OSE r00,OSE,OSE
// -I xua: cmd pr0=oooooo cmd=getcmd fu=...... udbb=oooooo
// -I xua: txr t00 < dddd,oooooo,dddd; bbbbbbbb,bbbb: OSE, ...
// -I xua: snd 00:00:00:00:00:00 > 00:00:00:00:00:00 typ: xxxx len: dddd
// command specific lines
// -I xua: GETPCBB: oooooo
// -I xua: RPA: 08:00:2b:00:00:00
// -I xua: WRF: tx base=oooooo size=dd elen=dd; rx base=oooooo size=dd elen=dd
// -I xua: WMODE: mode=oooooo


int Rw11CntlDEUNA::AttnHandler(RlinkServer::AttnArgs& args)
{
  fStats.Inc(kStatNAttnHdl);

  Rw11Cpu& cpu = Cpu();
  if (fPC_rdtxdsccur > 0) {                   // txdsc read update, if setup
    cpu.ModLalh(fPrimClist, fPC_rdtxdsccur, TxRingDscAddr(fTxRingIndex),
                Rw11Cpu::kCPAH_M_UBM22);
    cpu.ModLalh(fPrimClist, fPC_rdtxdscnxt, TxRingDscAddr(TxRingIndexNext()),
                Rw11Cpu::kCPAH_M_UBM22);
    cpu.ModLalh(fPrimClist, fPC_rdrxdsccur, RxRingDscAddr(fRxRingIndex),
                Rw11Cpu::kCPAH_M_UBM22);
    cpu.ModLalh(fPrimClist, fPC_rdrxdscnxt, RxRingDscAddr(RxRingIndexNext()),
                Rw11Cpu::kCPAH_M_UBM22);
  }

  Server().GetAttnInfo(args, fPrimClist);
  // FIXME_code: handle pcb and txdsc read errors ...

  fPr0Last = fPrimClist[fPC_rdpr0].Data();

  bool     rset  = fPr0Last & kPR0_M_RSET;
  bool     brst  = fPr0Last & kPR0_M_BRST;
  uint16_t pcmd  = (fPr0Last>>kPR0_V_PCMDBP) & kPR0_B_PCMDBP;

  // check for pcmd write while busy
  if (fPr0Last & kPR0_M_PCWWB) {
    uint16_t pcmdwwb  = fPr0Last & kPR0_M_PCMD;
    if (pcmdwwb == kPCMD_PDMD) {
      fStats.Inc(kStatNPcmdWBPdmd);
    } else {
      fStats.Inc(kStatNPcmdWBOther);
      RlogMsg lmsg(LogFile());
      lmsg << "-E " << Name() << ": pcmd write w/ busy"
           << " pr0=" << RosPrintBvi(fPr0Last,8)
           << " pcmd-1st=" << MnemoPcmd(pcmd)
           << " pcmd-2nd=" << MnemoPcmd(pcmdwwb);
    }
  }
  // check for pcmd  pdmd while busy restarts
  if (fPr0Last & kPR0_M_PDMDWB) {
    fStats.Inc(kStatNPdmdRestart);
  }

  RlinkCommandList clist;

  fPr1Pcto = false;
  uint16_t pr0out = 0;

  // handle bus and software reset: stop runnig, poll for RingHandler run-down
  if (rset || brst) {
    if (fTraceLevel>0) {
      RlogMsg lmsg(LogFile());
      lmsg << "-I " << Name() << ": cmd"
           << " pr0=" << RosPrintBvi(fPr0Last,8)
           << " rset=" << rset << " brst=" << brst;
    }
    Reset();
    if (rset) pr0out |= kPR0_M_RSET|kPR0_M_DNI;
    if (brst) pr0out |= kPR0_M_BRST;
    cpu.AddWibr(clist, fBase+kPR1, GetPr1());
    cpu.AddWibr(clist, fBase+kPR0, pr0out);
    Server().Exec(clist);
    return 0;
  }

  if (fTraceLevel>0) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I " << Name() << ": cmd"
         << " pr0=" << RosPrintBvi(fPr0Last,8)
         << " r=" << rset << "," << brst
         << " cmd=" << MnemoPcmd(pcmd);

    if (pcmd == kPCMD_GETCMD && fPC_rdpcb > 0) { // if GETCMD and pdb loaded
      uint16_t func = fPcb[0] & kPC0_M_FUNC;
      lmsg << " fu=" << MnemoFunc(func);

      if (func == kFUNC_RMAL || func == kFUNC_WMAL || // if func with udbb
          func == kFUNC_RRF  || func == kFUNC_WRF ||
          func == kFUNC_RCTR || func == kFUNC_RCCTR ||
          func == kFUNC_RSID || func == kFUNC_WSID) {
        uint32_t udbb = 0777777;
        Wlist2UBAddr(&fPcb[1], udbb);
        lmsg << " udbb=" << RosPrintf(udbb&kUBA_M,"o0", 6);
      }
    }
    if (pcmd == kPCMD_PDMD && fPC_rdtxdsccur > 0) { // PDMD and txdsc ect loaded
      lmsg << " t" << RosPrintf(fTxRingIndex,"d0", 2)
           << ","  << RingDsc2OSEString(fTxDscCurPC,'-')
           << ","  << RingDsc2OSEString(fTxDscNxtPC,'-')
           << " r" << RosPrintf(fRxRingIndex,"d0", 2)
           << ","  << RingDsc2OSEString(fRxDscCurPC,'-')
           << ","  << RingDsc2OSEString(fRxDscNxtPC,'-');
    }
  }

  switch (pcmd) {
  case kPCMD_NOOP:                          // NOOP --------------------------
    fStats.Inc(kStatNPcmdNoop);
    return 0;                                 // fully handled in FPGA
    
  case kPCMD_GETPCBB:                       // GETPCBB -----------------------
    {
      fStats.Inc(kStatNPcmdGetpcbb);
      size_t ipr2 = cpu.AddRibr(clist, fBase+kPR2);
      size_t ipr3 = cpu.AddRibr(clist, fBase+kPR3);
      cpu.AddWibr(clist, fBase+kPR1, GetPr1());
      cpu.AddWibr(clist, fBase+kPR0, kPR0_M_DNI);
      Server().Exec(clist);
      fPcbb = ( uint32_t(clist[ipr2].Data()) |
               (uint32_t(clist[ipr3].Data())<<16)) & kUBA_M; // 17:01 valid!
      fPcbbValid = true;
      SetupPrimClist();
      if (fTraceLevel>0) {
        RlogMsg lmsg(LogFile());
        lmsg << "-I " << Name() << ": GETPCBB: " << RosPrintBvi(fPcbb,8,18);
      }
    }
    return 0;

  case kPCMD_GETCMD:                        // GETCMD ------------------------
    {
      fStats.Inc(kStatNPcmdGetcmd);
      bool ok = ExecGetcmd(clist);
      pr0out |= ok ? kPR0_M_DNI : kPR0_M_PCEI;
    }
    break;

  case kPCMD_SELFTST:                       // SELFTST -----------------------
    {
      fStats.Inc(kStatNPcmdSelftst);
      Reset();                                // handle like reset 
      pr0out   |= kPR0_M_DNI;
    }
    return 0;

  case kPCMD_START:                         // START -------------------------
    {
      fStats.Inc(kStatNPcmdStart);
      if (fPr1State == kSTATE_RUN) {          // start while running is a noop 
        pr0out |= kPR0_M_DNI;
        break;
      }
      if (fPr1State == kSTATE_READY && fRingValid) { // in _READY and ring ok
        SetRunning(true);
        pr0out |= kPR0_M_DNI;
      } else {
        pr0out |= kPR0_M_PCEI;
      }
    }
    break;

  case kPCMD_BOOT:                          // BOOT --------------------------
    {
      fStats.Inc(kStatNPcmdUimpl);            // not implemented ... 
      pr0out |= kPR0_M_PCEI;
    }
    break;

  case kPCMD_PDMD:                          // PDMD --------------------------
    {
      fStats.Inc(kStatNPcmdPdmd);
      if (Running()) {
        StartTxRing(fTxDscCurPC, fTxDscNxtPC);
        StartRxRing(fRxDscCurPC, fRxDscNxtPC);        
      }
      pr0out |= kPR0_M_DNI;
    }
    break;

  case kPCMD_HALT:                          // HALT --------------------------
    {
      if (fPr1Delua) {
        fStats.Inc(kStatNPcmdHalt);           // defined for DELUA
        SetRunning(false);
        fPr1State = kSTATE_PHALT;             // ends in dead end state
      } else {
        fStats.Inc(kStatNPcmdRsrvd);
      }
      pr0out |= kPR0_M_DNI;                 // always DNI it (is noop on DEUNA)
    }
    break;

  case kPCMD_STOP:                          // STOP --------------------------
    {
      fStats.Inc(kStatNPcmdStop);
      if (fPr1State == kSTATE_RUN) {          // stop if in _RUN, noop otherwise
        SetRunning(false);
      }
      pr0out |= kPR0_M_PCEI;
    }
    break;

  default:                                  // all others are reserved codes
    {
      fStats.Inc(kStatNPcmdRsrvd);
      pr0out |= kPR0_M_DNI;
    }
    break;
  }

  cpu.AddWibr(clist, fBase+kPR1, GetPr1());
  cpu.AddWibr(clist, fBase+kPR0, pr0out);
  Server().Exec(clist);
  return 0;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDEUNA::ClearMacList()
{
  for (auto& mac : fMacList) mac = 0;
  fMacList[0] = fMacDefault;
  fMacList[1] = 0xffffffffffff;  
  fMcastCnt = 0;
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDEUNA::ClearCtr()
{
  fCtrTimeCleared.GetClock(CLOCK_MONOTONIC);
  fCtrRxFra      = 0;
  fCtrRxFraMcast = 0;
  fCtrRxByt      = 0;
  fCtrRxBytMcast = 0;
  fCtrRxFraLoInt = 0;
  fCtrRxFraLoBuf = 0;
  fCtrTxFra      = 0;
  fCtrTxFraMcast = 0;
  fCtrTxByt      = 0;
  fCtrTxBytMcast = 0;
  fCtrTxFraAbort = 0;
  fCtrFraLoop    = 0;
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDEUNA::ClearStatus()
{
  fStatus = 0;                              // lsb is 0 anyway. so clear all
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::Reset()
{
  fRunning     = false;                     // end running
  StopTxRing();                             // run-down tx ring
  StopRxRing();                             // run-down rx ring
  fPcbbValid   = false;                     // clear state
  fPcbb        = 0;
  fRingValid   = false;
  fTxRingBase  = 0;
  fTxRingSize  = 0;
  fTxRingELen  = 0;
  fRxRingBase  = 0;
  fRxRingSize  = 0;
  fRxRingELen  = 0;
  fTxRingIndex = 0;
  fRxRingIndex = 0;
  fMacList[0]  = fMacDefault;
  fMcastCnt    = 0;
  fPr1Pcto     = false;
  fPr1State    = kSTATE_READY;
  SetupPrimClist();
  ClearStatus();
  ClearCtr();
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::SetRunning(bool run)
{
  if (fRunning == run) return;
  if (run) {                                // start
    if (! fRxPollTimer.IsOpen()) {            // start poll timer if needed 
      fRxPollTimer.Open();
      Server().AddPollHandler([this](const pollfd& pfd)
                                { return RxPollHandler(pfd); }, 
                              fRxPollTimer.Fd(), POLLIN);
    }

    fRunning  = true;
    fPr1State = kSTATE_RUN;
    fTxRingIndex = 0;
    fTxBufOffset = 0;
    fRxRingIndex = 0;
    fRxBufOffset = 0;

    StartTxRing();
    StartRxRing();

  } else {                                  // stop
    fRunning  = false;
    StopTxRing();
    StopRxRing();
    fPr1State = kSTATE_READY;
  }

  SetupPrimClist();
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
bool Rw11CntlDEUNA::ExecGetcmd(RlinkCommandList& clist)
{
  Rw11Cpu& cpu = Cpu();

  // FIXME_code: where is pcb read status checked ??
  if (fPC_rdpcb == 0) {                     // if pcb not available
    fPr1Pcto = true;
    return false;
  }

  uint16_t func = fPcb[0] & kPC0_M_FUNC;
  if (fPcb[0] & kPC0_M_MBZ) return false;

  uint32_t udbb;
  uint16_t pr2len;
  Wlist2UBAddrLen(&fPcb[1], udbb, pr2len);
  bool udbb_ok = (udbb & ~kUBA_M) == 0;

  switch (func) {
  case kFUNC_NOOP:                          // NOOP --------------------------
    fStats.Inc(kStatNFuncNoop);
    return true;

  case kFUNC_RDPA:                          // RDPA  -- read default mac -----
    {
      fStats.Inc(kStatNFuncRdpa);
      RethTools::Mac2WList(fMacDefault, &fPcb[1]);
      cpu.AddWMem(clist, fPcbb+2, &fPcb[1], 3, Rw11Cpu::kCPAH_M_UBM22, true);
      LogMacFunc("RDPA", fMacDefault);
      return true;
    }
    
  case kFUNC_RPA:                           // RPA -- read mac ---------------
    {
      fStats.Inc(kStatNFuncRpa);
      RethTools::Mac2WList(fMacList[0], &fPcb[1]);
      cpu.AddWMem(clist, fPcbb+2, &fPcb[1], 3, Rw11Cpu::kCPAH_M_UBM22, true);
      LogMacFunc("RPA", fMacList[0]);
      return true;
    }
    
  case kFUNC_WPA:                           // WPA -- write mac---------------
    {
      fStats.Inc(kStatNFuncWpa);
      uint64_t mac= RethTools::WList2Mac(&fPcb[1]);
      if (mac & 0x1) return false;              // lsb of MAC must be 0 
      fMacList[0] = mac;
      LogMacFunc("RPA", fMacList[0]);
      return true;
    }
    
  case kFUNC_RMAL:                          // RMAL -- read mcast list -------
    {
      fStats.Inc(kStatNFuncRmal);
      if (!udbb_ok) return false;
      uint16_t mltlen = pr2len;
      if (mltlen > kDimMcast) return false;
      if (mltlen == 0) return true;
      uint16_t udb[3*kDimMcast];
      for (int i=0; i<mltlen; i++) {
        RethTools::Mac2WList(fMacList[2+i], &udb[3*i]);
      }
      LogMcastFunc("RMAL");

      RlinkCommandList clist1;
      cpu.AddWMem(clist1, udbb, udb, 3*mltlen, Rw11Cpu::kCPAH_M_UBM22, true);
      Server().Exec(clist1);
      // FIXME_code: handle access errors
      return true;
    }

  case kFUNC_WMAL:                          // WMAL -- write mcast list ------
    {
      fStats.Inc(kStatNFuncWmal);
      if (!udbb_ok) return false;
      uint16_t mltlen = pr2len;
      if (mltlen > kDimMcast) return false;
      fMcastCnt = 0;
      for (int i=0; i<kDimMcast; i++) fMacList[2+i] = 0;
      if (mltlen == 0) return true;

      uint16_t udb[3*kDimMcast];
      RlinkCommandList clist1;
      cpu.AddRMem(clist1, udbb, udb, 3*mltlen, Rw11Cpu::kCPAH_M_UBM22, true);
      Server().Exec(clist1);
      // FIXME_code: handle access errors
      for (int i=0; i<mltlen; i++) {
        uint64_t mac = RethTools::WList2Mac(&udb[3*i]);
        if (!(mac & 0x1)) return false;  // FIXME_code: check needed? DELUA ?
        fMacList[2+i] = mac;
      }
      fMcastCnt = mltlen;
      LogMcastFunc("WMAL");

      return true;
    }

  case kFUNC_RRF:                           // RRF -- read ring format -------
    {
      fStats.Inc(kStatNFuncRrf);
      // FIXME_code: get correct MBZ test !!
      if (!udbb_ok) return false;             // pdb[2] length ignored
      uint16_t udb[6];
      UBAddrLen2Wlist(&udb[0], fTxRingBase, fTxRingELen);
      udb[2] = fTxRingSize;
      UBAddrLen2Wlist(&udb[3], fRxRingBase, fRxRingELen);
      udb[5] = fRxRingSize;
      LogRingFunc("RRF");

      RlinkCommandList clist1;
      cpu.AddWMem(clist1, udbb, udb, 6, Rw11Cpu::kCPAH_M_UBM22, true);
      Server().Exec(clist1);
      // FIXME_code: handle access errors
      return true;
    }

  case kFUNC_WRF:                           // WRF -- write ring format ------
    {
      fStats.Inc(kStatNFuncWrf);
      if (!udbb_ok) return false;             // pdb[2] length ignored
      uint16_t udb[6];
      RlinkCommandList clist1;
      cpu.AddRMem(clist1, udbb, udb, 6, Rw11Cpu::kCPAH_M_UBM22, true);
      Server().Exec(clist1);
      // FIXME_code: handle access errors
      uint32_t txbase, rxbase;
      uint16_t txelen, rxelen;
      uint16_t txsize, rxsize;
      Wlist2UBAddrLen(&udb[0], txbase, txelen);
      if (txbase & ~kUBA_M) return false;
      txsize = udb[2];
      if (txsize <= 1) return false;
      Wlist2UBAddrLen(&udb[3], rxbase, rxelen);
      if (rxbase & ~kUBA_M) return false;
      rxsize = udb[5];
      if (rxsize <= 1) return false;
      fRingValid  = true;
      fTxRingBase = txbase;
      fTxRingELen = txelen;
      fTxRingSize = txsize;
      fRxRingBase = rxbase;
      fRxRingELen = rxelen;
      fRxRingSize = rxsize;
      LogRingFunc("WRF");
      return true;
    }    

  case kFUNC_RCTR:                          // RCTR -- read counters ---------
  case kFUNC_RCCTR:                         // RCCTR -- read&clear counters --
    {
      fStats.Inc((func==kFUNC_RCCTR) ? kStatNFuncRcctr : kStatNFuncRctr);
      if ((!udbb_ok) || pr2len != 0) return false;  // pdb[2] length mbz
      uint16_t ctrlen = fPcb[3];
      if (ctrlen &0x1) return false;          // must be even
      if (ctrlen == 0) return true;           // nothing to do...
      uint16_t ctrmax = fPr1Delua ? kDimCtrDelua : kDimCtrDeuna;
      if (ctrlen > ctrmax) ctrlen = ctrmax;
 
      uint16_t udb[kDimCtr];
      for (auto& w : udb) w = 0;

      Rtime dt = Rtime(CLOCK_MONOTONIC) - fCtrTimeCleared;
      udb[ 0] = ctrlen;
      udb[ 1] = (dt.Sec() < 0xffff) ? uint16_t(dt.Sec()) : 0xffff;
      udb[ 2] =  fCtrRxFra      & 0xffff;
      udb[ 3] =  fCtrRxFra      >> 16;
      udb[ 4] =  fCtrRxFraMcast & 0xffff;
      udb[ 5] =  fCtrRxFraMcast >> 16;
      udb[ 8] =  fCtrRxByt      & 0xffff;
      udb[ 9] =  fCtrRxByt      >> 16;
      udb[10] =  fCtrRxBytMcast & 0xffff;
      udb[11] =  fCtrRxBytMcast >> 16;
      udb[12] =  fCtrRxFraLoInt;
      udb[13] =  fCtrRxFraLoBuf;
      udb[14] =  fCtrTxFra      & 0xffff;
      udb[15] =  fCtrTxFra      >> 16;
      udb[16] =  fCtrTxFraMcast & 0xffff;
      udb[17] =  fCtrTxFraMcast >> 16;
      udb[24] =  fCtrTxByt      & 0xffff;
      udb[25] =  fCtrTxByt      >> 16;
      udb[26] =  fCtrTxBytMcast & 0xffff;
      udb[27] =  fCtrTxBytMcast >> 16;
      udb[29] =  fCtrTxFraAbort;
      RlinkCommandList clist1;
      cpu.AddWMem(clist1, udbb, udb, ctrlen, Rw11Cpu::kCPAH_M_UBM22, true);
      Server().Exec(clist1);
      // FIXME_code: handle access errors
      if (func==kFUNC_RCCTR) ClearCtr();
      return true;
    }

  case kFUNC_RMODE:                         // RMODE -- read mode ------------
    {
      fStats.Inc(kStatNFuncRmode);
      fPcb[1] = fMode;
      cpu.AddWMem(clist, fPcbb+2, &fPcb[1], 1, Rw11Cpu::kCPAH_M_UBM22, true);
      LogFunc("RMODE", "mode", fMode);
      return true;
    }
    
  case kFUNC_WMODE:                         // WMODE -- write mode -----------
    {
      fStats.Inc(kStatNFuncWmode);
      uint16_t mbz = fPr1Delua ? kMODE_M_MBZ_DELUA : kMODE_M_MBZ_DEUNA;
      if (fPcb[1] & mbz) return false;
      fMode = fPcb[1];
      LogFunc("WMODE", "mode", fMode);
      return true;
    }
    
  case kFUNC_RSTAT:                         // RSTAT -- read status ----------
  case kFUNC_RCSTAT:                        // RCSTAT -- read&clear status ---
    {
      fStats.Inc((func==kFUNC_RCSTAT) ? kStatNFuncRcstat : kStatNFuncRstat);
      fPcb[1] = fStatus;
      fPcb[2] = Rtools::Bytes2Word(kDimMcast, fMcastCnt);
      fPcb[3] = fPr1Delua ? kDimCtrDelua : kDimCtrDeuna;
      cpu.AddWMem(clist, fPcbb+2, &fPcb[1], 3, Rw11Cpu::kCPAH_M_UBM22, true);
      LogFunc((func==kFUNC_RCSTAT) ? "RCSTAT" : "RSTAT", 
              "stat", fStatus, "mltlen", fMcastCnt);
      if (func==kFUNC_RCSTAT) ClearStatus();
      return true;
    }
    
  case kFUNC_RSID:                          // RSID -- read system ID --------
    {
      fStats.Inc(kStatNFuncRsid);
      if ((!udbb_ok) || pr2len != 0) return false;  // pdb[2] length mbz
      uint16_t pltlen = fPcb[3];
      if (pltlen &0x1) return false;          // must be even
      if (pltlen == 0) return true;           // nothing to do...
      if (pltlen > kDimPlt) return false;     // PLTLEN to high is error
 
      uint16_t udb[kDimPlt];
      for (auto& w : udb) w = 0;

      // this follow DEUNA UG and DELUA UG (defaults are same for both)
      // and the simh pdp11_xu.c implementation
      udb[11] = 0x260;                      // type
      udb[12] = 28;                         // ccount (+parameters... NI)
      udb[13] = 7;                          // code
      udb[14] = 0;                          // recnum
                                            // mop information
      udb[15] = 1;                          // mvtype
      udb[16] = 0x0303;                     // mvver + mvlen
      udb[17] = 0;                          // mvueco + mveco
                                            // function information
      udb[18] = 2;                          // ftype
      udb[19] = 0x0502;                     // fval1 + flen
      udb[20] = 0x0700;                     // hatype<07:00> + fval2
      udb[21] = 0x0600;                     // halen + hatype<15:08>
                                            // built-in MAC address
      RethTools::Mac2WList(fMacList[0], &udb[21]); // HA
      udb[24] = 0x64;                       // dtype
      udb[25] = (11 << 8) + 1;              // dvalue + dlen
      RlinkCommandList clist1;
      cpu.AddWMem(clist1, udbb, udb, pltlen, Rw11Cpu::kCPAH_M_UBM22, true);
      Server().Exec(clist1);
      // FIXME_code: handle access errors
      return true;
    }

  case kFUNC_WSID:                          // WSID -- write system ID -------
    {
      fStats.Inc(kStatNFuncWsid);
      return false;                         // currently not implemented
    }

  default:
    fStats.Inc(kStatNFuncUimpl);
    return false;
  }
  return false;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::SetupPrimClist()
{
  Rw11Cpu& cpu  = Cpu();

  fPrimClist.Clear();
  fPrimClist.AddAttn();
  fPC_rdpr0      = cpu.AddRibr(fPrimClist, fBase+kPR0);
  fPC_rdpcb      = 0;
  fPC_lapcb      = 0;
  fPC_rdtxdsccur = 0;
  fPC_latxdsccur = 0;
  fPC_rdtxdscnxt = 0;
  fPC_latxdscnxt = 0;
  fPC_rdrxdsccur = 0;
  fPC_larxdsccur = 0;
  fPC_rdrxdscnxt = 0;
  if (!fPcbbValid) return;
  fPC_rdpcb = cpu.AddRMem(fPrimClist, fPcbb, fPcb, 4,
                          Rw11Cpu::kCPAH_M_UBM22, true);
  fPC_lapcb = fPrimClist.AddLabo();
  if (!Running()) return;

  // Note: the memory addresses will be set before each usage with ModLalh()
  //       that's why the initial memory address is set as kUBA_M (end of ubmap)
  fPC_rdtxdsccur = cpu.AddRMem(fPrimClist, kUBA_M, fTxDscCurPC, 3,
                               Rw11Cpu::kCPAH_M_UBM22, true);
  fPC_latxdsccur = fPrimClist.AddLabo();

  fPC_rdtxdscnxt = cpu.AddRMem(fPrimClist, kUBA_M, fTxDscNxtPC, 3,
                               Rw11Cpu::kCPAH_M_UBM22, true);
  fPC_latxdscnxt = fPrimClist.AddLabo();

  fPC_rdrxdsccur = cpu.AddRMem(fPrimClist, kUBA_M, fRxDscCurPC, 3,
                               Rw11Cpu::kCPAH_M_UBM22, true);
  fPC_larxdsccur = fPrimClist.AddLabo();

  fPC_rdrxdscnxt = cpu.AddRMem(fPrimClist, kUBA_M, fRxDscCurPC, 3,
                               Rw11Cpu::kCPAH_M_UBM22, true);
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs

uint16_t Rw11CntlDEUNA::GetPr1() const
{
  uint16_t pr1 = fPr1State;
  if (fPr1Pcto)  pr1 |= kPR1_M_PCTO;
  if (fPr1Delua) {
    pr1 |= kPR1_M_DELUA;
  } else {
    if (!fspUnit[0]->HasVirt()) {
      pr1 |= kPR1_M_XPWR | kPR1_M_ICAB;
    }
  }
  return pr1;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::StartTxRing()
{
  RlinkCommandList clist;
  uint16_t txdsccur[4];
  uint16_t txdscnxt[4];
  Cpu().AddRMem(clist, TxRingDscAddr(fTxRingIndex),
                txdsccur, 3, Rw11Cpu::kCPAH_M_UBM22, true);
  Cpu().AddRMem(clist, TxRingDscAddr(TxRingIndexNext()),
                txdscnxt, 3, Rw11Cpu::kCPAH_M_UBM22, true);
  Server().Exec(clist);
  // FIXME_code: check dsc read errors !  
  StartTxRing(txdsccur, txdscnxt);
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::StartTxRing(const uint16_t dsccur[4],
                                const uint16_t dscnxt[4])
{
  if (fTxRingState != kStateTxIdle) return;

  SetRingDsc(fTxDscCur, dsccur);
  SetRingDsc(fTxDscNxt, dscnxt);
  
  if (fTxDscCurPC[2] & kTXR2_M_OWN) {       // pending tx frames ?
    fTxRingState = kStateTxBusy;
    Server().QueueAction([this](){ return TxRingHandler(); });
  }
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::StopTxRing()
{
  fTxRingState = kStateTxIdle;
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::StartRxRing()
{
  RlinkCommandList clist;
  uint16_t rxdsccur[4];
  uint16_t rxdscnxt[4];
  Cpu().AddRMem(clist, RxRingDscAddr(fRxRingIndex),
                rxdsccur, 3, Rw11Cpu::kCPAH_M_UBM22, true);
  Cpu().AddRMem(clist, RxRingDscAddr(RxRingIndexNext()),
                rxdscnxt, 3, Rw11Cpu::kCPAH_M_UBM22, true);
  Server().Exec(clist);
  // FIXME_code: check dsc read errors !  
  StartRxRing(rxdsccur, rxdscnxt);
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::StartRxRing(const uint16_t dsccur[4],
                                const uint16_t dscnxt[4])
{
  if (fRxRingState != kStateRxIdle) return;

  SetRingDsc(fRxDscCur, dsccur);
  SetRingDsc(fRxDscNxt, dscnxt);

  if (!fRxBufQueue.empty() &&               // if pending rx frames
      fRxDscCur[2] & kRXR2_M_OWN) {         // and buffer available
    fRxRingState = kStateRxBusy;
    Server().QueueAction([this](){ return RxRingHandler(); });
  }
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::StopRxRing()
{
  if (fRxRingState == kStateRxPoll) fRxPollTimer.Cancel();
  fRxRingState = kStateRxIdle;
  return;
}
//--------------------------------------+-----------------------------------
//! FIXME_docs
int Rw11CntlDEUNA::TxRingHandler()
{
  fTxRingState = kStateTxIdle;              // expect quit
  if (!Running()) return 0;                   // quit if not running

  RlinkCommandList clist;
  Rw11Cpu& cpu  = Cpu();
  Rw11UnitDEUNA& unit = *fspUnit[0];

  if (!(fTxDscCur[2] & kTXR2_M_OWN)) return 0; // FIXME_code: shouldn't happen !
  // FIXME_code: quit if ring bad, not attached,...

  LogRingInfo('t','<');                     // log initial ring dsc state

  if (fTxBufOffset == 0) {                  // new frame processed
    fTxBuf.Clear();                           // clear buffer
    fTxBuf.SetTime();                         // set timestamp
  }

  // clear OWN+flags, keep SEGB,STF,ENF  
  fTxDscCur[2] &= kTXR2_M_SEGB|kTXR2_M_STF|kTXR2_M_ENF; 
  fTxDscCur[3]  = 0;

  uint16_t stat   = 0;
  uint16_t pr0out = 0;

  uint16_t slen = fTxDscCur[0];
  uint32_t segb = uint32_t(fTxDscCur[1]) | uint32_t(fTxDscCur[2] & 0xff)<<16;
  if (segb & ~kUBA_M) stat |= kSTAT_M_TRNG; // FIXME_code: see MBZ comment above

  uint16_t tsize = slen;
  if (tsize > RethBuf::kMaxSize) {
    tsize = RethBuf::kMaxSize;
    fTxDscCur[3] |= kTXR3_M_BUFL;           // FIXME_code: is that correct ?
  }

  // read data
  // FIXME_code: handle odd base !!
  cpu.AddRMem(clist, segb, fTxBuf.Buf16(), (tsize+1)/2, 
              Rw11Cpu::kCPAH_M_UBM22, true);
  Server().Exec(clist);
  // FIXME_code: handle errors !!

  fTxBuf.SetSize(tsize);                    // FIXME_code: handle chunks !

  clist.Clear();

  // update current dsc
  cpu.AddWMem(clist, TxRingDscAddr(fTxRingIndex)+4, &fTxDscCur[2], 2, 
              Rw11Cpu::kCPAH_M_UBM22, true);
  clist.AddLabo();

  // re-read next dsc; and read next-next dsc 
  uint16_t dsccurnew[4];
  uint16_t dscnxtnew[4];
  cpu.AddRMem(clist, TxRingDscAddr(TxRingIndexNext(1)), dsccurnew, 3, 
              Rw11Cpu::kCPAH_M_UBM22, true);
  clist.AddLabo();
  cpu.AddRMem(clist, TxRingDscAddr(TxRingIndexNext(2)), dscnxtnew, 3, 
              Rw11Cpu::kCPAH_M_UBM22, true);
  clist.AddLabo();

  // signal frame done
  pr0out |= kPR0_M_TXI;
  cpu.AddWibr(clist, fBase+kPR0, pr0out);

  // final frame handling
  fTxBuf.SetMacSource(fMacList[0]);         // set source address
  if (fTxBuf.Size() < RethBuf::kMinSize) {  // pad if to small
    ::memset(fTxBuf.Buf8()+fTxBuf.Size(), 0, RethBuf::kMinSize-fTxBuf.Size());
    fTxBuf.SetSize(RethBuf::kMinSize);
    fStats.Inc(kStatNTxFraPad);
    if (!(fMode&kMODE_M_TPAD)) {            // runt error unless TPAD active
      fTxDscCur[3] |= kTXR3_M_BUFL;
    }
  }

  // check for 'station match'
  uint64_t macdst = fTxBuf.MacDestination();
  int matchdst = MacFilter(macdst);
  if (matchdst > 0) {
    fTxDscCur[2] |= kTXR2_M_MTCH;
  }

  UpdateStat32(fCtrTxFra, kStatNTxFra);
  UpdateStat32(fCtrTxByt, kStatNTxByt, fTxBuf.Size());
  if (fTxBuf.IsMcast()) {                   // Mcast includes Bcast !
    UpdateStat32(fCtrTxFraMcast, kStatNTxFraMcast);
    UpdateStat32(fCtrTxBytMcast, kStatNTxBytMcast, fTxBuf.Size());
    if (fTxBuf.IsBcast()) {
      fStats.Inc(kStatNTxFraBcast);
    }
  }

  if (fTraceLevel>2) {
    RlogMsg lmsg(LogFile());
    std::ostringstream sos;
    fTxBuf.Dump(sos, 4, "fTxBuf: ");
    lmsg << sos.str();
  }

  LogFrameInfo('t', fTxBuf);               // log transmitted frame
  if (unit.HasVirt()) {                    //  attached ?
    RerrMsg emsg;
    unit.Virt().Snd(fTxBuf, emsg);
    // FIXME_code: error handling 
  }  

  LogRingInfo('t','>');                    // log final ring dsc state
  Server().Exec(clist);
  // FIXME_code: handle errors

  // push ring index, update current and next dsc
  fTxRingIndex = TxRingIndexNext();
  SetRingDsc(fTxDscCur, dsccurnew);
  SetRingDsc(fTxDscNxt, dscnxtnew);

  // now decide whether to idle or continue
  if (!(fTxDscCur[2] & kTXR2_M_OWN)) return 0; // quit if nothing to do

  fTxRingState = kStateTxBusy;              // otherwise continue
  return 1;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
int Rw11CntlDEUNA::RxRingHandler()
{
  fRxRingState = kStateRxIdle;
  if (!Running())  return 0;                // quit if not running

  RlinkCommandList clist;
  Rw11Cpu& cpu  = Cpu();

  if (!(fRxDscCur[2] & kRXR2_M_OWN)) return 0; // FIXME_code: shouldn't happen !

  if (fRxBufOffset == 0) {                  // new frame needed
    if (fRxBufQueue.empty()) return 0;        // quit if none available
    fRxBufCurr = fRxBufQueue.front();
    fRxBufQueue.pop_front();
  }
  RethBuf& ebuf = *fRxBufCurr;

  if (true && ebuf.Size() < RethBuf::kMinSize) { // pad if ena
    ::memset(ebuf.Buf8()+ebuf.Size(), 0, RethBuf::kMinSize-ebuf.Size());
    ebuf.SetSize(RethBuf::kMinSize);
    fStats.Inc(kStatNRxFraPad);
  }

  LogRingInfo('r','<');                     // log initial ring dsc state
  LogFrameInfo('e', ebuf);                  // log reveived frame

  // FIXME_code: this also clears the MBZ areas !! handle this correctly
  // clear OWN+flags, keep SEGB
  fRxDscCur[2] &= kRXR2_M_SEGB;
  fRxDscCur[3]  = 0;

  uint16_t stat   = 0;
  uint16_t pr0out = 0;

  uint16_t slen = fRxDscCur[0];
  uint32_t segb = uint32_t(fRxDscCur[1]) | uint32_t(fRxDscCur[2] & 0xff)<<16;
  if (segb & ~kUBA_M) stat |= kSTAT_M_RRNG; // FIXME_code: see MBZ comment above

  uint16_t tsize = ebuf.Size();

  if (ebuf.Size() > slen) {
    tsize = slen;
    fRxDscCur[3] |= kRXR3_M_BUFL;
  }

  // Note: the DEUNA returns in the rx descriptor the frame length including
  //       the CRC length (4 bytes) !! But apparently does not transfer the
  //       CRC, at least in normal mode !! See comments in simh pdp11_xu.c.
  fRxDscCur[2] |= kRXR2_M_STF | kRXR2_M_ENF;
  fRxDscCur[3] |= tsize+RethBuf::kCrcSize;
  
  // write data
  cpu.AddWMem(clist, segb, ebuf.Buf16(), (tsize+1)/2, 
              Rw11Cpu::kCPAH_M_UBM22, true);
  clist.AddLabo();
  // update current dsc
  cpu.AddWMem(clist, RxRingDscAddr(fRxRingIndex)+4, &fRxDscCur[2], 2, 
              Rw11Cpu::kCPAH_M_UBM22, true);
  clist.AddLabo();

  // re-read next dsc; and read next-next dsc 
  uint16_t dsccurnew[4];
  uint16_t dscnxtnew[4];
  cpu.AddRMem(clist, RxRingDscAddr(RxRingIndexNext(1)), dsccurnew, 3, 
              Rw11Cpu::kCPAH_M_UBM22, true);
  clist.AddLabo();
  cpu.AddRMem(clist, RxRingDscAddr(RxRingIndexNext(2)), dscnxtnew, 3, 
              Rw11Cpu::kCPAH_M_UBM22, true);
  clist.AddLabo();
  
  // signal frame done
  pr0out |= kPR0_M_RXI;
  cpu.AddWibr(clist, fBase+kPR0, pr0out);

  UpdateStat32(fCtrRxFra, kStatNRxFra);
  UpdateStat32(fCtrRxByt, kStatNRxByt, ebuf.Size());
  if (ebuf.IsMcast()) {                   // Mcast includes Bcast !
    UpdateStat32(fCtrRxFraMcast, kStatNRxFraMcast);
    UpdateStat32(fCtrRxBytMcast, kStatNRxBytMcast, ebuf.Size());
    if (ebuf.IsBcast()) {
      fStats.Inc(kStatNRxFraBcast);
    }
  }

  LogRingInfo('r','>');                    // log final ring dsc state
  Server().Exec(clist);
  // FIXME_code: handle errors

  // push ring index, update current and next dsc
  fRxRingIndex = RxRingIndexNext();
  SetRingDsc(fRxDscCur, dsccurnew);
  SetRingDsc(fRxDscNxt, dscnxtnew);

  // now decide whether to idle, continue, or poll
  if (fRxBufQueue.empty()) return 0;        // quit if nothing to do
  if (!(fRxDscCur[2] & kRXR2_M_OWN)) {      // no free buffer
    fRxPollTimer.SetRelative(fRxPollTime);
    fRxRingState = kStateRxPoll;              // activate timer
    return 0;
  }

  fRxRingState = kStateRxBusy;              // otherwise continue
  return 1;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
int Rw11CntlDEUNA::RxPollHandler(const pollfd& pfd)
{
  // bail-out and cancel handler if poll returns an error event
  if (pfd.revents & (~pfd.events)) return -1;

  uint64_t cnt = fRxPollTimer.Read();       // harvest expiration count
  if (!Running() ||                         // if not running
      fRxRingState != kStateRxPoll ||       // if not polling
      !cnt) return 0;                       // if not expired -> quit

  fRxRingState = kStateRxIdle;              // end poll
  StartRxRing();                            // re-start rx ring

  return 0;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
int Rw11CntlDEUNA::MacFilter(uint64_t mac)
{
  int maxind = 2 + fMcastCnt;
  for (int i=0; i<maxind; i++) {
    if (fMacList[i] == mac) return i; 
  }
  return -1;
}
//--------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDEUNA::UpdateStat16(uint32_t& stat, size_t ind, uint32_t inc)
{
  fStats.Inc(ind, inc);
  stat += inc;
  if (stat < inc || stat > 0xffff) stat = 0xffff;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDEUNA::UpdateStat32(uint32_t& stat, size_t ind, uint32_t inc)
{
  fStats.Inc(ind, inc);
  stat += inc;
  if (stat < inc) stat = 0xffffffff;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::LogMacFunc(const char* cmd, uint64_t mac)
{
  if (fTraceLevel == 0) return;
  RlogMsg lmsg(LogFile());
  lmsg << "-I " << Name() << ": " << cmd << ": " << RethTools::Mac2String(mac);
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::LogMcastFunc(const char* cmd)
{
  if (fTraceLevel == 0) return;
  RlogMsg lmsg(LogFile());
  lmsg << "-I " << Name() << ": " << cmd << ": mltlen=" << fMcastCnt;
  for (int i=0; i<fMcastCnt; i++) {
    lmsg << "\n        " << RethTools::Mac2String(fMacList[2+i]);
  }
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::LogRingFunc(const char* cmd)
{
  if (fTraceLevel == 0) return;
  RlogMsg lmsg(LogFile());
  lmsg << "-I " << Name() << ": " << cmd << ":"
       << " tx base=" << RosPrintBvi(fTxRingBase,8,18)
       << " size=" << RosPrintf(fTxRingSize, "d", 2)
       << " elen=" << RosPrintf(fTxRingELen, "d", 2)
       << "; rx base=" << RosPrintBvi(fRxRingBase,8,18)
       << " size=" << RosPrintf(fRxRingSize, "d", 2)
       << " elen=" << RosPrintf(fRxRingELen, "d", 2);
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::LogFunc(const char* cmd, const char* tag1, uint16_t val1,
                            const char* tag2, uint16_t val2)
{
  if (fTraceLevel == 0) return;
  RlogMsg lmsg(LogFile());
  lmsg << "-I " << Name() << ": " << cmd << ": "
       << tag1 << "=" << RosPrintBvi(val1,8);
  if (tag2) lmsg << tag2 << "=" << RosPrintBvi(val2,8);
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::LogRingInfo(char rxtx, char rw)
{
  if (fTraceLevel == 0) return;

  bool tx = (rxtx == 't');
  uint16_t  rind = tx ? fTxRingIndex : fRxRingIndex;
  uint16_t* rdsc = tx ? fTxDscCur    : fRxDscCur;

  RlogMsg lmsg(LogFile());
  lmsg << "-I " << Name() << ": " << rxtx << "xr "
       << rxtx << RosPrintf(rind,"d0", 2) << " " << rw
       << " " << RingDsc2String(rdsc, rxtx);
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs
void Rw11CntlDEUNA::LogFrameInfo(char rxtx, const RethBuf& buf)
{
  if (fTraceLevel == 0) return;

  bool tx = (rxtx == 't');
  RlogMsg lmsg(LogFile());
  lmsg << "-I " << Name() << ":" << (tx ? " snd " : " rcv ") << buf.FrameInfo();
  return;
}

//--------------------------------------+-----------------------------------
//! FIXME_docs

std::string Rw11CntlDEUNA::RingDsc2String(const uint16_t dsc[4], char rxtx)
{
  std::ostringstream sos;
  uint32_t segb = uint32_t(dsc[1]) + (uint32_t(dsc[2] & kTXR2_M_SEGB)<<16);
  uint16_t mlen = dsc[3] & kRXR3_M_MLEN;
  sos << RosPrintf(dsc[0],"d", 4)
      << ","  << RosPrintBvi(segb, 8, 18)
      << ","  << RosPrintf(mlen,"d", 4)
      << "; " << RosPrintBvi(uint16_t(dsc[2]>>8), 2, 8)
      << ","  << RosPrintBvi(uint16_t(dsc[3]>>12), 2, 4) << ": ";
  
  sos << RingDsc2OSEString(dsc);
  
  if (dsc[2] & kTXR2_M_ERRS) sos << " errs";
  if (rxtx == 't') {
    if (dsc[2] & kTXR2_M_MTCH) sos << " mtch";
    if (dsc[2] & kTXR2_M_MORE) sos << " more";
    if (dsc[2] & kTXR2_M_ONE)  sos << " one";
    if (dsc[2] & kTXR2_M_DEF)  sos << " def";
    sos << ",";
    if (dsc[2] & kTXR3_M_BUFL) sos << " bufl";
    if (dsc[2] & kTXR3_M_UBTO) sos << " ubto";
    if (dsc[2] & kTXR3_M_LCOL) sos << " lcol";
    if (dsc[2] & kTXR3_M_LCAR) sos << " lcar";
    if (dsc[2] & kTXR3_M_RTRY) sos << " rtry";
  } else {
    if (dsc[2] & kRXR2_M_FRAM) sos << " fram";
    if (dsc[2] & kRXR2_M_OFLO) sos << " oflo";
    if (dsc[2] & kRXR2_M_CRC)  sos << " crc";
    sos << ",";
    if (dsc[2] & kRXR3_M_BUFL) sos << " bufl";
    if (dsc[2] & kRXR3_M_UBTO) sos << " ubto";
    if (dsc[2] & kRXR3_M_NCHN) sos << " nchn";
    if (dsc[2] & kRXR3_M_OVRN) sos << " ovrn";
  }
  
  return sos.str();
}

//--------------------------------------+-----------------------------------
//! FIXME_docs

std::string Rw11CntlDEUNA::RingDsc2OSEString(const uint16_t dsc[4], char fill)
{
  char res[4] = {fill,fill,fill,0};
  if (dsc[2] & kTXR2_M_OWN) res[0] = 'O';
  if (dsc[2] & kTXR2_M_STF) res[1] = 'S';
  if (dsc[2] & kTXR2_M_ENF) res[2] = 'E';
  return string(res);  
}

} // end namespace Retro
