// $Id: Rw11Cpu.hpp 1112 2019-02-17 11:10:04Z mueller $
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
// 2019-02-15  1112   1.2.16 add HasIbtst()
// 2018-12-23  1091   1.2.15 AddWbibr(): add move version
// 2018-12-17  1085   1.2.14 use std::mutex,condition_variable instead of boost
// 2018-12-16  1084   1.2.13 use =delete for noncopyable instead of boost
// 2018-12-07  1078   1.2.12 use std::shared_ptr instead of boost
// 2018-09-23  1050   1.2.11 add HasPcnt()
// 2017-04-07   868   1.2.10 Dump(): add detail arg
// 2017-02-26   857   1.2.9  add kCPAH_M_UBM22
// 2017-02-19   853   1.2.8  use Rtime
// 2017-02-17   851   1.2.7  probe/setup auxilliary devices: kw11l,kw11p,iist
// 2017-02-10   850   1.2.6  add ModLalh()
// 2015-12-28   721   1.2.5  BUGFIX: IM* correct register offset definitions
// 2015-07-12   700   1.2.4  use ..CpuAct instead ..CpuGo (new active based lam);
//                           add probe and map setup for optional cpu components
// 2015-05-08   675   1.2.3  w11a start/stop/suspend overhaul
// 2015-04-25   668   1.2.2  add AddRbibr(), AddWbibr()
// 2015-04-03   661   1.2.1  add kStat_M_* defs
// 2015-03-21   659   1.2    add RAddrMap(); add AllRAddrMapInsert();
// 2015-01-01   626   1.1    Adopt for rlink v4 and 4k ibus window; add IAddrMap
// 2013-04-14   506   1.0.1  add AddLalh(),AddRMem(),AddWMem()
// 2013-04-12   504   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rw11Cpu.
*/

#ifndef included_Retro_Rw11Cpu
#define included_Retro_Rw11Cpu 1

#include <string>
#include <vector>
#include <memory>
#include <map>
#include <mutex>
#include <condition_variable>

#include "librtools/Rstats.hpp"
#include "librtools/RerrMsg.hpp"
#include "librlink/RlinkConnect.hpp"
#include "librlink/RlinkAddrMap.hpp"

#include "Rw11Probe.hpp"

#include "librtools/Rbits.hpp"
#include "Rw11.hpp"

namespace Retro {

  class Rw11Cntl;                           // forw decl to avoid circular incl

  class Rw11Cpu : public Rbits {
    public:
      typedef std::map<std::string, std::shared_ptr<Rw11Cntl>> cmap_t;

      explicit      Rw11Cpu(const std::string& type);
      virtual      ~Rw11Cpu();
 
                    Rw11Cpu(const Rw11Cpu&) = delete;    // noncopyable 
      Rw11Cpu&      operator=(const Rw11Cpu&) = delete;  // noncopyable

      void          Setup(Rw11* pw11);
      Rw11&         W11() const;
      RlinkServer&  Server() const;
      RlinkConnect& Connect() const;
      RlogFile&     LogFile() const;

      const std::string&   Type() const;
      size_t        Index() const;
      uint16_t      Base() const;
      uint16_t      IBase() const;

      bool          HasScnt() const;
      bool          HasPcnt() const;
      bool          HasCmon() const;
      uint16_t      HasHbpt() const;
      bool          HasIbmon() const;
      bool          HasIbtst() const;
      bool          HasKw11l() const;
      bool          HasKw11p() const;
      bool          HasIist() const;

      void          AddCntl(const std::shared_ptr<Rw11Cntl>& spcntl);
      bool          TestCntl(const std::string& name) const;
      void          ListCntl(std::vector<std::string>& list) const;
      Rw11Cntl&     Cntl(const std::string& name) const;

      void          Start();

      std::string   NextCntlName(const std::string& base) const;

      int           AddMembe(RlinkCommandList& clist, uint16_t be, 
                             bool stick=false);
      int           AddRibr(RlinkCommandList& clist, uint16_t ibaddr);
      int           AddWibr(RlinkCommandList& clist, uint16_t ibaddr,
                            uint16_t data);

      int           AddRbibr(RlinkCommandList& clist, uint16_t ibaddr, 
                             size_t size);
      int           AddWbibr(RlinkCommandList& clist, uint16_t ibaddr, 
                             const std::vector<uint16_t>& block);
      int           AddWbibr(RlinkCommandList& clist, uint16_t ibaddr, 
                             std::vector<uint16_t>&& block);

