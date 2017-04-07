// $Id: Rw11Cpu.cpp 868 2017-04-07 20:09:33Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-07   868   1.2.12 Dump(): add detail arg
// 2017-02-26   857   1.2.11 add kCPAH_M_UBM22
// 2017-02-19   853   1.2.10 use Rtime
// 2017-02-17   851   1.2.9  probe/setup auxilliary devices: kw11l,kw11p,iist
// 2017-02-10   850   1.2.8  add ModLalh()
// 2017-02-04   848   1.2.7  ProbeCntl: handle probe data
// 2015-12-26   719   1.2.6  BUGFIX: IM* correct register offset definitions
// 2015-07-12   700   1.2.5  use ..CpuAct instead ..CpuGo (new active based lam);
//                           add probe and map setup for optional cpu components
// 2015-05-15   682   1.2.4  BUGFIX: Boot(): extract unit number properly
//                           Boot(): stop cpu before load, check unit number
// 2015-05-08   675   1.2.3  w11a start/stop/suspend overhaul
// 2015-04-25   668   1.2.2  add AddRbibr(), AddWbibr()
// 2015-04-03   661   1.2.1  add kStat_M_* defs
// 2015-03-21   659   1.2    add RAddrMap()
// 2015-01-01   626   1.1    Adopt for rlink v4 and 4k ibus window
// 2014-12-21   617   1.0.3  use kStat_M_RbTout for rbus timeout
// 2014-08-02   576   1.0.2  adopt rename of LastExpect->SetLastExpect
// 2013-04-14   506   1.0.1  add AddLalh(),AddRMem(),AddWMem()
// 2013-04-12   504   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11Cpu.cpp 868 2017-04-07 20:09:33Z mueller $
  \brief   Implemenation of Rw11Cpu.
*/
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>

#include <vector>
#include <map>
#include <algorithm>

#include "boost/date_time/posix_time/posix_time_types.hpp"

#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"
#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "Rw11Cntl.hpp"

#include "Rw11Cpu.hpp"

using namespace std;

