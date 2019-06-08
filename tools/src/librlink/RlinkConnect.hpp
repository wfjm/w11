// $Id: RlinkConnect.hpp 1160 2019-06-07 17:30:17Z mueller $
//
// Copyright 2011-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-06-07  1160   2.8.4  *Stats() not longer const
// 2018-12-23  1091   2.8.3  add BadPort()
// 2018-12-17  1085   2.8.2  use std::recursive_mutex instead of boost
// 2018-12-16  1084   2.8.1  use =delete for noncopyable instead of boost
// 2018-12-08  1079   2.8    add HasPort(); return ref for Port()
// 2018-12-07  1078   2.7.1  use std::shared_ptr instead of boost
// 2018-12-01  1076   2.7    use unique_ptr instead of scoped_ptr
// 2017-04-22   883   2.6.3  add rbus monitor probe, add HasRbmon()
// 2017-04-09   871   2.6.2  LogFileName(): returns now const std::string&
// 2017-04-07   868   2.6.1  Dump(): add detail arg
// 2017-02-20   854   2.6    use Rtime, drop TimeOfDayAsDouble
// 2016-04-02   758   2.5    add USR_ACCESS register support (RLUA0/RLUA1)
// 2016-03-20   748   2.4    add fTimeout,(Set)Timeout();
// 2015-04-12   666   2.3    add LinkInit,LinkInitDone; transfer xon
// 2015-04-02   661   2.2    expect logic: stat expect in Command, invert mask
// 2015-01-06   631   2.1    full rlink v4 implementation
// 2014-12-25   621   2.0.2  Reorganize packet send/revd stats
// 2014-12-20   616   2.0.1  add BlockDone expect checks
// 2014-12-10   611   2.0    re-organize for rlink v4
// 2013-04-21   509   1.3.3  add SndAttn() method
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
  \brief   Declaration of class \c RlinkConnect.
*/

#ifndef included_Retro_RlinkConnect
#define included_Retro_RlinkConnect 1

#include <cstdint>
#include <string>
#include <vector>
#include <memory>
#include <ostream>
#include <mutex>

#include "librtools/RerrMsg.hpp"
#include "librtools/Rtime.hpp"
#include "librtools/Rstats.hpp"
#include "librtools/RlogFile.hpp"
#include "librtools/Rexception.hpp"

#include "RlinkPort.hpp"
#include "RlinkCommandList.hpp"
#include "RlinkPacketBufSnd.hpp"
#include "RlinkPacketBufRcv.hpp"
#include "RlinkAddrMap.hpp"
#include "RlinkContext.hpp"

#include "librtools/Rbits.hpp"

namespace Retro {

  class RlinkServer;                        // forw decl to avoid circular incl

  class RlinkConnect : public Rbits {
    public:

                    RlinkConnect();
                   ~RlinkConnect();

                    RlinkConnect(const RlinkConnect&) = delete;  // noncopyable 
      RlinkConnect& operator=(const RlinkConnect&) = delete;     // noncopyable

      bool          Open(const std::string& name, RerrMsg& emsg);
      void          Close();
      bool          IsOpen() const;
      bool          HasPort() const;
      RlinkPort&        Port();
      const RlinkPort&  Port() const;

      bool          LinkInit(RerrMsg& emsg);
      bool          LinkInitDone() const;
    
      RlinkContext& Context();  

      void          SetServer(RlinkServer* pserv);
      RlinkServer*  Server() const;
      bool          ServerActive() const;
      bool          ServerActiveInside() const;
      bool          ServerActiveOutside() const;

      // provide Lockable interface
      void          lock();
      bool          try_lock();
      void          unlock();

      bool          Exec(RlinkCommandList& clist, RerrMsg& emsg);
      bool          Exec(RlinkCommandList& clist, RlinkContext& cntx,
                         RerrMsg& emsg);
      void          Exec(RlinkCommandList& clist);
      void          Exec(RlinkCommandList& clist, RlinkContext& cntx);

      int           WaitAttn(const Rtime& timeout, Rtime& twait, uint16_t& apat, 
                             RerrMsg& emsg);
      bool          SndOob(uint16_t addr, uint16_t data, RerrMsg& emsg);
      bool          SndAttn(RerrMsg& emsg);

