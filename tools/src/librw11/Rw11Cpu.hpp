// $Id: Rw11Cpu.hpp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-04-12   504   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11Cpu.hpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Declaration of class Rw11Cpu.
*/

#ifndef included_Retro_Rw11Cpu
#define included_Retro_Rw11Cpu 1

#include <string>
#include <vector>

#include "boost/utility.hpp"
#include "boost/shared_ptr.hpp"
#include "boost/thread/locks.hpp"
#include "boost/thread/condition_variable.hpp"

#include "librtools/Rstats.hpp"
#include "librtools/RerrMsg.hpp"
#include "librlink/RlinkConnect.hpp"

#include "Rw11Probe.hpp"

#include "librtools/Rbits.hpp"
#include "Rw11.hpp"

namespace Retro {

  class Rw11Cntl;                           // forw decl to avoid circular incl

  class Rw11Cpu : public Rbits, private boost::noncopyable {
    public:
      typedef std::map<std::string, boost::shared_ptr<Rw11Cntl>> cmap_t;
      typedef cmap_t::iterator         cmap_it_t;
      typedef cmap_t::const_iterator   cmap_cit_t;
      typedef cmap_t::value_type       cmap_val_t;

      explicit      Rw11Cpu(const std::string& type);
      virtual      ~Rw11Cpu();

      void          Setup(Rw11* pw11);
      Rw11&         W11() const;
      RlinkServer&  Server() const;
      RlinkConnect& Connect() const;
      RlogFile&     LogFile() const;

      const std::string&   Type() const;
      size_t        Index() const;
      uint16_t      Base() const;

      void          AddCntl(const boost::shared_ptr<Rw11Cntl>& spcntl);
      bool          TestCntl(const std::string& name) const;
      void          ListCntl(std::vector<std::string>& list) const;
      Rw11Cntl&     Cntl(const std::string& name) const;

      void          Start();

      std::string   NextCntlName(const std::string& base) const;

      int           AddIbrb(RlinkCommandList& clist, uint16_t ibaddr);
      int           AddRibr(RlinkCommandList& clist, uint16_t ibaddr);
      int           AddWibr(RlinkCommandList& clist, uint16_t ibaddr,
                            uint16_t data);

      bool          MemRead(uint16_t addr, std::vector<uint16_t>& data, 
                            size_t nword, RerrMsg& emsg);
      bool          MemWrite(uint16_t addr, const std::vector<uint16_t>& data,
                             RerrMsg& emsg);

      bool          ProbeCntl(Rw11Probe& dsc);

      bool          LoadAbs(const std::string& fname, RerrMsg& emsg,
                            bool trace=false);
      bool          Boot(const std::string& uname, RerrMsg& emsg);

      void          SetCpuGoUp();
      void          SetCpuGoDown(uint16_t stat);
      double        WaitCpuGoDown(double tout);
      bool          CpuGo() const;
      uint16_t      CpuStat() const;

      void          W11AttnHandler();

      const Rstats& Stats() const;
      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // some constants (also defined in cpp)
      static const uint16_t  kCp_addr_conf  = 0x0000; //!< 
      static const uint16_t  kCp_addr_cntl  = 0x0001; //!< 
      static const uint16_t  kCp_addr_stat  = 0x0002; //!< 
      static const uint16_t  kCp_addr_psw   = 0x0003; //!< 
      static const uint16_t  kCp_addr_al    = 0x0004; //!< 
      static const uint16_t  kCp_addr_ah    = 0x0005; //!< 
      static const uint16_t  kCp_addr_mem   = 0x0006; //!< 
      static const uint16_t  kCp_addr_memi  = 0x0007; //!< 
      static const uint16_t  kCp_addr_r0    = 0x0008; //!< 
      static const uint16_t  kCp_addr_pc    = 0x000f; //!< 
      static const uint16_t  kCp_addr_ibrb  = 0x0010; //!< 
      static const uint16_t  kCp_addr_ibr   = 0x0080; //!< 

      static const uint16_t  kCp_func_noop  = 0x0000; //!< 
      static const uint16_t  kCp_func_start = 0x0001; //!< 
      static const uint16_t  kCp_func_stop  = 0x0002; //!< 
      static const uint16_t  kCp_func_cont  = 0x0003; //!< 
      static const uint16_t  kCp_func_step  = 0x0004; //!< 
      static const uint16_t  kCp_func_reset = 0x000f; //!<

      static const uint16_t  kCp_stat_m_cpurust = 0x00f0;  //!<
      static const uint16_t  kCp_stat_v_cpurust = 4;       //!<
      static const uint16_t  kCp_stat_b_cpurust = 0x000f;  //!<
      static const uint16_t  kCp_stat_m_cpuhalt = kWBit03; //!<
      static const uint16_t  kCp_stat_m_cpugo   = kWBit02; //!<
      static const uint16_t  kCp_stat_m_cmdmerr = kWBit01; //!<
      static const uint16_t  kCp_stat_m_cmderr  = kWBit00; //!<

      static const uint16_t  kCp_cpurust_init   = 0x0;  //!< cpu in init state
      static const uint16_t  kCp_cpurust_halt   = 0x1;  //!< cpu executed HALT
      static const uint16_t  kCp_cpurust_reset  = 0x2;  //!< cpu was reset
      static const uint16_t  kCp_cpurust_stop   = 0x3;  //!< cpu was stopped
      static const uint16_t  kCp_cpurust_step   = 0x4;  //!< cpu was stepped
      static const uint16_t  kCp_cpurust_susp   = 0x5;  //!< cpu was suspended
      static const uint16_t  kCp_cpurust_runs   = 0x7;  //!< cpu running
      static const uint16_t  kCp_cpurust_vecfet = 0x8;  //!< vector fetch halt
      static const uint16_t  kCp_cpurust_recrsv = 0x9;  //!< rec red-stack halt
      static const uint16_t  kCp_cpurust_sfail  = 0xa;  //!< sequencer failure
      static const uint16_t  kCp_cpurust_vfail  = 0xb;  //!< vmbox failure

    private:
                    Rw11Cpu() {}            //!< default ctor blocker

    protected:
      Rw11*         fpW11;
      std::string   fType;
      size_t        fIndex;
      uint16_t      fBase;
      bool          fCpuGo;
      uint16_t      fCpuStat;
      boost::mutex               fCpuGoMutex;
      boost::condition_variable  fCpuGoCond;
      cmap_t        fCntlMap;               //!< name->cntl map
      Rstats        fStats;                 //!< statistics
  };
  
} // end namespace Retro

#include "Rw11Cpu.ipp"

#endif
