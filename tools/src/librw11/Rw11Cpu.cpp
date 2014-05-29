// $Id: Rw11Cpu.cpp 521 2013-05-20 22:16:45Z mueller $
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
// 2013-04-14   506   1.0.1  add AddLalh(),AddRMem(),AddWMem()
// 2013-04-12   504   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11Cpu.cpp 521 2013-05-20 22:16:45Z mueller $
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

const uint16_t  Rw11Cpu::kCp_addr_conf;  
const uint16_t  Rw11Cpu::kCp_addr_cntl;  
const uint16_t  Rw11Cpu::kCp_addr_stat;  
const uint16_t  Rw11Cpu::kCp_addr_psw;  
const uint16_t  Rw11Cpu::kCp_addr_al;  
const uint16_t  Rw11Cpu::kCp_addr_ah;  
const uint16_t  Rw11Cpu::kCp_addr_mem;  
const uint16_t  Rw11Cpu::kCp_addr_memi;  
const uint16_t  Rw11Cpu::kCp_addr_r0;  
const uint16_t  Rw11Cpu::kCp_addr_pc;  
const uint16_t  Rw11Cpu::kCp_addr_ibrb;  
const uint16_t  Rw11Cpu::kCp_addr_ibr;  

const uint16_t  Rw11Cpu::kCp_func_noop;  
const uint16_t  Rw11Cpu::kCp_func_start;  
const uint16_t  Rw11Cpu::kCp_func_stop;  
const uint16_t  Rw11Cpu::kCp_func_cont;  
const uint16_t  Rw11Cpu::kCp_func_step;  
const uint16_t  Rw11Cpu::kCp_func_reset; 

const uint16_t  Rw11Cpu::kCp_stat_m_cpurust;
const uint16_t  Rw11Cpu::kCp_stat_v_cpurust;
const uint16_t  Rw11Cpu::kCp_stat_b_cpurust;
const uint16_t  Rw11Cpu::kCp_stat_m_cpuhalt;
const uint16_t  Rw11Cpu::kCp_stat_m_cpugo;
const uint16_t  Rw11Cpu::kCp_stat_m_cmdmerr;
const uint16_t  Rw11Cpu::kCp_stat_m_cmderr;

const uint16_t  Rw11Cpu::kCp_cpurust_init;
const uint16_t  Rw11Cpu::kCp_cpurust_halt;
const uint16_t  Rw11Cpu::kCp_cpurust_reset;
const uint16_t  Rw11Cpu::kCp_cpurust_stop;
const uint16_t  Rw11Cpu::kCp_cpurust_step;
const uint16_t  Rw11Cpu::kCp_cpurust_susp;
const uint16_t  Rw11Cpu::kCp_cpurust_runs;
const uint16_t  Rw11Cpu::kCp_cpurust_vecfet;
const uint16_t  Rw11Cpu::kCp_cpurust_recrsv;
const uint16_t  Rw11Cpu::kCp_cpurust_sfail;
const uint16_t  Rw11Cpu::kCp_cpurust_vfail;

const uint16_t  Rw11Cpu::kCp_ah_m_addr;
const uint16_t  Rw11Cpu::kCp_ah_m_22bit;
const uint16_t  Rw11Cpu::kCp_ah_m_ubmap;

//------------------------------------------+-----------------------------------
//! Constructor