      uint32_t      SysId() const;
      uint32_t      UsrAcc() const;
      size_t        RbufSize() const;
      size_t        BlockSizeMax() const;
      size_t        BlockSizePrudent() const;
      bool          HasRbmon() const;

      bool          AddrMapInsert(const std::string& name, uint16_t addr);
      bool          AddrMapErase(const std::string& name);
      bool          AddrMapErase(uint16_t addr);
      void          AddrMapClear();
      const RlinkAddrMap& AddrMap() const;

      Rstats&       Stats();
      Rstats&       SndStats();
      Rstats&       RcvStats();

      void          SetLogBaseAddr(uint32_t base);
      void          SetLogBaseData(uint32_t base);
      void          SetLogBaseStat(uint32_t base);
      void          SetPrintLevel(uint32_t lvl);
      void          SetDumpLevel(uint32_t lvl);
      void          SetTraceLevel(uint32_t lvl);
      void          SetTimeout(const Rtime& timeout);

      uint32_t      LogBaseAddr() const;
      uint32_t      LogBaseData() const;
      uint32_t      LogBaseStat() const;
      uint32_t      PrintLevel() const;
      uint32_t      DumpLevel() const;
      uint32_t      TraceLevel() const;
      const Rtime&  Timeout() const;

      bool          LogOpen(const std::string& name, RerrMsg& emsg);
      void          LogUseStream(std::ostream* pstr, 
                                 const std::string& name = "");
      RlogFile&     LogFile() const;
      const std::shared_ptr<RlogFile>&   LogFileSPtr() const;

      void          SetLogFileName(const std::string& name);
      const std::string&   LogFileName() const;

      void          Print(std::ostream& os) const;
      void          Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

      void          HandleUnsolicitedData();

    // some constants (also defined in cpp)
      static const uint16_t kRbaddr_RLCNTL = 0xffff; //!< rlink core reg RLCNTL
      static const uint16_t kRbaddr_RLSTAT = 0xfffe; //!< rlink core reg RLSTAT
      static const uint16_t kRbaddr_RLID1  = 0xfffd; //!< rlink core reg RLID1
      static const uint16_t kRbaddr_RLID0  = 0xfffc; //!< rlink core reg RLID0
      static const uint16_t kRbaddr_RLUA1  = 0xfffb; //!< rlink opt. reg RLUA1
      static const uint16_t kRbaddr_RLUA0  = 0xfffa; //!< rlink opt. reg RLUA0
      static const uint16_t kRbaddr_RMBASE = 0xffe8; //!< rlink opt. rbd_rbmon

      static const uint16_t kRLCNTL_M_AnEna = kWBit15;//!< RLCNTL: an  enable
      static const uint16_t kRLCNTL_M_AtoEna= kWBit14;//!< RLCNTL: ato enable
      static const uint16_t kRLCNTL_M_AtoVal= 0x00ff; //!< RLCNTL: ato value

      static const uint16_t kRLSTAT_V_LCmd  =  8;     //!< RLSTAT: lcmd
      static const uint16_t kRLSTAT_B_LCmd  = 0x00ff; //!< RLSTAT: lcmd
      static const uint16_t kRLSTAT_M_BAbo  = kWBit07;//!< RLSTAT: babo
      static const uint16_t kRLSTAT_M_RBSize= 0x0007; //!< RLSTAT: rbuf size

      static const uint16_t kSBCNTL_V_RLMON = 15; //!< SBCNTL: rlmon enable bit
      static const uint16_t kSBCNTL_V_RLBMON= 14; //!< SBCNTL: rlbmon enable bit
      static const uint16_t kSBCNTL_V_RBMON = 13; //!< SBCNTL: rbmon enable bit

      // space beyond data for rblk =  8 :cmd(1) cnt(2) dcnt(2) stat(1) crc(2)
      //                   and wblk =  3 :cmd(1) cnt(2)
      static const uint16_t kRbufBlkDelta=16; //!< rbuf needed for rblk or wblk
      // 512 byte are enough space for a prudent amount of non-blk commands
      static const uint16_t kRbufPrudentDelta=512; //!< Rbuf space reserve