      int           AddLalh(RlinkCommandList& clist, uint32_t addr, 
                            uint16_t mode=kCPAH_M_22BIT);
      void          ModLalh(RlinkCommandList& clist, size_t ind, uint32_t addr, 
                            uint16_t mode=kCPAH_M_22BIT);

      int           AddRMem(RlinkCommandList& clist, uint32_t addr,
                            uint16_t* buf, size_t size, 
                            uint16_t mode=kCPAH_M_22BIT, 
                            bool singleblk=false);
      int           AddWMem(RlinkCommandList& clist, uint32_t addr,
                            const uint16_t* buf, size_t size, 
                            uint16_t mode=kCPAH_M_22BIT,
                            bool singleblk=false);

      bool          MemRead(uint16_t addr, std::vector<uint16_t>& data, 
                            size_t nword, RerrMsg& emsg);
      bool          MemWrite(uint16_t addr, const std::vector<uint16_t>& data,
                             RerrMsg& emsg);

      bool          ProbeCntl(Rw11Probe& dsc);

      bool          LoadAbs(const std::string& fname, RerrMsg& emsg,
                            bool trace=false);
      bool          Boot(const std::string& uname, RerrMsg& emsg);

      void          SetCpuActUp();
      void          SetCpuActDown(uint16_t stat);
      int           WaitCpuActDown(const Rtime& tout, Rtime&twait);
      bool          CpuAct() const;
      uint16_t      CpuStat() const;

      uint16_t      IbusRemoteAddr(uint16_t ibaddr) const;
      void          AllIAddrMapInsert(const std::string& name, uint16_t ibaddr);
      void          AllRAddrMapInsert(const std::string& name, uint16_t rbaddr);

      bool          IAddrMapInsert(const std::string& name, uint16_t ibaddr);
      bool          IAddrMapErase(const std::string& name);
      bool          IAddrMapErase(uint16_t ibaddr);
      void          IAddrMapClear();
      const RlinkAddrMap& IAddrMap() const;

      bool          RAddrMapInsert(const std::string& name, uint16_t rbaddr);
      bool          RAddrMapErase(const std::string& name);
      bool          RAddrMapErase(uint16_t rbaddr);
      void          RAddrMapClear();
      const RlinkAddrMap& RAddrMap() const;

      void          W11AttnHandler();

      const Rstats& Stats() const;
      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // some constants (also defined in cpp)
      static const uint16_t  kCPCONF  = 0x0000; //!< CPCONF  reg offset
      static const uint16_t  kCPCNTL  = 0x0001; //!< CPADDR  reg offset
      static const uint16_t  kCPSTAT  = 0x0002; //!< CPSTAT  reg offset
      static const uint16_t  kCPPSW   = 0x0003; //!< CPPSW   reg offset
      static const uint16_t  kCPAL    = 0x0004; //!< CPAL    reg offset
      static const uint16_t  kCPAH    = 0x0005; //!< CPAH    reg offset
      static const uint16_t  kCPMEM   = 0x0006; //!< CPMEM   reg offset
      static const uint16_t  kCPMEMI  = 0x0007; //!< CPMEMI  reg offset
      static const uint16_t  kCPR0    = 0x0008; //!< CPR0    reg offset
      static const uint16_t  kCPPC    = 0x000f; //!< CPPC    reg offset
      static const uint16_t  kCPMEMBE = 0x0010; //!< CPMEMBE reg offset

      static const uint16_t  kCPFUNC_NOOP    = 0x0000; //!< 
      static const uint16_t  kCPFUNC_START   = 0x0001; //!< 
      static const uint16_t  kCPFUNC_STOP    = 0x0002; //!< 
      static const uint16_t  kCPFUNC_STEP    = 0x0003; //!< 
      static const uint16_t  kCPFUNC_CRESET  = 0x0004; //!< 
      static const uint16_t  kCPFUNC_BRESET  = 0x0005; //!<
      static const uint16_t  kCPFUNC_SUSPEND = 0x0006; //!<
      static const uint16_t  kCPFUNC_RESUME  = 0x0007; //!<