Rw11Cpu::Rw11Cpu(const std::string& type)
  : fpW11(0),
    fType(type),
    fIndex(0),
    fBase(0),
    fCpuGo(0),
    fCpuStat(0),
    fCpuGoMutex(),
    fCpuGoCond(),
    fCntlMap(),
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
  // command base: 'cn.', where n is cpu index
  string cbase = "c";
  cbase += '0'+Index();
  cbase += '.';
  Connect().AddrMapInsert(cbase+"conf", Base()+kCp_addr_conf);
  Connect().AddrMapInsert(cbase+"cntl", Base()+kCp_addr_cntl);
  Connect().AddrMapInsert(cbase+"stat", Base()+kCp_addr_stat);
  Connect().AddrMapInsert(cbase+"psw" , Base()+kCp_addr_psw);
  Connect().AddrMapInsert(cbase+"al"  , Base()+kCp_addr_al);
  Connect().AddrMapInsert(cbase+"ah"  , Base()+kCp_addr_ah);
  Connect().AddrMapInsert(cbase+"mem" , Base()+kCp_addr_mem);
  Connect().AddrMapInsert(cbase+"memi", Base()+kCp_addr_memi);
  Connect().AddrMapInsert(cbase+"r0"  , Base()+kCp_addr_r0);
  Connect().AddrMapInsert(cbase+"r1"  , Base()+kCp_addr_r0+1);
  Connect().AddrMapInsert(cbase+"r2"  , Base()+kCp_addr_r0+2);
  Connect().AddrMapInsert(cbase+"r3"  , Base()+kCp_addr_r0+3);
  Connect().AddrMapInsert(cbase+"r4"  , Base()+kCp_addr_r0+4);
  Connect().AddrMapInsert(cbase+"r5"  , Base()+kCp_addr_r0+5);
  Connect().AddrMapInsert(cbase+"sp"  , Base()+kCp_addr_r0+6);
  Connect().AddrMapInsert(cbase+"pc"  , Base()+kCp_addr_r0+7);
  Connect().AddrMapInsert(cbase+"ibrb", Base()+kCp_addr_ibrb);
  // create names for ib window, line c0.ib00, c0.ib02,.., c0.ib76
  for (int i=0; i<32; i++) {
    string rname = cbase + "ib";
    rname += '0' + ((i>>2)&07);
    rname += '0' + ((i<<1)&07);
    Connect().AddrMapInsert(rname , Base()+kCp_addr_ibr+i);
  }
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