    // statistics counter indices
      enum stats {
        kStatNExec = 0,                     //!< Exec() calls
        kStatNExecPart,                     //!< ExecPart() calls
        kStatNCmd,                          //!< commands executed
        kStatNRreg,                         //!< rreg commands
        kStatNRblk,                         //!< rblk commands
        kStatNWreg,                         //!< wreg commands
        kStatNWblk,                         //!< wblk commands
        kStatNLabo,                         //!< labo commands
        kStatNAttn,                         //!< attn commands
        kStatNInit,                         //!< init commands
        kStatNRblkWord,                     //!< words rcvd with rblk
        kStatNWblkWord,                     //!< words send with wblk
        kStatNExpData,                      //!< expect for data defined
        kStatNExpDone,                      //!< expect for done defined
        kStatNExpStat,                      //!< expect for stat explicit
        kStatNNoExpStat,                    //!< no expect for stat
        kStatNChkData,                      //!< expect data failed
        kStatNChkDone,                      //!< expect done failed
        kStatNChkStat,                      //!< expect stat failed
        kStatNSndOob,                       //!< SndOob() calls
        kStatNErrMiss,                      //!< decode: missing data
        kStatNErrCmd,                       //!< decode: command mismatch
        kStatNErrLen,                       //!< decode: length mismatch
        kStatNErrCrc,                       //!< decode: crc mismatch
        kDimStat
      };

    protected: 
      bool          ExecPart(RlinkCommandList& clist, size_t ibeg, size_t iend, 
                             RerrMsg& emsg);

      void          EncodeRequest(RlinkCommandList& clist, size_t ibeg, 
                                  size_t iend);
      int           DecodeResponse(RlinkCommandList& clist, size_t ibeg,
                                   size_t iend);
      bool          DecodeAttnNotify(uint16_t& apat);
      bool          ReadResponse(const Rtime& timeout, RerrMsg& emsg);
      void          AcceptResponse();
      void          ProcessUnsolicitedData();
      void          ProcessAttnNotify();
      [[noreturn]] void BadPort(const char* meth);

    protected: 
      RlinkPort::port_uptr_t fupPort;       //!< uptr to port
      bool          fLinkInitDeferred;      //!< noinit attr seen on Open
      bool          fLinkInitDone;          //!< LinkInit done
      RlinkServer*  fpServ;                 //!< ptr to server (optional)
      uint8_t       fSeqNumber[8];          //!< command sequence number
      RlinkPacketBufSnd fSndPkt;            //!< send    packet buffer
      RlinkPacketBufRcv fRcvPkt;            //!< receive packet buffer
      RlinkContext  fContext;               //!< default context
      RlinkAddrMap  fAddrMap;               //!< name<->address mapping
      Rstats        fStats;                 //!< statistics
      uint32_t      fLogBaseAddr;           //!< log: base for addr
      uint32_t      fLogBaseData;           //!< log: base for data
      uint32_t      fLogBaseStat;           //!< log: base for stat
      uint32_t      fPrintLevel;            //!< print 0=off,1=err,2=chk,3=all
      uint32_t      fDumpLevel;             //!< dump  0=off,1=err,2=chk,3=all
      uint32_t      fTraceLevel;            //!< trace 0=off,1=buf,2=char
      Rtime         fTimeout;               //!< response timeout
      std::shared_ptr<RlogFile> fspLog;     //!< log file ptr
      std::recursive_mutex fConnectMutex;   //!< mutex to lock whole connect
      uint16_t      fAttnNotiPatt;          //!< attn notifier pattern
      Rtime         fTsLastAttnNoti;        //!< time stamp last attn notify
      uint32_t      fSysId;                 //!< SYSID of connected device
      uint32_t      fUsrAcc;                //!< USR_ACCESS of connected device
      size_t        fRbufSize;              //!< Rbuf size (in bytes)
      bool          fHasRbmon;              //!< has rbd_rbmon (rbus monitor)
  };
  
} // end namespace Retro

#include "RlinkConnect.ipp"

#endif