      static const uint16_t  kCPSTAT_M_SuspExt = kWBit09; //!<
      static const uint16_t  kCPSTAT_M_SuspInt = kWBit08; //!<
      static const uint16_t  kCPSTAT_M_CpuRust = 0x00f0;  //!<
      static const uint16_t  kCPSTAT_V_CpuRust = 4;       //!<
      static const uint16_t  kCPSTAT_B_CpuRust = 0x000f;  //!<
      static const uint16_t  kCPSTAT_M_CpuSusp = kWBit03; //!<
      static const uint16_t  kCPSTAT_M_CpuGo   = kWBit02; //!<
      static const uint16_t  kCPSTAT_M_CmdMErr = kWBit01; //!<
      static const uint16_t  kCPSTAT_M_CmdErr  = kWBit00; //!<

      static const uint16_t  kCPURUST_INIT   = 0x0;  //!< cpu in init state
      static const uint16_t  kCPURUST_HALT   = 0x1;  //!< cpu executed HALT
      static const uint16_t  kCPURUST_RESET  = 0x2;  //!< cpu was reset
      static const uint16_t  kCPURUST_STOP   = 0x3;  //!< cpu was stopped
      static const uint16_t  kCPURUST_STEP   = 0x4;  //!< cpu was stepped
      static const uint16_t  kCPURUST_SUSP   = 0x5;  //!< cpu was suspended
      static const uint16_t  kCPURUST_HBPT   = 0x6;  //!< cpu hardware bpt
      static const uint16_t  kCPURUST_RUNS   = 0x7;  //!< cpu running
      static const uint16_t  kCPURUST_VECFET = 0x8;  //!< vector fetch halt
      static const uint16_t  kCPURUST_RECRSV = 0x9;  //!< rec red-stack halt
      static const uint16_t  kCPURUST_SFAIL  = 0xa;  //!< sequencer failure
      static const uint16_t  kCPURUST_VFAIL  = 0xb;  //!< vmbox failure

      static const uint16_t  kCPAH_M_ADDR  = 0x003f;  //!< mask for 6bit msb
      static const uint16_t  kCPAH_M_22BIT = kWBit06; //!< ena 22bit addressing
      static const uint16_t  kCPAH_M_UBMAP = kWBit07; //!< ena ubmap
      static const uint16_t  kCPAH_M_UBM22 = kWBit06|kWBit07; //!< ubmap+22bit

      static const uint16_t  kCPMEMBE_M_STICK = kWBit02; //!< 
      static const uint16_t  kCPMEMBE_M_BE    = 0x0003;  //!< 

    // defs for the four status bits defined by w11 rbus iface
      static const uint8_t   kStat_M_CmdErr  = kBBit07; //!< stat: cmderr  flag
      static const uint8_t   kStat_M_CmdMErr = kBBit06; //!< stat: cmdmerr flag
      static const uint8_t   kStat_M_CpuSusp = kBBit05; //!< stat: cpususp flag
      static const uint8_t   kStat_M_CpuGo   = kBBit04; //!< stat: cpugo   flag

    // defs for optional w11 cpu components
      static const uint16_t  kSCBASE  = 0x0040;   //!< DMSCNT reg base offset
      static const uint16_t  kSCCNTL  = 0x0000;   //!< SC.CNTL  reg offset
      static const uint16_t  kSCADDR  = 0x0001;   //!< SC.ADDR  reg offset
      static const uint16_t  kSCDATA  = 0x0002;   //!< SC.DATA  reg offset

      static const uint16_t  kCMBASE  = 0x0048;   //!< DMCMON reg base offset
      static const uint16_t  kCMCNTL  = 0x0000;   //!< CM.CNTL  reg offset
      static const uint16_t  kCMSTAT  = 0x0001;   //!< CM.STAT  reg offset
      static const uint16_t  kCMADDR  = 0x0002;   //!< CM.ADDR  reg offset
      static const uint16_t  kCMDATA  = 0x0003;   //!< CM.DATA  reg offset
      static const uint16_t  kCMIADDR = 0x0004;   //!< CM.IADDR reg offset
      static const uint16_t  kCMIPC   = 0x0005;   //!< CM.IPC   reg offset
      static const uint16_t  kCMIREG  = 0x0006;   //!< CM.IREG  reg offset
      static const uint16_t  kCMIMAL  = 0x0007;   //!< CM.IMAL  reg offset