int Rw11Cpu::AddIbrb(RlinkCommandList& clist, uint16_t ibaddr)
{
  return clist.AddWreg(fBase+kCp_addr_ibrb, ibaddr & ~(077));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11Cpu::AddRibr(RlinkCommandList& clist, uint16_t ibaddr)
{
  uint16_t ibroff = (ibaddr & 077)/2;
  return clist.AddRreg(fBase+kCp_addr_ibr + ibroff);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11Cpu::AddWibr(RlinkCommandList& clist, uint16_t ibaddr, uint16_t data)
{
  uint16_t ibroff = (ibaddr & 077)/2;
  return clist.AddWreg(fBase+kCp_addr_ibr + ibroff, data);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11Cpu::AddLalh(RlinkCommandList& clist, uint32_t addr, uint16_t mode)
{
  uint16_t al = uint16_t(addr);
  uint16_t ah = uint16_t(addr>>16) & kCp_ah_m_addr;
  ah |= mode & (kCp_ah_m_22bit|kCp_ah_m_ubmap);
  int ind = clist.AddWreg(fBase+kCp_addr_al, al);
  clist.AddWreg(fBase+kCp_addr_ah, ah);
  return ind;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11Cpu::AddRMem(RlinkCommandList& clist, uint32_t addr,
                     uint16_t* buf, size_t size, uint16_t mode)
{
  int ind = AddLalh(clist, addr, mode);
  while (size > 0) {
    size_t bsize = (size>256) ? 256 : size;
    clist.AddRblk(fBase+kCp_addr_memi, buf, bsize);
    buf  += bsize;
    size -= bsize;
  }
  return ind;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11Cpu::AddWMem(RlinkCommandList& clist, uint32_t addr,
                     const uint16_t* buf, size_t size, uint16_t mode)
{
  int ind = AddLalh(clist, addr, mode);
  while (size > 0) {
    size_t bsize = (size>256) ? 256 : size;
    clist.AddWblk(fBase+kCp_addr_memi, buf, bsize);
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
  data.resize(nword);
  size_t ndone = 0;
  while (nword>ndone) {
    size_t nblk = min(size_t(256), nword-ndone);
    RlinkCommandList clist;
    clist.AddWreg(fBase+kCp_addr_al, addr+2*ndone);
    clist.AddRblk(fBase+kCp_addr_memi, data.data()+ndone, nblk);
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
  size_t nword = data.size();
  size_t ndone = 0;
  while (nword>ndone) {
    size_t nblk = min(size_t(256), nword-ndone);
    RlinkCommandList clist;
    clist.AddWreg(fBase+kCp_addr_al, addr+2*ndone);
    clist.AddWblk(fBase+kCp_addr_memi, data.data()+ndone, nblk);
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
      clist.AddWreg(fBase+kCp_addr_al,  dsc.fAddr);
      iib = clist.AddRreg(fBase+kCp_addr_mem);
      clist.LastExpect(new RlinkCommandExpect(0,0xff)); // disable stat checking
    }
    if (dsc.fProbeRem) {
      AddIbrb(clist, dsc.fAddr);
      irb = AddRibr(clist, dsc.fAddr);
      clist.LastExpect(new RlinkCommandExpect(0,0xff)); // disable stat checking
    }

    Server().Exec(clist);
    // FIXME_code: handle errors

    if (dsc.fProbeInt) {
      dsc.fFoundInt = (clist[iib].Status() & (RlinkCommand::kStat_M_RbNak |
                                              RlinkCommand::kStat_M_RbErr)) ==0;
    }
    if (dsc.fProbeRem) {
      dsc.fFoundRem = (clist[irb].Status() & (RlinkCommand::kStat_M_RbNak |
                                              RlinkCommand::kStat_M_RbErr)) ==0;
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
  typedef obmap_t::iterator         obmap_it_t;
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
      string unum = cname.substr(i);
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

  // FIXME_code: unit number not checked. Cntl doesn't even know about ...

  Rw11Cntl& cntl = Cntl(cname);

  vector<uint16_t> code;
  uint16_t aload = 0;
  uint16_t astart = 0;

  if (!cntl.BootCode(uind, code, aload, astart) || code.size()==0) {
    emsg.Init("Rw11Cpu::Boot", string("boot not supported for controller '") 
              + cname + "'");
    return false;
  }

  if (!MemWrite(aload, code, emsg)) return false;
  
  RlinkCommandList clist;
  clist.AddWreg(fBase+kCp_addr_pc, astart);
  clist.AddWreg(fBase+kCp_addr_cntl, kCp_func_start);
  SetCpuGoUp();
  if (!Server().Exec(clist, emsg)) return false;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::SetCpuGoUp()
{
  boost::lock_guard<boost::mutex> lock(fCpuGoMutex);
  fCpuGo   = true;
  fCpuStat = 0;
  fCpuGoCond.notify_all();
  return;
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::SetCpuGoDown(uint16_t stat)
{
  if ((stat & kCp_stat_m_cpugo) == 0) {
    boost::lock_guard<boost::mutex> lock(fCpuGoMutex);
    fCpuGo   = false;
    fCpuStat = stat;
    fCpuGoCond.notify_all();
  }
  return;
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

double Rw11Cpu::WaitCpuGoDown(double tout)
{
  boost::system_time t0(boost::get_system_time());
  boost::system_time timeout(boost::posix_time::max_date_time);
  if (tout > 0.) 
    timeout = t0 + boost::posix_time::microseconds((long)1E6 * tout);  
  boost::unique_lock<boost::mutex> lock(fCpuGoMutex);
  while (fCpuGo) {
    if (!fCpuGoCond.timed_wait(lock, timeout)) return -1.;
  }
  boost::posix_time::time_duration dt = boost::get_system_time() - t0;
  return double(dt.ticks()) / dt.ticks_per_second();
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::W11AttnHandler()
{
  RlinkCommandList clist;
  clist.AddRreg(fBase+kCp_addr_stat);
  if (Server().Exec(clist)) 
    SetCpuGoDown(clist[0].Data());
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cpu::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11Cpu @ " << this << endl;

  os << bl << "  fpW11:           " << fpW11 << endl;
  os << bl << "  fType:           " << fType << endl;
  os << bl << "  fIndex:          " << fIndex << endl;
  os << bl << "  fBase:           " << RosPrintf(fBase,"$x0",4) << endl;
  os << bl << "  fCpuGo:          " << fCpuGo << endl;
  os << bl << "  fCpuStat:        " << RosPrintf(fCpuStat,"$x0",4) << endl;
  os << bl << "  fCntlMap:        " << endl;
  for (cmap_cit_t it=fCntlMap.begin(); it!=fCntlMap.end(); it++) {
    os << bl << "    " << RosPrintf((it->first).c_str(), "-s",8)
       << " : " << it->second << endl;
  }
  fStats.Dump(os, ind+2, "fStats: ");
  return;
}

} // end namespace Retro
