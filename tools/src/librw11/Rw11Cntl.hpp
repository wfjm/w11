// $Id: Rw11Cntl.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.2.6  Stats() not longer const
// 2019-05-04  1146   1.2.5  UnitSetupAll(): now virtual
// 2019-04-14  1131   1.2.4  add UnitSetup(), UnitSetupAll()
// 2018-12-16  1084   1.2.3  use =delete for noncopyable instead of boost
// 2017-04-15   874   1.2.2  NUnit() now pure; add UnitBase()
// 2017-04-02   865   1.2.1  Dump(): add detail arg
// 2017-02-04   848   1.2    add ProbeFound(),ProbeDataInt,Rem()
// 2015-05-15   680   1.1.1  add NUnit() as virtual
// 2014-12-30   625   1.1    adopt to Rlink V4 attn logic
// 2013-03-06   495   1.0    Initial version
// 2013-02-05   483   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11Cntl.
*/

#ifndef included_Retro_Rw11Cntl
#define included_Retro_Rw11Cntl 1

#include <string>

#include "librtools/Rstats.hpp"
#include "librlink/RlinkConnect.hpp"
#include "librlink/RlinkServer.hpp"
#include "Rw11Probe.hpp"

#include "librtools/Rbits.hpp"
#include "Rw11Cpu.hpp"

namespace Retro {

  class Rw11Unit;                           // forw decl to avoid circular incl

  class Rw11Cntl : public Rbits {
    public:

      explicit      Rw11Cntl(const std::string& type);
      virtual      ~Rw11Cntl();

                    Rw11Cntl(const Rw11Cntl&) = delete;   // noncopyable 
      Rw11Cntl&     operator=(const Rw11Cntl&) = delete;  // noncopyable
    
      void          SetCpu(Rw11Cpu* pcpu);
      Rw11Cpu&      Cpu() const;
      Rw11&         W11() const;
      RlinkServer&  Server() const;
      RlinkConnect& Connect() const;
      RlogFile&     LogFile() const;

      const std::string&   Type() const;
      const std::string&   Name() const;
      uint16_t      Base() const;
      int           Lam() const;

      void          SetEnable(bool ena);
      bool          Enable() const;

      virtual bool  Probe();
      bool          ProbeFound() const;
      uint16_t      ProbeDataInt() const;
      uint16_t      ProbeDataRem() const;
      const Rw11Probe& ProbeStatus() const;

      virtual void  Start();
      bool          IsStarted() const;

      virtual size_t NUnit() const = 0;
      virtual Rw11Unit& UnitBase(size_t index) const = 0;
      virtual bool  BootCode(size_t unit, std::vector<uint16_t>& code, 
                             uint16_t& aload, uint16_t& astart);
      virtual void  UnitSetup(size_t ind);
      virtual void  UnitSetupAll();

      void          SetTraceLevel(uint32_t level);
      uint32_t      TraceLevel() const;

      std::string   UnitName(size_t index) const;

      Rstats&       Stats();
      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // statistics counter indices
      enum stats {
        kStatNAttnHdl = 0,
        kStatNAttnNoAct,
        kDimStat
      };    

    protected:
      void          ConfigCntl(const std::string& name, uint16_t base, int lam,
                               uint16_t probeoff, bool probeint, bool proberem);

    private:
                    Rw11Cntl() {}           //!< default ctor blocker

    protected:
      Rw11Cpu*      fpCpu;                  //!< cpu back pointer
      std::string   fType;                  //!< controller type
      std::string   fName;                  //!< controller name
      uint16_t      fBase;                  //!< controller base address
      int           fLam;                   //!< attn bit number (-1 of none)
      bool          fEnable;                //!< enable flag
      bool          fStarted;               //!< true if Start() called
      Rw11Probe     fProbe;                 //!< controller probe context
      uint32_t      fTraceLevel;            //!< trace level; 0=off;1=cntl
      RlinkCommandList fPrimClist;          //!< clist for attn primary info 
      Rstats        fStats;                 //!< statistics
  };
  
} // end namespace Retro

#include "Rw11Cntl.ipp"

#endif