/*!
  \class Retro::Rw11Cpu
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint16_t  Rw11Cpu::kCPCONF;  
const uint16_t  Rw11Cpu::kCPCNTL;  
const uint16_t  Rw11Cpu::kCPSTAT;  
const uint16_t  Rw11Cpu::kCPPSW;  
const uint16_t  Rw11Cpu::kCPAL;  
const uint16_t  Rw11Cpu::kCPAH;  
const uint16_t  Rw11Cpu::kCPMEM;  
const uint16_t  Rw11Cpu::kCPMEMI;  
const uint16_t  Rw11Cpu::kCPR0;  
const uint16_t  Rw11Cpu::kCPPC;  
const uint16_t  Rw11Cpu::kCPMEMBE;  

const uint16_t  Rw11Cpu::kCPFUNC_NOOP;  
const uint16_t  Rw11Cpu::kCPFUNC_START;  
const uint16_t  Rw11Cpu::kCPFUNC_STOP;  
const uint16_t  Rw11Cpu::kCPFUNC_STEP;  
const uint16_t  Rw11Cpu::kCPFUNC_CRESET;  
const uint16_t  Rw11Cpu::kCPFUNC_BRESET; 
const uint16_t  Rw11Cpu::kCPFUNC_SUSPEND; 
const uint16_t  Rw11Cpu::kCPFUNC_RESUME; 

const uint16_t  Rw11Cpu::kCPSTAT_M_SuspExt;
const uint16_t  Rw11Cpu::kCPSTAT_M_SuspInt;
const uint16_t  Rw11Cpu::kCPSTAT_M_CpuRust;
const uint16_t  Rw11Cpu::kCPSTAT_V_CpuRust;
const uint16_t  Rw11Cpu::kCPSTAT_B_CpuRust;
const uint16_t  Rw11Cpu::kCPSTAT_M_CpuSusp;
const uint16_t  Rw11Cpu::kCPSTAT_M_CpuGo;
const uint16_t  Rw11Cpu::kCPSTAT_M_CmdMErr;
const uint16_t  Rw11Cpu::kCPSTAT_M_CmdErr;

const uint16_t  Rw11Cpu::kCPURUST_INIT;
const uint16_t  Rw11Cpu::kCPURUST_HALT;
const uint16_t  Rw11Cpu::kCPURUST_RESET;
const uint16_t  Rw11Cpu::kCPURUST_STOP;
const uint16_t  Rw11Cpu::kCPURUST_STEP;
const uint16_t  Rw11Cpu::kCPURUST_SUSP;
const uint16_t  Rw11Cpu::kCPURUST_HBPT;
const uint16_t  Rw11Cpu::kCPURUST_RUNS;
const uint16_t  Rw11Cpu::kCPURUST_VECFET;
const uint16_t  Rw11Cpu::kCPURUST_RECRSV;
const uint16_t  Rw11Cpu::kCPURUST_SFAIL;
const uint16_t  Rw11Cpu::kCPURUST_VFAIL;

const uint16_t  Rw11Cpu::kCPAH_M_ADDR;
const uint16_t  Rw11Cpu::kCPAH_M_22BIT;
const uint16_t  Rw11Cpu::kCPAH_M_UBMAP;
const uint16_t  Rw11Cpu::kCPAH_M_UBM22;

const uint16_t  Rw11Cpu::kCPMEMBE_M_STICK;
const uint16_t  Rw11Cpu::kCPMEMBE_M_BE;

const uint8_t   Rw11Cpu::kStat_M_CmdErr;
const uint8_t   Rw11Cpu::kStat_M_CmdMErr;
const uint8_t   Rw11Cpu::kStat_M_CpuSusp;
const uint8_t   Rw11Cpu::kStat_M_CpuGo;

const uint16_t  Rw11Cpu::kSCBASE;
const uint16_t  Rw11Cpu::kSCCNTL;
const uint16_t  Rw11Cpu::kSCADDR;
const uint16_t  Rw11Cpu::kSCDATA;

const uint16_t  Rw11Cpu::kCMBASE;
const uint16_t  Rw11Cpu::kCMCNTL;
const uint16_t  Rw11Cpu::kCMSTAT;
const uint16_t  Rw11Cpu::kCMADDR;
const uint16_t  Rw11Cpu::kCMDATA;
const uint16_t  Rw11Cpu::kCMIADDR;
const uint16_t  Rw11Cpu::kCMIPC;
const uint16_t  Rw11Cpu::kCMIREG;
const uint16_t  Rw11Cpu::kCMIMAL;

const uint16_t  Rw11Cpu::kHBBASE;
const uint16_t  Rw11Cpu::kHBSIZE;
const uint16_t  Rw11Cpu::kHBNMAX;
const uint16_t  Rw11Cpu::kHBCNTL;
const uint16_t  Rw11Cpu::kHBSTAT;
const uint16_t  Rw11Cpu::kHBHILIM;
const uint16_t  Rw11Cpu::kHBLOLIM;

const uint16_t  Rw11Cpu::kIMBASE;
const uint16_t  Rw11Cpu::kIMCNTL;
const uint16_t  Rw11Cpu::kIMSTAT;
const uint16_t  Rw11Cpu::kIMHILIM;
const uint16_t  Rw11Cpu::kIMLOLIM;
const uint16_t  Rw11Cpu::kIMADDR;
const uint16_t  Rw11Cpu::kIMDATA;

const uint16_t  Rw11Cpu::kKWLBASE;
const uint16_t  Rw11Cpu::kKWPBASE;
const uint16_t  Rw11Cpu::kKWPCSR;
const uint16_t  Rw11Cpu::kKWPCSB;
const uint16_t  Rw11Cpu::kKWPCTR;
const uint16_t  Rw11Cpu::kIISTBASE;
const uint16_t  Rw11Cpu::kIISTACR;
const uint16_t  Rw11Cpu::kIISTADR;

//------------------------------------------+-----------------------------------
//! Constructor

Rw11Cpu::Rw11Cpu(const std::string& type)
  : fpW11(nullptr),
    fType(type),
    fIndex(0),
    fBase(0),
    fIBase(0x4000),
    fHasScnt(false),
    fHasCmon(false),
    fHasHbpt(0),
    fHasIbmon(false),
    fHasKw11l(false),
    fHasKw11p(false),
    fHasIist(false),
    fCpuAct(0),
    fCpuStat(0),
    fCpuActMutex(),
    fCpuActCond(),
    fCntlMap(),
    fIAddrMap(),
    fRAddrMap(),
    fStats()
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11Cpu::~Rw11Cpu()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::Setup(Rw11* pw11)
{
  fpW11 = pw11;
  SetupStd();
  SetupOpt();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::AddCntl(const boost::shared_ptr<Rw11Cntl>& spcntl)
{
  if (!spcntl)
    throw Rexception("Rw11Cpu::AddCntl","Bad args: spcntl == 0");

  string name(spcntl->Name());
  if (fCntlMap.find(name) != fCntlMap.end()) 
    throw Rexception("Rw11Cpu::AddCntl",
                     "Bad state: duplicate controller name");;

  fCntlMap.insert(cmap_val_t(name, spcntl));
  spcntl->SetCpu(this);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11Cpu::TestCntl(const std::string& name) const
{
  return fCntlMap.find(name) != fCntlMap.end();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::ListCntl(std::vector<std::string>& list) const
{
  list.clear();
  for (cmap_cit_t it=fCntlMap.begin(); it!=fCntlMap.end(); it++) {
    list.push_back((it->second)->Name());
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rw11Cntl& Rw11Cpu::Cntl(const std::string& name) const
{
  cmap_cit_t it=fCntlMap.find(name);
  if (it == fCntlMap.end())
    throw Rexception("Rw11Cpu::Cntl()",
                     "Bad args: controller name '" + name + "' unknown");
  return *(it->second);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::Start()
{
  for (cmap_cit_t it=fCntlMap.begin(); it!=fCntlMap.end(); it++) {
    Rw11Cntl& cntl(*(it->second));
    cntl.Probe();
    if (cntl.ProbeStatus().Found() && cntl.Enable()) {
      cntl.Start();
    }
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string Rw11Cpu::NextCntlName(const std::string& base) const
{
  for (char let='a'; let<='z'; let++) {
    string name = base + let;
    if (fCntlMap.find(name) == fCntlMap.end()) return name;
  }
  throw Rexception("Rw11Cpu::NextCntlName", 
                   "Bad args: all controller letters used for '" + base + "'");
  return "";
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11Cpu::AddMembe(RlinkCommandList& clist, uint16_t be, bool stick)
{
  uint16_t data = be & kCPMEMBE_M_BE;
  if (stick) data |= kCPMEMBE_M_STICK;
  return clist.AddWreg(fBase+kCPMEMBE, data);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11Cpu::AddRibr(RlinkCommandList& clist, uint16_t ibaddr)
{
  if ((ibaddr & 0160001) != 0160000) 
    throw Rexception("Rw11Cpu::AddRibr", "ibaddr out of IO page or odd");
  
  return clist.AddRreg(IbusRemoteAddr(ibaddr));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11Cpu::AddWibr(RlinkCommandList& clist, uint16_t ibaddr, uint16_t data)
{
  if ((ibaddr & 0160001) != 0160000)
    throw Rexception("Rw11Cpu::AddWibr", "ibaddr out of IO page or odd");

  return clist.AddWreg(IbusRemoteAddr(ibaddr), data);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
int Rw11Cpu::AddRbibr(RlinkCommandList& clist, uint16_t ibaddr, size_t size)
{
  if ((ibaddr & 0160001) != 0160000) 
    throw Rexception("Rw11Cpu::AddRbibr", "ibaddr out of IO page or odd");
  
  return clist.AddRblk(IbusRemoteAddr(ibaddr), size);
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs
int Rw11Cpu::AddWbibr(RlinkCommandList& clist, uint16_t ibaddr, 
                      std::vector<uint16_t> block)
{
  if ((ibaddr & 0160001) != 0160000) 
    throw Rexception("Rw11Cpu::AddWbibr", "ibaddr out of IO page or odd");
  
  return clist.AddWblk(IbusRemoteAddr(ibaddr), block);
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11Cpu::AddLalh(RlinkCommandList& clist, uint32_t addr, uint16_t mode)
{
  uint16_t al = uint16_t(addr);
  uint16_t ah = uint16_t(addr>>16) & kCPAH_M_ADDR;
  ah |= mode & (kCPAH_M_22BIT|kCPAH_M_UBMAP);
  int ind = clist.AddWreg(fBase+kCPAL, al);
  clist.AddWreg(fBase+kCPAH, ah);
  return ind;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::ModLalh(RlinkCommandList& clist, size_t ind, 
                      uint32_t addr, uint16_t mode)
{
  if (ind + 1 > clist.Size())
    throw Rexception("Rw11Cpu::ModLalh","Bad args: ind out of range");

  uint16_t al = uint16_t(addr);
  uint16_t ah = uint16_t(addr>>16) & kCPAH_M_ADDR;
  ah |= mode & (kCPAH_M_22BIT|kCPAH_M_UBMAP);

  RlinkCommand& cmdal = clist[ind];
  RlinkCommand& cmdah = clist[ind+1];

  if (cmdal.Command() != RlinkCommand::kCmdWreg ||
      cmdal.Address() != fBase+kCPAL ||
      cmdah.Command() != RlinkCommand::kCmdWreg ||
      cmdah.Address() != fBase+kCPAH)
    throw Rexception("Rw11Cpu::ModLalh","Bad state: not writing cpal/cpah");

  cmdal.SetData(al);
  cmdah.SetData(ah);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11Cpu::AddRMem(RlinkCommandList& clist, uint32_t addr, uint16_t* buf, 
                     size_t size, uint16_t mode, bool singleblk)
{
  size_t blkmax = Connect().BlockSizeMax();
  if (singleblk && size > blkmax)
    throw Rexception("Rw11Cpu::AddRMem",
                     "Bad args: singleblk==true && size > BlockSizeMax()");

  int ind = AddLalh(clist, addr, mode);
  while (size > 0) {
    size_t bsize = (size>blkmax) ? blkmax : size;
    clist.AddRblk(fBase+kCPMEMI, buf, bsize);
    buf  += bsize;
    size -= bsize;
  }
  return ind;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11Cpu::AddWMem(RlinkCommandList& clist, uint32_t addr,
                     const uint16_t* buf, size_t size, 
                     uint16_t mode, bool singleblk)
{
  size_t blkmax = Connect().BlockSizeMax();
  if (singleblk && size > blkmax)
    throw Rexception("Rw11Cpu::AddWMem",
                     "Bad args: singleblk==true && size > BlockSizeMax()");

  int ind = AddLalh(clist, addr, mode);
  while (size > 0) {
    size_t bsize = (size>blkmax) ? blkmax : size;
    clist.AddWblk(fBase+kCPMEMI, buf, bsize);
    buf  += bsize;
    size -= bsize;
  }
  return ind;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11Cpu::MemRead(uint16_t addr, std::vector<uint16_t>& data, 
                      size_t nword, RerrMsg& emsg)
{
  size_t blkmax = Connect().BlockSizePrudent();
  data.resize(nword);
  size_t ndone = 0;
  while (nword>ndone) {
    size_t nblk = min(blkmax, nword-ndone);
    RlinkCommandList clist;
    clist.AddWreg(fBase+kCPAL, addr+2*ndone);
    clist.AddRblk(fBase+kCPMEMI, data.data()+ndone, nblk);
    if (!Server().Exec(clist, emsg)) return false;
    ndone += nblk;
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11Cpu::MemWrite(uint16_t addr, const std::vector<uint16_t>& data,
                       RerrMsg& emsg)
{
  size_t blkmax = Connect().BlockSizePrudent();
  size_t nword = data.size();
  size_t ndone = 0;
  while (nword>ndone) {
    size_t nblk = min(blkmax, nword-ndone);
    RlinkCommandList clist;
    clist.AddWreg(fBase+kCPAL, addr+2*ndone);
    clist.AddWblk(fBase+kCPMEMI, data.data()+ndone, nblk);
    if (!Server().Exec(clist, emsg)) return false;
    ndone += nblk;
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11Cpu::ProbeCntl(Rw11Probe& dsc)
{
  if (!(dsc.fProbeInt | dsc.fProbeRem) || dsc.fAddr == 0) 
    throw Rexception("Rw11Cpu::Probe",
                     "Bad args: fAddr == 0 or fProbeInt|fProbeRem == false");

  if (!dsc.fProbeDone) {
    RlinkCommandList clist;
    int iib = -1;
    int irb = -1;
    if (dsc.fProbeInt) {
      clist.AddWreg(fBase+kCPAL,  dsc.fAddr);
      iib = clist.AddRreg(fBase+kCPMEM);
      clist.SetLastExpectStatus(0,0);       // disable stat check
    }
    if (dsc.fProbeRem) {
      irb = AddRibr(clist, dsc.fAddr);
      clist.SetLastExpectStatus(0,0);       // disable stat check
    }

    dsc.fFoundInt = false;
    dsc.fFoundRem = false;
    dsc.fDataInt  = 0;
    dsc.fDataRem  = 0;
    
    Server().Exec(clist);

    if (dsc.fProbeInt) {
      dsc.fFoundInt = (clist[iib].Status() & 
                         (RlinkCommand::kStat_M_RbTout |
                          RlinkCommand::kStat_M_RbNak  |
                          RlinkCommand::kStat_M_RbErr)) ==0;
      if (dsc.fFoundInt) dsc.fDataInt = clist[iib].Data();
    }
    if (dsc.fProbeRem) {
      dsc.fFoundRem = (clist[irb].Status() & 
                         (RlinkCommand::kStat_M_RbTout |
                          RlinkCommand::kStat_M_RbNak  |
                          RlinkCommand::kStat_M_RbErr)) ==0;
      if (dsc.fFoundRem) dsc.fDataRem = clist[irb].Data();
    }
    dsc.fProbeDone = true;
  }

  return dsc.Found();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

// absolute binary format described in notes_ptape.txt

bool Rw11Cpu::LoadAbs(const std::string& fname, RerrMsg& emsg, bool trace)
{
  int fd = open(fname.c_str(), O_RDONLY);

  if (fd < 0) {
    emsg.InitErrno("Rw11Cpu::LoadAbs()", string("open() for '") + fname + 
                   "' failed: ", errno);
    return false;
  }
  
  enum states {
    s_chr0,
    s_chr1,
    s_cntlow,
    s_cnthgh,
    s_adrlow,
    s_adrhgh,
    s_data,
    s_chksum
  };

  typedef std::map<uint16_t, uint16_t> obmap_t;
  //typedef obmap_t::iterator         obmap_it_t;
  typedef obmap_t::const_iterator   obmap_cit_t;
  typedef obmap_t::value_type       obmap_val_t;

  obmap_t oddbyte;                          // odd byte cache

  vector<uint16_t> data;
  data.reserve(256);
  
  int chrnum = -1;                          // char number in block
  int blknum = 0;                           // block number
  int bytcnt = 0;                           // byte count
  uint16_t ldaddr = 0;                      // load address
  uint8_t chksum = 0;                       // check sum
  uint16_t addr = 0;                        // current address
  uint16_t word = 0;                        // current word

  bool ok = false;
  bool go = true;
  enum states state = s_chr0;

  while (go) {
    uint8_t byte;
    int irc = read(fd, &byte, 1);
    if (irc == 0) {
      if (state == s_chr0) {
        ok = true;
      } else {
        emsg.Init("Rw11Cpu::LoadAbs()", "unexpected EOF");
      }
      break;
    } else if (irc < 0) {
      emsg.InitErrno("Rw11Cpu::LoadAbs()", "read() failed: ", errno);
      break;
    }

    chrnum += 1;
    chksum += byte;

    //cout << "+++1 " << blknum << "," << chrnum << " s=" << state << " : " 
    //     << RosPrintBvi(byte,8) << endl;

    switch (state) {
    case s_chr0:
      if (byte == 0) {
        chrnum = -1;
        state = s_chr0;
      } else if (byte == 1) {
        state = s_chr1;
      } else {
        emsg.InitPrintf("Rw11Cpu::LoadAbs()", 
                        "unexpected start-of-block %3.3o", byte);
        go = false;
      }
      break;

    case s_chr1:
      if (byte == 0) {
        state = s_cntlow;
      } else {
        emsg.InitPrintf("Rw11Cpu::LoadAbs()", 
                        "unexpected 2nd char %3.3o", byte);
        go = false;
      }
      break;
      
    case s_cntlow:
      bytcnt = byte;
      state  = s_cnthgh;
      break;
      
    case s_cnthgh:
      bytcnt |= uint16_t(byte) << 8;
      state  = s_adrlow;
      break;
      
    case s_adrlow:
      ldaddr = byte;
      state = s_adrhgh;
      break;
      
    case s_adrhgh:
      ldaddr |= uint16_t(byte) << 8;
      addr = ldaddr;
      word = 0;
      if ((addr & 0x01) == 1 && bytcnt > 6) {
        obmap_cit_t it = oddbyte.find(addr);
        if (it != oddbyte.end()) {
          word = it->second;
        } else {
          if (trace) {
            RlogMsg lmsg(LogFile());
            lmsg << "LoadAbs-W: no low byte data for " << RosPrintBvi(addr,8);
          }
        }
      }
      
      if (trace) {
        RlogMsg lmsg(Connect().LogFile());
        lmsg << "LoadAbs-I: block " << RosPrintf(blknum,"d",3)
             << ", length " << RosPrintf(bytcnt-6,"d",5)
             << " byte, address " << RosPrintBvi(ldaddr,8)
             << ":" << RosPrintBvi(uint16_t(ldaddr+(bytcnt-6)-1),8);
      }
      state = (bytcnt == 6) ? s_chksum : s_data;
      break;
    
    case s_data:
      if ((addr & 0x01) == 0) {             // even (low) byte
        word = byte;
      } else {                              // odd (high) byte
        word |= uint16_t(byte) << 8;
        data.push_back(word);
      }
      addr += 1;
      if (chrnum == bytcnt-1) state = s_chksum;
      break;
      
    case s_chksum:
      if (chksum != 0) {
        emsg.InitPrintf("Rw11Cpu::LoadAbs()", "check sum error %3.3o", chksum);
        go = false;
      } else if (bytcnt == 6) {
        if (trace) {
          RlogMsg lmsg(Connect().LogFile());
          lmsg << "LoadAbs-I: start address " << RosPrintBvi(ldaddr,8);
        }
        go = false;
        ok = true;
      } else {
        if ((addr & 0x01) == 1) {           // high byte not yet seen
          data.push_back(word);             // zero fill high byte
          oddbyte.insert(obmap_val_t(addr,word)); // store even byte for later
        }

        //cout << "+++2 " << RosPrintBvi(ldaddr,8) 
        //     << " " << data.size() << endl;
        
        if (!MemWrite(ldaddr, data, emsg)) {
          go = false;
        }
        data.clear();
      }
      chrnum = -1;
      blknum += 1;
      state = s_chr0;
      break;

    } // switch(state)
  } // while(go)
  
  close(fd);
  
  return ok;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11Cpu::Boot(const std::string& uname, RerrMsg& emsg)
{
  string cname;
  size_t uind=0;
  for (size_t i=0; i<uname.length(); i++) {
    char c = uname[i];
    if (c >= '0' && c <= '9') {
      string unum = uname.substr(i);
      uind = ::atoi(unum.c_str());
      break;
    } else {
      cname.push_back(c);
    }
  }

  if (!TestCntl(cname)) {
    emsg.Init("Rw11Cpu::Boot", string("controller '") + cname + "' not known");
    return false;
  }

  Rw11Cntl& cntl = Cntl(cname);
  if (uind >= cntl.NUnit()) {
    emsg.Init("Rw11Cpu::Boot", string("unit number '") + uname + "' invalid");
    return false;
  }

  vector<uint16_t> code;
  uint16_t aload = 0;
  uint16_t astart = 0;

  if (!cntl.BootCode(uind, code, aload, astart) || code.size()==0) {
    emsg.Init("Rw11Cpu::Boot", string("boot not supported for controller '") 
              + cname + "'");
    return false;
  }

  // stop and reset cpu, just in case
  RlinkCommandList clist;
  clist.AddWreg(fBase+kCPCNTL, kCPFUNC_STOP);   // stop cpu
  clist.AddWreg(fBase+kCPCNTL, kCPFUNC_CRESET); // init cpu and bus
  if (!Server().Exec(clist, emsg)) return false;

  // load boot code
  if (!MemWrite(aload, code, emsg)) return false;
  
  // and start cpu at boot loader start address
  clist.Clear();
  clist.AddWreg(fBase+kCPPC, astart);           // load PC
  clist.AddWreg(fBase+kCPCNTL, kCPFUNC_START);  // and start
  SetCpuActUp();
  if (!Server().Exec(clist, emsg)) return false;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::SetCpuActUp()
{
  boost::lock_guard<boost::mutex> lock(fCpuActMutex);
  fCpuAct  = true;
  fCpuStat = 0;
  fCpuActCond.notify_all();
  return;
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::SetCpuActDown(uint16_t stat)
{
  if ((stat & kCPSTAT_M_CpuGo) == 0 || (stat & kCPSTAT_M_CpuSusp) != 0 ) {
    boost::lock_guard<boost::mutex> lock(fCpuActMutex);
    fCpuAct  = false;
    fCpuStat = stat;
    fCpuActCond.notify_all();
  }
  return;
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11Cpu::WaitCpuActDown(const Rtime& tout, Rtime& twait)
{
  Rtime tstart(CLOCK_MONOTONIC);
  twait.Clear();
  
  boost::system_time timeout(boost::posix_time::max_date_time);
  if (tout.IsPositive()) 
    // Note: boost::posix_time might lack the nanoseconds ctor (if build with
    //       microsecond precision), thus use microsecond.
    timeout = boost::get_system_time() + 
              boost::posix_time::seconds(tout.Sec()) +
              boost::posix_time::microseconds(tout.NSec()/1000);
  boost::unique_lock<boost::mutex> lock(fCpuActMutex);
  while (fCpuAct) {
    if (!fCpuActCond.timed_wait(lock, timeout)) return -1;
  }
  twait = Rtime(CLOCK_MONOTONIC) - tstart;
  return twait.IsPositive();
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::AllIAddrMapInsert(const std::string& name, uint16_t ibaddr)
{
  IAddrMapInsert(name, ibaddr);
  uint16_t rbaddr = IbusRemoteAddr(ibaddr);
  RAddrMapInsert(name, rbaddr);

  // add ix. to name in common Connect AddrMap to keep name unique
  string cname = "i";
  cname += '0'+Index();
  cname += '.';
  cname += name;
  Connect().AddrMapInsert(cname, rbaddr);

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::AllRAddrMapInsert(const std::string& name, uint16_t rbaddr)
{
  RAddrMapInsert(name, rbaddr);

  // add cx. to name in common Connect AddrMap to keep name unique
  string cname = "c";
  cname += '0'+Index();
  cname += '.';
  cname += name;
  Connect().AddrMapInsert(cname, rbaddr);

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::W11AttnHandler()
{
  RlinkCommandList clist;
  clist.AddRreg(fBase+kCPSTAT);
  Server().Exec(clist);
  SetCpuActDown(clist[0].Data());
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::Dump(std::ostream& os, int ind, const char* text,
                   int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11Cpu @ " << this << endl;

  os << bl << "  fpW11:           " << fpW11 << endl;
  os << bl << "  fType:           " << fType << endl;
  os << bl << "  fIndex:          " << fIndex << endl;
  os << bl << "  fBase:           " << RosPrintf(fBase,"$x0",4) << endl;
  os << bl << "  fIBase:          " << RosPrintf(fIBase,"$x0",4) << endl;
  os << bl << "  fHasScnt:        " << fHasScnt << endl;
  os << bl << "  fHasCmon:        " << fHasCmon << endl;
  os << bl << "  fHasHbpt:        " << fHasHbpt << endl;
  os << bl << "  fHasIbmon:       " << fHasIbmon << endl;
  os << bl << "  fCpuAct:         " << fCpuAct << endl;
  os << bl << "  fCpuStat:        " << RosPrintf(fCpuStat,"$x0",4) << endl;
  os << bl << "  fCntlMap:        " << endl;
  for (cmap_cit_t it=fCntlMap.begin(); it!=fCntlMap.end(); it++) {
    os << bl << "    " << RosPrintf((it->first).c_str(), "-s",8)
       << " : " << it->second << endl;
  }
  fIAddrMap.Dump(os, ind+2, "fIAddrMap: ", detail-1);
  fRAddrMap.Dump(os, ind+2, "fRAddrMap: ", detail-1);
  fStats.Dump(os, ind+2, "fStats: ", detail);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::SetupStd()
{
  // add control port address rbus mappings
  AllRAddrMapInsert("conf" , Base()+kCPCONF);
  AllRAddrMapInsert("cntl" , Base()+kCPCNTL);
  AllRAddrMapInsert("stat" , Base()+kCPSTAT);
  AllRAddrMapInsert("psw"  , Base()+kCPPSW);
  AllRAddrMapInsert("al"   , Base()+kCPAL);
  AllRAddrMapInsert("ah"   , Base()+kCPAH);
  AllRAddrMapInsert("mem"  , Base()+kCPMEM);
  AllRAddrMapInsert("memi" , Base()+kCPMEMI);
  AllRAddrMapInsert("r0"   , Base()+kCPR0);
  AllRAddrMapInsert("r1"   , Base()+kCPR0+1);
  AllRAddrMapInsert("r2"   , Base()+kCPR0+2);
  AllRAddrMapInsert("r3"   , Base()+kCPR0+3);
  AllRAddrMapInsert("r4"   , Base()+kCPR0+4);
  AllRAddrMapInsert("r5"   , Base()+kCPR0+5);
  AllRAddrMapInsert("sp"   , Base()+kCPR0+6);
  AllRAddrMapInsert("pc"   , Base()+kCPR0+7);
  AllRAddrMapInsert("membe", Base()+kCPMEMBE);

  // add cpu register address ibus and rbus mappings
  AllIAddrMapInsert("psw"    , 0177776);
  AllIAddrMapInsert("stklim" , 0177774);
  AllIAddrMapInsert("pirq"   , 0177772);
  AllIAddrMapInsert("mbrk"   , 0177770);
  AllIAddrMapInsert("cpuerr" , 0177766);
  AllIAddrMapInsert("sysid"  , 0177764);
  AllIAddrMapInsert("hisize" , 0177762);
  AllIAddrMapInsert("losize" , 0177760);

  AllIAddrMapInsert("hm"     , 0177752);
  AllIAddrMapInsert("maint"  , 0177750);
  AllIAddrMapInsert("cntrl"  , 0177746);
  AllIAddrMapInsert("syserr" , 0177744);
  AllIAddrMapInsert("hiaddr" , 0177742);
  AllIAddrMapInsert("loaddr" , 0177740);

  AllIAddrMapInsert("ssr2"   , 0177576);
  AllIAddrMapInsert("ssr1"   , 0177574);
  AllIAddrMapInsert("ssr0"   , 0177572);

  AllIAddrMapInsert("sdreg"  , 0177570);

  AllIAddrMapInsert("ssr3"   , 0172516);

  // add mmu segment register files
  string sdr = "sdr";
  string sar = "sar";
  for (char i=0; i<8; i++) {
    char ichar = '0'+i;
    AllIAddrMapInsert(sdr+"ki."+ichar, 0172300+2*i);
    AllIAddrMapInsert(sdr+"kd."+ichar, 0172320+2*i);
    AllIAddrMapInsert(sar+"ki."+ichar, 0172340+2*i);
    AllIAddrMapInsert(sar+"kd."+ichar, 0172360+2*i);
    AllIAddrMapInsert(sdr+"si."+ichar, 0172200+2*i);
    AllIAddrMapInsert(sdr+"sd."+ichar, 0172220+2*i);
    AllIAddrMapInsert(sar+"si."+ichar, 0172240+2*i);
    AllIAddrMapInsert(sar+"sd."+ichar, 0172260+2*i);
    AllIAddrMapInsert(sdr+"ui."+ichar, 0177600+2*i);
    AllIAddrMapInsert(sdr+"ud."+ichar, 0177620+2*i);
    AllIAddrMapInsert(sar+"ui."+ichar, 0177640+2*i);
    AllIAddrMapInsert(sar+"ud."+ichar, 0177660+2*i);
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::SetupOpt()
{
  // probe optional cpu components: dmscnt, dmcmon, dmhbpt and ibmon
  RlinkCommandList clist;

  int isc =  clist.AddRreg(Base()+kSCBASE+kSCCNTL);
  clist.SetLastExpectStatus(0,0);        // disable stat check

  int icm =  clist.AddRreg(Base()+kCMBASE+kCMCNTL);
  clist.SetLastExpectStatus(0,0); 

  int ihb[kHBNMAX];
  for (int i=0; i<kHBNMAX; i++) {
    ihb[i] =  clist.AddRreg(Base()+kHBBASE+i*kHBSIZE+kHBCNTL);
    clist.SetLastExpectStatus(0,0); 
  }
  int iim = AddRibr(clist, kIMBASE+kIMCNTL);
  clist.SetLastExpectStatus(0,0); 

  // probe auxilliary cpu components: kw11-l, kw11-p, iist
  int ikwl= AddRibr(clist, kKWLBASE);
  clist.SetLastExpectStatus(0,0); 

  int ikwp= AddRibr(clist, kKWPBASE + kKWPCSR);
  clist.SetLastExpectStatus(0,0); 

  int iii= AddRibr(clist, kIISTBASE + kIISTACR);
  clist.SetLastExpectStatus(0,0); 

  Connect().Exec(clist);

  uint8_t statmsk = RlinkCommand::kStat_M_RbTout |
                    RlinkCommand::kStat_M_RbNak  |
                    RlinkCommand::kStat_M_RbErr;
  
  fHasScnt = (clist[isc].Status() & statmsk) == 0;
  if (fHasScnt) {
    uint16_t base = Base() + kSCBASE;
    AllRAddrMapInsert("sc.cntl" , base + kSCCNTL);
    AllRAddrMapInsert("sc.addr" , base + kSCADDR);
    AllRAddrMapInsert("sc.data" , base + kSCDATA);
  }

  fHasCmon = (clist[icm].Status() & statmsk) == 0;
  if (fHasCmon) {
    uint16_t base = Base() + kCMBASE;
    AllRAddrMapInsert("cm.cntl"  , base + kCMCNTL);
    AllRAddrMapInsert("cm.stat"  , base + kCMSTAT);
    AllRAddrMapInsert("cm.addr"  , base + kCMADDR);
    AllRAddrMapInsert("cm.data"  , base + kCMDATA);
    AllRAddrMapInsert("cm.iaddr" , base + kCMIADDR);
    AllRAddrMapInsert("cm.ipc"   , base + kCMIPC);
    AllRAddrMapInsert("cm.ireg"  , base + kCMIREG);
    AllRAddrMapInsert("cm.imal"  , base + kCMIMAL);
  }
  
  fHasHbpt = 0;
  for (int i=0; i<kHBNMAX; i++) {
    if ((clist[ihb[i]].Status() & statmsk) != 0) break;
    fHasHbpt += 1;
    uint16_t base = Base() + kHBBASE + i*kHBSIZE;
    std::string pref = "hb";
    pref += '0'+i;
    AllRAddrMapInsert(pref+".cntl"  , base + kHBCNTL);
    AllRAddrMapInsert(pref+".stat"  , base + kHBSTAT);
    AllRAddrMapInsert(pref+".hilim" , base + kHBHILIM);
    AllRAddrMapInsert(pref+".lolim" , base + kHBLOLIM);
  }

  fHasIbmon = (clist[iim].Status() & statmsk) == 0;
  if (fHasIbmon) {
    AllIAddrMapInsert("im.cntl",  kIMBASE + kIMCNTL);
    AllIAddrMapInsert("im.stat",  kIMBASE + kIMSTAT);
    AllIAddrMapInsert("im.hilim", kIMBASE + kIMHILIM);
    AllIAddrMapInsert("im.lolim", kIMBASE + kIMLOLIM);
    AllIAddrMapInsert("im.addr",  kIMBASE + kIMADDR);
    AllIAddrMapInsert("im.data",  kIMBASE + kIMDATA);
  }

  fHasKw11l = (clist[ikwl].Status() & statmsk) == 0;
  if (fHasKw11l) {
    AllIAddrMapInsert("kwl.csr",  kKWLBASE);
  }

  fHasKw11p = (clist[ikwp].Status() & statmsk) == 0;
  if (fHasKw11p) {
    AllIAddrMapInsert("kwp.csr",  kKWPBASE + kKWPCSR);
    AllIAddrMapInsert("kwp.csb",  kKWPBASE + kKWPCSB);
    AllIAddrMapInsert("kwp.ctr",  kKWPBASE + kKWPCTR);
  }
  
  fHasIist = (clist[iii].Status() & statmsk) == 0;
  if (fHasIist) {
    AllIAddrMapInsert("iist.acr",   kIISTBASE + kIISTACR);
    AllIAddrMapInsert("iist.adr",   kIISTBASE + kIISTADR);
  }

  return;
}


} // end namespace Retro
