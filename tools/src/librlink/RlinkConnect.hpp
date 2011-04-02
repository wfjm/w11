// $Id: RlinkConnect.hpp 375 2011-04-02 07:56:47Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-04-02   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkConnect.hpp 375 2011-04-02 07:56:47Z mueller $
  \brief   Declaration of class \c RlinkConnect.
*/

#ifndef included_Retro_RlinkConnect
#define included_Retro_RlinkConnect 1

#include <cstdint>
#include <string>
#include <vector>
#include <ostream>

#include "librtools/RerrMsg.hpp"
#include "librtools/Rstats.hpp"
#include "librtools/RlogFile.hpp"

#include "RlinkPort.hpp"
#include "RlinkCommandList.hpp"
#include "RlinkPacketBuf.hpp"
#include "RlinkAddrMap.hpp"

namespace Retro {

  class RlinkConnect {
    public:
      struct LogOpts {
        size_t        baseaddr;
        size_t        basedata;
        size_t        basestat;
        size_t        printlevel;           // 0=off,1=err,2=chk,3=all
        size_t        dumplevel;            // 0=off,1=err,2=chk,3=all
        size_t        tracelevel;           // 0=off,1=buf,2=char

                      LogOpts()
                        : baseaddr(16), basedata(16), basestat(16),
                          printlevel(0), dumplevel(0), tracelevel(0)
                      {}
      };

                    RlinkConnect();
                    ~RlinkConnect();

      bool          Open(const std::string& name, RerrMsg& emsg);
      void          Close();
      bool          IsOpen() const;
      RlinkPort*    Port() const;

      bool          Exec(RlinkCommandList& clist, RerrMsg& emsg);
      bool          ExecPart(RlinkCommandList& clist, size_t ibeg, size_t iend, 
                             RerrMsg& emsg);

      double        WaitAttn(double timeout, RerrMsg& emsg);
      bool          SndOob(uint16_t addr, uint16_t data, RerrMsg& emsg);

      bool          AddrMapInsert(const std::string& name, uint16_t addr);
      bool          AddrMapErase(const std::string& name);
      bool          AddrMapErase(uint16_t addr);
      void          AddrMapClear();

      const RlinkAddrMap& AddrMap() const;
      const Rstats& Stats() const;

      bool          LogOpen(const std::string& name);
      void          LogUseStream(std::ostream* pstr);
      void          SetLogOpts(const LogOpts& opts);
      const LogOpts&  GetLogOpts() const;
      RlogFile&     LogFile() const;

      void          Print(std::ostream& os) const;
      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;


    // statistics counter indices
      enum stats {
        kStatNExec = 0,
        kStatNSplitVol,
        kStatNExecPart,
        kStatNCmd,
        kStatNRreg,
        kStatNRblk,
        kStatNWreg,
        kStatNWblk,
        kStatNStat,
        kStatNAttn,
        kStatNInit,
        kStatNRblkWord,
        kStatNWblkWord,
        kStatNTxPktByt,
        kStatNTxEsc,
        kStatNRxPktByt,
        kStatNRxEsc,
        kStatNRxAttn,
        kStatNRxIdle,
        kStatNRxDrop,
        kStatNExpData,
        kStatNExpStat,
        kStatNChkData,
        kStatNChkStat,
        kStatNSndOob,
        kDimStat
      };

    protected: 
      RlinkPort*    fpPort;                 //!< ptr to port
      uint8_t       fSeqNumber[8];          //!< command sequence number
      RlinkPacketBuf fTxPkt;                //!< transmit packet buffer
      RlinkPacketBuf fRxPkt;                //!< receive packet buffer
      RlinkAddrMap  fAddrMap;               //!< name<->address mapping
      Rstats        fStats;                 //!< statistics
      LogOpts       fLogOpts;               //!< log options
      RlogFile      fLogFile;               //!< connection log file

    // RlinkConnect is not copyable and assignable
    private:
                    RlinkConnect(const RlinkConnect& rhs);
      RlinkConnect& operator=(const RlinkConnect& rhs);
  };
  
} // end namespace Retro

#if !(defined(Retro_NoInline) || defined(Retro_RlinkConnect_NoInline))
#include "RlinkConnect.ipp"
#endif

#endif
