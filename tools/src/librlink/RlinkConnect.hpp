// $Id: RlinkConnect.hpp 495 2013-03-06 17:13:48Z mueller $
//
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-03-05   495   1.3.2  add Exec() without emsg (will send emsg to LogFile)
// 2013-03-01   493   1.3.1  add Server(Active..|SignalAttn)() methods
// 2013-02-23   492   1.3    use scoped_ptr for Port; Close allways allowed
//                           use RlinkContext, add Context(), Exec(..., cntx)
// 2013-02-22   491   1.2    use new RlogFile/RlogMsg interfaces
// 2013-02-03   481   1.1.3  add SetServer(),Server()
// 2013-01-13   474   1.1.2  add PollAttn() method
// 2011-11-28   434   1.1.1  struct LogOpts: use uint32_t for lp64 compatibility
// 2011-04-24   380   1.1    use boost::noncopyable (instead of private dcl's);
//                           use boost::(mutex&lock), implement Lockable IF
// 2011-04-22   379   1.0.1  add Lock(), Unlock()
// 2011-04-02   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkConnect.hpp 495 2013-03-06 17:13:48Z mueller $
  \brief   Declaration of class \c RlinkConnect.
*/

#ifndef included_Retro_RlinkConnect
#define included_Retro_RlinkConnect 1

#include <cstdint>
#include <string>
#include <vector>
#include <ostream>

#include "boost/utility.hpp"
#include "boost/thread/recursive_mutex.hpp"
#include "boost/shared_ptr.hpp"
#include "boost/scoped_ptr.hpp"

#include "librtools/RerrMsg.hpp"
#include "librtools/Rstats.hpp"
#include "librtools/RlogFile.hpp"

#include "RlinkPort.hpp"
#include "RlinkCommandList.hpp"
#include "RlinkPacketBuf.hpp"
#include "RlinkAddrMap.hpp"
#include "RlinkContext.hpp"

namespace Retro {

  class RlinkServer;                        // forw decl to avoid circular incl

  class RlinkConnect : private boost::noncopyable {
    public:
      struct LogOpts {
        uint32_t      baseaddr;
        uint32_t      basedata;
        uint32_t      basestat;
        uint32_t      printlevel;           // 0=off,1=err,2=chk,3=all
        uint32_t      dumplevel;            // 0=off,1=err,2=chk,3=all
        uint32_t      tracelevel;           // 0=off,1=buf,2=char

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

      RlinkContext& Context();  

      void          SetServer(RlinkServer* pserv);
      RlinkServer*  Server() const;
      bool          ServerActive() const;
      bool          ServerActiveInside() const;
      bool          ServerActiveOutside() const;
      void          ServerSignalAttn();

      // provide boost Lockable interface
      void          lock();
      bool          try_lock();
      void          unlock();

      bool          Exec(RlinkCommandList& clist, RerrMsg& emsg);
      bool          Exec(RlinkCommandList& clist, RlinkContext& cntx,
                         RerrMsg& emsg);
      bool          Exec(RlinkCommandList& clist);
      bool          Exec(RlinkCommandList& clist, RlinkContext& cntx);

      double        WaitAttn(double timeout, RerrMsg& emsg);
      int           PollAttn(RerrMsg& emsg);
      bool          SndOob(uint16_t addr, uint16_t data, RerrMsg& emsg);

      bool          AddrMapInsert(const std::string& name, uint16_t addr);
      bool          AddrMapErase(const std::string& name);
      bool          AddrMapErase(uint16_t addr);
      void          AddrMapClear();

      const RlinkAddrMap& AddrMap() const;
      const Rstats& Stats() const;

      void          SetLogOpts(const LogOpts& opts);
      const LogOpts&  GetLogOpts() const;

      bool          LogOpen(const std::string& name);
      void          LogUseStream(std::ostream* pstr, 
                                 const std::string& name = "");
      RlogFile&     LogFile() const;
      const boost::shared_ptr<RlogFile>&   LogFileSPtr() const;

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
      bool          ExecPart(RlinkCommandList& clist, size_t ibeg, size_t iend, 
                             RerrMsg& emsg, RlinkContext& cntx);

    protected: 
      boost::scoped_ptr<RlinkPort> fpPort;  //!< ptr to port
      RlinkServer*  fpServ;                 //!< ptr to server (optional)
      uint8_t       fSeqNumber[8];          //!< command sequence number
      RlinkPacketBuf fTxPkt;                //!< transmit packet buffer
      RlinkPacketBuf fRxPkt;                //!< receive packet buffer
      RlinkContext  fContext;               //!< default context
      RlinkAddrMap  fAddrMap;               //!< name<->address mapping
      Rstats        fStats;                 //!< statistics
      LogOpts       fLogOpts;               //!< log options
      boost::shared_ptr<RlogFile> fspLog;   //!< log file ptr
      boost::recursive_mutex fConnectMutex; //!< mutex to lock whole connect
  };
  
} // end namespace Retro

#include "RlinkConnect.ipp"

#endif
