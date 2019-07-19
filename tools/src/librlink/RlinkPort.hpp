// $Id: RlinkPort.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.4.5  Stats() not longer const
// 2018-12-16  1084   1.4.4  use =delete for noncopyable instead of boost
// 2018-12-07  1078   1.4.3  use std::shared_ptr instead of boost
// 2018-12-01  1076   1.4 2  use unique_ptr
// 2017-04-07   868   1.4.1  Dump(): add detail arg
// 2017-02-19   853   1.4    use Rtime, drop TimeOfDayAsDouble
// 2015-04-11   666   1.3    add fXon, XonEnable()
// 2014-12-10   611   1.2.2  add time stamps for Read/Write for logs
// 2013-05-01   513   1.2.1  fTraceLevel now uint32_t
// 2013-02-23   492   1.2    use RparseUrl
// 2013-02-22   491   1.1    use new RlogFile/RlogMsg interfaces
// 2013-01-27   477   1.0.3  add RawRead(),RawWrite() methods
// 2012-12-26   465   1.0.2  add CloseFd() method
// 2011-04-24   380   1.0.1  use boost::noncopyable (instead of private dcl's)
// 2011-03-27   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RlinkPort.
*/

#ifndef included_Retro_RlinkPort
#define included_Retro_RlinkPort 1

#include <string>
#include <map>
#include <memory>

#include "librtools/RerrMsg.hpp"
#include "librtools/RlogFile.hpp"
#include "librtools/Rstats.hpp"
#include "librtools/RparseUrl.hpp"
#include "librtools/Rtime.hpp"

namespace Retro {

  class RlinkPort {
    public:
      typedef std::unique_ptr<RlinkPort>  port_uptr_t;
    
                    RlinkPort();
      virtual      ~RlinkPort();

                    RlinkPort(const RlinkPort&) = delete;  // noncopyable 
      RlinkPort&    operator=(const RlinkPort&) = delete;  // noncopyable

      virtual bool  Open(const std::string& url, RerrMsg& emsg) = 0;
      virtual void  Close();

      virtual int   Read(uint8_t* buf, size_t size, const Rtime& timeout, 
                         RerrMsg& emsg);
      virtual int   Write(const uint8_t* buf, size_t size, RerrMsg& emsg);
      virtual bool  PollRead(const Rtime& timeout);

      int           RawRead(uint8_t* buf, size_t size, bool exactsize,
                            const Rtime& timeout, Rtime& tused, RerrMsg& emsg);
      int           RawWrite(const uint8_t* buf, size_t size, RerrMsg& emsg);

      bool          IsOpen() const;

      const RparseUrl&  Url() const;
      bool          XonEnable() const;

      int           FdRead() const;
      int           FdWrite() const;

      void          SetLogFile(const std::shared_ptr<RlogFile>& splog);
      void          SetTraceLevel(uint32_t level);

      uint32_t      TraceLevel() const;

      Rstats&       Stats();

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // some constants (also defined in cpp)
      static const int  kEof  =  0;         //!< return code: end-of-file 
      static const int  kTout = -1;         //!< return code: time out
      static const int  kErr  = -2;         //!< return code: IO error

    // statistics counter indices
      enum stats {
        kStatNPortWrite = 0,
        kStatNPortRead,
        kStatNPortTxByt,
        kStatNPortRxByt,
        kStatNPortRawWrite,
        kStatNPortRawRead,
        kDimStat
      };    

    protected:
      void          CloseFd(int& fd);

    protected:
      bool          fIsOpen;                //!< is open flag
      RparseUrl     fUrl;                   //!< parsed url
      bool          fXon;                   //!< xon attribute set 
      int           fFdRead;                //!< fd for read
      int           fFdWrite;               //!< fd for write
      std::shared_ptr<RlogFile>  fspLog;    //!< log file ptr
      uint32_t      fTraceLevel;            //!< trace level
      Rtime         fTsLastRead;            //!< time stamp last write
      Rtime         fTsLastWrite;           //!< time stamp last write
      Rstats        fStats;                 //!< statistics
  };
  
} // end namespace Retro

#include "RlinkPort.ipp"

#endif