      static const uint16_t  kHBBASE  = 0x0050;   //!< DMHBPT reg base offset
      static const uint16_t  kHBSIZE  = 0x0004;   //!< DMHBPT unit size
      static const uint16_t  kHBNMAX  = 0x0004;   //!< DMHBPT max number units
      static const uint16_t  kHBCNTL  = 0x0000;   //!< HB.CNTL  reg offset
      static const uint16_t  kHBSTAT  = 0x0001;   //!< HB.STAT  reg offset
      static const uint16_t  kHBHILIM = 0x0002;   //!< HB.HILIM reg offset
      static const uint16_t  kHBLOLIM = 0x0003;   //!< HB.LOLIM reg offset

      static const uint16_t  kPCBASE  = 0x0060;   //!< DMPCNT reg base offset
      static const uint16_t  kPCCNTL  = 0x0000;   //!< PC.CNTL  reg offset
      static const uint16_t  kPCSTAT  = 0x0001;   //!< PC.STAT  reg offset
      static const uint16_t  kPCDATA  = 0x0002;   //!< PC.DATA  reg offset

      static const uint16_t  kIMBASE  = 0160000;  //!< Ibmon ibus address
      static const uint16_t  kIMCNTL  = 0x0000;   //!< IM.CNTL  reg offset
      static const uint16_t  kIMSTAT  = 0x0002;   //!< IM.STAT  reg offset
      static const uint16_t  kIMHILIM = 0x0004;   //!< IM.HILIM reg offset
      static const uint16_t  kIMLOLIM = 0x0006;   //!< IM.LOLIM reg offset
      static const uint16_t  kIMADDR  = 0x0008;   //!< IM.ADDR  reg offset
      static const uint16_t  kIMDATA  = 0x000a;   //!< IM.DATA  reg offset
    
      static const uint16_t  kITBASE  = 0170000;  //!< Ibtst ibus address
      static const uint16_t  kITCNTL  = 0x0000;   //!< IT.CNTL  reg offset
      static const uint16_t  kITSTAT  = 0x0002;   //!< IT.STAT  reg offset
      static const uint16_t  kITDATA  = 0x0004;   //!< IT.DATA  reg offset
      static const uint16_t  kITFIFO  = 0x0006;   //!< IT.FIFO  reg offset

    // defs for optional w11 aux components
      static const uint16_t  kKWLBASE = 0177546;  //!< KW11-L ibus address
      static const uint16_t  kKWPBASE = 0172540;  //!< KW11-P ibus address
      static const uint16_t  kKWPCSR  = 0x0000;   //!< KWP.CSR  reg offset
      static const uint16_t  kKWPCSB  = 0x0002;   //!< KWP.CSB  reg offset
      static const uint16_t  kKWPCTR  = 0x0004;   //!< KWP.CTR  reg offset
      static const uint16_t  kIISTBASE= 0177500;  //!< IIST   ibus address
      static const uint16_t  kIISTACR = 0x0000;   //!< II.ACR   reg offset
      static const uint16_t  kIISTADR = 0x0002;   //!< II.ADR   reg offset

    protected:
      void          SetupStd();
      void          SetupOpt();

    private:
                    Rw11Cpu() {}            //!< default ctor blocker

    protected:
      Rw11*         fpW11;
      std::string   fType;
      size_t        fIndex;
      uint16_t      fBase;
      uint16_t      fIBase;
      bool          fHasScnt;               //!< has dmscnt (state counter) 
      bool          fHasPcnt;               //!< has dmpcnt (perf counters) 
      bool          fHasCmon;               //!< has dmcmon (cpu monitor)
      uint16_t      fHasHbpt;               //!< has dmhbpt (hardware breakpoint)
      bool          fHasIbmon;              //!< has ibmon  (ibus monitor)
      bool          fHasIbtst;              //!< has ibtst  (ibus tester)
      bool          fHasKw11l;              //!< has kw11-l (line clock)
      bool          fHasKw11p;              //!< has kw11-p (prog clock)
      bool          fHasIist;               //!< has iist   (smp comm)
      bool          fCpuAct;
      uint16_t      fCpuStat;
      std::mutex               fCpuActMutex;
      std::condition_variable  fCpuActCond;
      cmap_t        fCntlMap;               //!< name->cntl map
      RlinkAddrMap  fIAddrMap;              //!< ibus name<->address mapping
      RlinkAddrMap  fRAddrMap;              //!< rbus name<->address mapping
      Rstats        fStats;                 //!< statistics
  };
  
} // end namespace Retro

#include "Rw11Cpu.ipp"

#endif
