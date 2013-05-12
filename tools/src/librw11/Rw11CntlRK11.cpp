// $Id: Rw11CntlRK11.cpp 515 2013-05-04 17:28:59Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// Other credits: 
//   the boot code from the simh project and Copyright Robert M Supnik
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
// 2013-04-20   508   1.0    Initial version
// 2013-02-10   485   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11CntlRK11.cpp 515 2013-05-04 17:28:59Z mueller $
  \brief   Implemenation of Rw11CntlRK11.
*/

#include "boost/bind.hpp"
#include "boost/foreach.hpp"
#define foreach_ BOOST_FOREACH

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"

#include "Rw11CntlRK11.hpp"

using namespace std;

/*!
  \class Retro::Rw11CntlRK11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint16_t Rw11CntlRK11::kIbaddr;
const int      Rw11CntlRK11::kLam;

const uint16_t Rw11CntlRK11::kRKDS; 
const uint16_t Rw11CntlRK11::kRKER; 
const uint16_t Rw11CntlRK11::kRKCS; 
const uint16_t Rw11CntlRK11::kRKWC; 
const uint16_t Rw11CntlRK11::kRKBA; 
const uint16_t Rw11CntlRK11::kRKDA; 
const uint16_t Rw11CntlRK11::kRKMR; 

const uint16_t Rw11CntlRK11::kProbeOff;
const bool     Rw11CntlRK11::kProbeInt;
const bool     Rw11CntlRK11::kProbeRem;

const uint16_t Rw11CntlRK11::kRKDS_M_ID;
const uint16_t Rw11CntlRK11::kRKDS_V_ID;
const uint16_t Rw11CntlRK11::kRKDS_B_ID;
const uint16_t Rw11CntlRK11::kRKDS_M_HDEN;
const uint16_t Rw11CntlRK11::kRKDS_M_DRU;
const uint16_t Rw11CntlRK11::kRKDS_M_SIN;
const uint16_t Rw11CntlRK11::kRKDS_M_SOK;
const uint16_t Rw11CntlRK11::kRKDS_M_DRY;
const uint16_t Rw11CntlRK11::kRKDS_M_ADRY;
const uint16_t Rw11CntlRK11::kRKDS_M_WPS;
const uint16_t Rw11CntlRK11::kRKDS_B_SC;

const uint16_t Rw11CntlRK11::kRKER_M_DRE;
const uint16_t Rw11CntlRK11::kRKER_M_OVR;
const uint16_t Rw11CntlRK11::kRKER_M_WLO;
const uint16_t Rw11CntlRK11::kRKER_M_PGE;
const uint16_t Rw11CntlRK11::kRKER_M_NXM;
const uint16_t Rw11CntlRK11::kRKER_M_NXD;
const uint16_t Rw11CntlRK11::kRKER_M_NXC;
const uint16_t Rw11CntlRK11::kRKER_M_NXS;
const uint16_t Rw11CntlRK11::kRKER_M_CSE;
const uint16_t Rw11CntlRK11::kRKER_M_WCE;

const uint16_t Rw11CntlRK11::kRKCS_M_MAINT;
const uint16_t Rw11CntlRK11::kRKCS_M_IBA;
const uint16_t Rw11CntlRK11::kRKCS_M_FMT;
const uint16_t Rw11CntlRK11::kRKCS_M_RWA;
const uint16_t Rw11CntlRK11::kRKCS_M_SSE;
const uint16_t Rw11CntlRK11::kRKCS_M_MEX;
const uint16_t Rw11CntlRK11::kRKCS_V_MEX;
const uint16_t Rw11CntlRK11::kRKCS_B_MEX;
const uint16_t Rw11CntlRK11::kRKCS_V_FUNC;
const uint16_t Rw11CntlRK11::kRKCS_B_FUNC;
const uint16_t Rw11CntlRK11::kRKCS_CRESET;
const uint16_t Rw11CntlRK11::kRKCS_WRITE;
const uint16_t Rw11CntlRK11::kRKCS_READ;
const uint16_t Rw11CntlRK11::kRKCS_WCHK;
const uint16_t Rw11CntlRK11::kRKCS_SEEK;
const uint16_t Rw11CntlRK11::kRKCS_RCHK;
const uint16_t Rw11CntlRK11::kRKCS_DRESET;
const uint16_t Rw11CntlRK11::kRKCS_WLOCK;
const uint16_t Rw11CntlRK11::kRKCS_M_GO;

const uint16_t Rw11CntlRK11::kRKDA_M_DRSEL;
const uint16_t Rw11CntlRK11::kRKDA_V_DRSEL;
const uint16_t Rw11CntlRK11::kRKDA_B_DRSEL;
const uint16_t Rw11CntlRK11::kRKDA_M_CYL;
const uint16_t Rw11CntlRK11::kRKDA_V_CYL;
const uint16_t Rw11CntlRK11::kRKDA_B_CYL;
const uint16_t Rw11CntlRK11::kRKDA_M_SUR;
const uint16_t Rw11CntlRK11::kRKDA_V_SUR;
const uint16_t Rw11CntlRK11::kRKDA_B_SUR;
const uint16_t Rw11CntlRK11::kRKDA_B_SC;

const uint16_t Rw11CntlRK11::kRKMR_M_RID;
const uint16_t Rw11CntlRK11::kRKMR_V_RID;
const uint16_t Rw11CntlRK11::kRKMR_M_CRDONE;
const uint16_t Rw11CntlRK11::kRKMR_M_SBCLR;
const uint16_t Rw11CntlRK11::kRKMR_M_CRESET;
const uint16_t Rw11CntlRK11::kRKMR_M_FDONE;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlRK11::Rw11CntlRK11()
  : Rw11CntlBase<Rw11UnitRK11,8>("rk11"),
    fPC_rkwc(0),
    fPC_rkba(0),
    fPC_rkda(0),
    fPC_rkmr(0),
    fPC_rkcs(0),
    fRd_busy(false),
    fRd_rkcs(0),
    fRd_rkda(0),
    fRd_addr(0),
    fRd_lba(0),
    fRd_nwrd(0),
    fRd_ovr(false)
{
  // must here because Unit have a back-pointer (not available at Rw11CntlBase)
  for (size_t i=0; i<NUnit(); i++) {
    fspUnit[i].reset(new Rw11UnitRK11(this, i));
  }
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11CntlRK11::~Rw11CntlRK11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRK11::Config(const std::string& name, uint16_t base, int lam)
{
  ConfigCntl(name, base, lam, kProbeOff, kProbeInt, kProbeRem);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRK11::Start()
{
  if (fStarted || fLam<0 || !fEnable || !fProbe.Found())
    throw Rexception("Rw11CntlDL11::Start",
                     "Bad state: started, no lam, not enable, not found");

  // setup primary info clist
  fPrimClist.Clear();
  Cpu().AddIbrb(fPrimClist, fBase);
  fPC_rkwc = Cpu().AddRibr(fPrimClist, fBase+kRKWC);
  fPC_rkba = Cpu().AddRibr(fPrimClist, fBase+kRKBA);
  fPC_rkda = Cpu().AddRibr(fPrimClist, fBase+kRKDA);
  fPC_rkmr = Cpu().AddRibr(fPrimClist, fBase+kRKMR); // read to monitor CRDONE
  fPC_rkcs = Cpu().AddRibr(fPrimClist, fBase+kRKCS);

  // add attn handler
  Server().AddAttnHandler(boost::bind(&Rw11CntlRK11::AttnHandler, this, _1), 
                          uint16_t(1)<<fLam, (void*)this);

  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRK11::UnitSetup(size_t ind)
{
  Rw11UnitRK11& unit = *fspUnit[ind];
  Rw11Cpu& cpu  = Cpu();
  RlinkCommandList clist;

  uint16_t rkds = ind<<kRKDS_V_ID;
  if (unit.Virt()) {                        // file attached
    rkds |= kRKDS_M_HDEN;                   // always high density
    rkds |= kRKDS_M_SOK;                    // always sector counter OK ?FIXME?
    rkds |= kRKDS_M_DRY;                    // drive available
    rkds |= kRKDS_M_ADRY;                   // access available
    if (unit.WProt())                       // in case write protected
      rkds |= kRKDS_M_WPS;
  }
  unit.SetRkds(rkds);
  cpu.AddIbrb(clist, fBase);
  cpu.AddWibr(clist, fBase+kRKDS, rkds);
  Server().Exec(clist);

  return;
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11CntlRK11::BootCode(size_t unit, std::vector<uint16_t>& code, 
                            uint16_t& aload, uint16_t& astart)
{
  uint16_t kBOOT_START = 02000;
  uint16_t bootcode[] = {      // rk05 boot loader - from simh pdp11_rk.c 
    0042113,                   // "KD"
    0012706, kBOOT_START,      // MOV #boot_start, SP
    0012700, uint16_t(unit),   // MOV #unit, R0        ; unit number
    0010003,                   // MOV R0, R3
    0000303,                   // SWAB R3
    0006303,                   // ASL R3
    0006303,                   // ASL R3
    0006303,                   // ASL R3
    0006303,                   // ASL R3
    0006303,                   // ASL R3
    0012701, 0177412,          // MOV #RKDA, R1        ; rkda
    0010311,                   // MOV R3, (R1)         ; load da
    0005041,                   // CLR -(R1)            ; clear ba
    0012741, 0177000,          // MOV #-256.*2, -(R1)  ; load wc
    0012741, 0000005,          // MOV #READ+GO, -(R1)  ; read & go
    0005002,                   // CLR R2
    0005003,                   // CLR R3
    0012704, uint16_t(kBOOT_START+020),  // MOV #START+20, R4
    0005005,                   // CLR R5
    0105711,                   // TSTB (R1)
    0100376,                   // BPL .-4
    0105011,                   // CLRB (R1)
    0005007                    // CLR PC     (5007)
  };
  
  code.clear();
  foreach_ (uint16_t& w, bootcode) code.push_back(w); 
  aload  = kBOOT_START;
  astart = kBOOT_START+2;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRK11::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlRK11 @ " << this << endl;
  os << bl << "  fPC_rkwc:        " << fPC_rkwc << endl;
  os << bl << "  fPC_rkba:        " << fPC_rkba << endl;
  os << bl << "  fPC_rkda:        " << fPC_rkda << endl;
  os << bl << "  fPC_rkmr:        " << fPC_rkmr << endl;
  os << bl << "  fPC_rkcs:        " << fPC_rkcs << endl;
  os << bl << "  fRd_busy:        " << fRd_busy << endl;
  os << bl << "  fRd_rkcs:        " << fRd_rkcs << endl;
  os << bl << "  fRd_rkda:        " << fRd_rkda << endl;
  os << bl << "  fRd_addr:        " << fRd_addr << endl;
  os << bl << "  fRd_lba:         " << fRd_lba  << endl;
  os << bl << "  fRd_nwrd:        " << fRd_nwrd << endl;
  os << bl << "  fRd_ovr:         " << fRd_ovr  << endl;

  Rw11CntlBase<Rw11UnitRK11,8>::Dump(os, ind, " ^");
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlRK11::AttnHandler(const RlinkServer::AttnArgs& args)
{
  RlinkCommandList* pclist;
  size_t off;
  
  GetPrimInfo(args, pclist, off);  

  uint16_t rkwc = (*pclist)[off+fPC_rkwc].Data();
  uint16_t rkba = (*pclist)[off+fPC_rkba].Data();
  uint16_t rkda = (*pclist)[off+fPC_rkda].Data();
  //uint16_t rkmr = (*pclist)[off+fPC_rkmr].Data();
  uint16_t rkcs = (*pclist)[off+fPC_rkcs].Data();

  uint16_t se   =  rkda                 & kRKDA_B_SC;
  uint16_t hd   = (rkda>>kRKDA_V_SUR)   & kRKDA_B_SUR;
  uint16_t cy   = (rkda>>kRKDA_V_CYL)   & kRKDA_B_CYL;
  uint16_t dr   = (rkda>>kRKDA_V_DRSEL) & kRKDA_B_DRSEL;
 
  bool go       =  rkcs & kRKCS_M_GO;
  uint16_t fu   = (rkcs>>kRKCS_V_FUNC)  & kRKCS_B_FUNC;
  uint16_t mex  = (rkcs>>kRKCS_V_MEX)   & kRKCS_B_MEX;
  uint32_t addr = uint32_t(mex)<<16 | uint32_t(rkba);

  // Note: apparently are operands first promoted to 32 bit -> mask after ~ !
  uint32_t nwrd = (~uint32_t(rkwc)&0xffff) + 1; // transfer size in words

  if (!go) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I RK11 cs=" << RosPrintBvi(rkcs,8)
         << "  go=0, spurious attn, dropped";
    return 0;
  }
  
  // all 8 units are always available, but check anyway
  if (dr > NUnit())
    throw Rexception("Rw11CntlRK11::AttnHandler","Bad state: dr > NUnit()");

  Rw11UnitRK11& unit = *fspUnit[dr];
  Rw11Cpu& cpu = Cpu();
  RlinkCommandList clist;

  uint32_t lba  = unit.Chs2Lba(cy,hd,se);
  uint32_t nblk = (2*nwrd+unit.BlockSize()-1)/unit.BlockSize();

  uint16_t rker = 0;
  uint16_t rkds = unit.Rkds();

  if (fTraceLevel>0) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I RK11 cs=" << RosPrintBvi(rkcs,8)
         << " da=" << RosPrintBvi(rkda,8)
         << " ad=" << RosPrintBvi(addr,8,18)
         << " fu=" << fu
         << " dchs=" << dr 
         << "," << RosPrintf(cy,"d",3) 
         << "," << hd 
         << "," << RosPrintf(se,"d",2)
         << " lba,nw=" << RosPrintf(lba,"d",4) 
         << "," << RosPrintf(nwrd,"d",5);
  }

  // check for general abort conditions
  if (fu != kRKCS_CRESET &&                 // function not control reset
      (!unit.Virt())) {                     //   and drive not attached
    rker = kRKER_M_NXD;                     //   --> abort with NXD error

  } else if (fu != kRKCS_WRITE &&           // function neither write
             fu != kRKCS_READ &&            //   nor read
             (rkcs & (kRKCS_M_FMT|kRKCS_M_RWA))) { // and FMT or RWA set 
    rker = kRKER_M_PGE;                     //   --> abort with PGE error
  } else if (rkcs & kRKCS_M_RWA) {          // RWA not supported
    rker = kRKER_M_DRE;                     //   --> abort with DRE error
  }
  
  if (rker) {
    cpu.AddWibr(clist, fBase+kRKER, rker);
    if (fu == kRKCS_SEEK || fu == kRKCS_DRESET) 
      cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_SBCLR | (1u<<dr));
    cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_FDONE);
    LogRker(rker);
    Server().Exec(clist);
    return 0;
  }

  // check for overrun (read/write beyond cylinder 203
  // if found, truncate request length
  bool ovr = lba + nblk > unit.NBlock();
  if (ovr) nwrd = (unit.NBlock()-lba) * (unit.BlockSize()/2);
  bool queue = false;

  // now handle the functions
  if (fu == kRKCS_CRESET) {                 // Control reset -----------------
    cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_CRESET);
    fRd_busy  = false;

  } else if (fu == kRKCS_WRITE) {           // Write -------------------------
                                            //   Note: WRITE+FMT is just WRITE
    if (se >= unit.NSector())   rker |= kRKER_M_NXS;
    if (cy >= unit.NCylinder()) rker |= kRKER_M_NXC;
    if (unit.WProt())           rker |= kRKER_M_WLO;
    if (rkcs & kRKCS_M_IBA) rker |= kRKER_M_DRE;  // not yet supported FIXME
    queue = true;

  } else if (fu == kRKCS_READ) {            // Read --------------------------
    if (se >= unit.NSector())   rker |= kRKER_M_NXS;
    if (cy >= unit.NCylinder()) rker |= kRKER_M_NXC;
    if (rkcs & kRKCS_M_IBA) rker |= kRKER_M_DRE;  // not yet supported FIXME
    queue = true;
    
  } else if (fu == kRKCS_WCHK) {            // Write Check -------------------
    if (se >= unit.NSector())   rker |= kRKER_M_NXS;
    if (cy >= unit.NCylinder()) rker |= kRKER_M_NXC;
    if (rkcs & kRKCS_M_IBA) rker |= kRKER_M_DRE;  // not yet supported FIXME
    queue = true;

  } else if (fu == kRKCS_SEEK) {            // Seek --------------------------
    if (se >= unit.NSector())   rker |= kRKER_M_NXS;
    if (cy >= unit.NCylinder()) rker |= kRKER_M_NXC;
    if (rker) {
      cpu.AddWibr(clist, fBase+kRKER, rker);
      cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_SBCLR | (1u<<dr));
      cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_FDONE);
      LogRker(rker);
    } else {
      cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_FDONE);
      rkds &= ~kRKDS_B_SC;                  // replace current sector number
      rkds |= se;
      unit.SetRkds(rkds);
      cpu.AddWibr(clist, fBase+kRKDS, rkds);
      cpu.AddWibr(clist, fBase+kRKMR, 1u<<dr); // issue seek done
    }

  } else if (fu == kRKCS_RCHK) {            // Read Check --------------------
    if (se >= unit.NSector())   rker |= kRKER_M_NXS;
    if (cy >= unit.NCylinder()) rker |= kRKER_M_NXC;
    if (rkcs & kRKCS_M_IBA) rker |= kRKER_M_DRE;  // not yet supported FIXME
    queue = true;

  } else if (fu == kRKCS_DRESET) {          // Drive Reset -------------------
    cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_FDONE);
    cpu.AddWibr(clist, fBase+kRKMR, 1u<<dr);   // issue seek done
    
  } else if (fu == kRKCS_WLOCK) {           // Write Lock --------------------
    rkds |= kRKDS_M_WPS;                    // set RKDS write protect flag
    unit.SetRkds(rkds);
    unit.SetWProt(true);
    cpu.AddWibr(clist, fBase+kRKDS, rkds);
    cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_FDONE);
  }

  if (queue) {                             // to be handled in RdmaHandlder
    if (rker) {                              // abort on case of errors
      cpu.AddWibr(clist, fBase+kRKER, rker);
      cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_FDONE);
      LogRker(rker);
    } else {                                 // or queue action 
      fRd_busy  = true;
      fRd_rkcs  = rkcs;
      fRd_rkda  = rkda;
      fRd_addr  = addr;
      fRd_lba   = lba;
      fRd_nwrd  = nwrd;
      fRd_ovr   = ovr;
      Server().QueueAction(boost::bind(&Rw11CntlRK11::RdmaHandler, this));
    }

  } else {                                  // handled here
    Server().Exec(clist);
  }

  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlRK11::RdmaHandler()
{
  uint16_t rker = 0;
  uint16_t fu   = (fRd_rkcs>>kRKCS_V_FUNC)  & kRKCS_B_FUNC;
  uint16_t dr   = (fRd_rkda>>kRKDA_V_DRSEL) & kRKDA_B_DRSEL;
  Rw11UnitRK11& unit = *fspUnit[dr];
  Rw11Cpu& cpu = Cpu();

  uint8_t buf[512];

  if (fu == kRKCS_WRITE) {                  // Write -------------------------
                                            //   Note: WRITE+FMT is like WRITE
    RlinkCommandList clist;
    size_t bsize = (fRd_nwrd>256) ? 256 : fRd_nwrd;
    cpu.AddRMem(clist, fRd_addr, (uint16_t*) buf, bsize,
                Rw11Cpu::kCp_ah_m_22bit|Rw11Cpu::kCp_ah_m_ubmap);
    Server().Exec(clist);
    // FIXME_code: handle rdma I/O error
    RerrMsg emsg;
    bool rc = unit.VirtWrite(fRd_lba, 1, buf, emsg);
    if (!rc) {
      RlogMsg lmsg(LogFile());
      lmsg << emsg;
      rker |= kRKER_M_CSE;              // forward disk I/O error
    }
    if (rker == 0) {
      fRd_nwrd -= bsize;
      fRd_addr += 2*bsize;
      fRd_lba  += 1;
    }
    if (rker==0 && fRd_nwrd>0)            // not error and not yet done
      return 1;                           // requeue
    
  } else if (fu == kRKCS_READ) {
    if ((fRd_rkcs&kRKCS_M_FMT) == 0) {      // Read --------------------------
      RerrMsg emsg;
      bool rc = unit.VirtRead(fRd_lba, 1, buf, emsg);
      if (!rc) {
        RlogMsg lmsg(LogFile());
        lmsg << emsg;
        rker |= kRKER_M_CSE;              // forward disk I/O error
      }

      if (rker == 0) {
        RlinkCommandList clist;
        size_t bsize = (fRd_nwrd>256) ? 256 : fRd_nwrd;
        cpu.AddWMem(clist, fRd_addr, (uint16_t*) buf, bsize,
                    Rw11Cpu::kCp_ah_m_22bit|Rw11Cpu::kCp_ah_m_ubmap);
        Server().Exec(clist);
        // FIXME_code: handle rdma I/O error
        fRd_nwrd -= bsize;
        fRd_addr += 2*bsize;
        fRd_lba  += 1;
      }
      if (rker==0 && fRd_nwrd>0)            // not error and not yet done
        return 1;                           // requeue
 
    } else {                                // Read Format -------------------
      uint16_t cy = fRd_lba / (unit.NHead()*unit.NSector());
      uint16_t da = cy<<kRKDA_V_CYL;
      RlinkCommandList clist;
      cpu.AddWMem(clist, fRd_addr, &da, 1,
                  Rw11Cpu::kCp_ah_m_22bit|Rw11Cpu::kCp_ah_m_ubmap);
      Server().Exec(clist);
      // FIXME_code: handle rdma I/O error
      fRd_nwrd -= 1;
      fRd_addr += 2;
      fRd_lba  += 1;
      if (rker==0 && fRd_nwrd>0)            // not error and not yet done
        return 1;                           // requeue
    }
    
  } else if (fu == kRKCS_WCHK) {            // Write Check -------------------
    uint16_t bufmem[256];
    RlinkCommandList clist;
    size_t bsize = (fRd_nwrd>256) ? 256 : fRd_nwrd;
    cpu.AddRMem(clist, fRd_addr, bufmem, bsize,
                Rw11Cpu::kCp_ah_m_22bit|Rw11Cpu::kCp_ah_m_ubmap);
    Server().Exec(clist);
    // FIXME_code: handle rdma I/O error
    RerrMsg emsg;
    bool rc = unit.VirtRead(fRd_lba, 1, buf, emsg);
    if (!rc) {
      RlogMsg lmsg(LogFile());
      lmsg << emsg;
      rker |= kRKER_M_CSE;              // forward disk I/O error
    }
    if (rker == 0) {
      uint16_t* pmem = bufmem;
      uint16_t* pdsk = (uint16_t*) &buf;
      for (size_t i=0; i<bsize; i++) {
        if (*pmem++ != *pdsk++) rker |= kRKER_M_WCE;
      }
      fRd_nwrd -= bsize;
      fRd_addr += 2*bsize;
      fRd_lba  += 1;
    }
    // determine abort criterion
    bool stop = (rker & ~kRKER_M_WCE) != 0 ||
                ((rker & kRKER_M_WCE) && (fRd_rkcs & kRKCS_M_SSE));
    if (!stop && fRd_nwrd>0)                // not error and not yet done
      return 1;                             // requeue

  } else if (fu == kRKCS_RCHK) {            // Read Check --------------------
    // Note: no DMA transfer done; done here to keep logic similar to read
    size_t bsize = (fRd_nwrd>256) ? 256 : fRd_nwrd;
    fRd_nwrd -= bsize;
    fRd_addr += 2*bsize;
    fRd_lba  += 1;
    if (rker==0 && fRd_nwrd>0)            // not error and not yet done
      return 1;                           // requeue

  } else {
    throw Rexception("Rw11CntlDL11::RdmaHandler",
                     "Bad state: bad function code");
  }

  // common handling for dma transfer completion
  if (fRd_ovr) rker |= kRKER_M_OVR;

  RlinkCommandList clist;
  
  uint16_t ba   = fRd_addr & 0177776;       // get lower 16 bits
  uint16_t mex  = (fRd_addr>>16) & 03;      // get upper  2 bits
  uint16_t cs   = (fRd_rkcs & ~kRKCS_M_MEX) | (mex << kRKCS_V_MEX);
  uint16_t se;
  uint16_t hd;
  uint16_t cy;
  unit.Lba2Chs(fRd_lba, cy,hd,se);
  uint16_t da   = (fRd_rkda & kRKDA_M_DRSEL) | (cy<<kRKDA_V_CYL) |
                  (hd<<kRKDA_V_SUR) | se;

  cpu.AddIbrb(clist, fBase);
  if (rker) {
    cpu.AddWibr(clist, fBase+kRKER, rker);
    LogRker(rker);
  }
  cpu.AddWibr(clist, fBase+kRKWC, uint16_t((-fRd_nwrd)&0177777));
  cpu.AddWibr(clist, fBase+kRKBA, ba);
  cpu.AddWibr(clist, fBase+kRKDA, da);
  if (cs != fRd_rkcs) 
    cpu.AddWibr(clist, fBase+kRKCS, cs);
  cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_FDONE);
  
  Server().Exec(clist);

  fRd_busy  = false;

  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRK11::LogRker(uint16_t rker)
{
  RlogMsg lmsg(LogFile());
  lmsg << "-E RK11 er=" << RosPrintBvi(rker,8) << "  ERROR ABORT";
}

} // end namespace Retro
