// $Id: RtclRlinkPort.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-08  1079   1.3    use ref not ptr for RlinkPort
// 2018-12-07  1078   1.2.1  use std::shared_ptr instead of boost
// 2018-12-01  1076   1.2    use unique_ptr
// 2017-04-29   888   1.1    LogFileName(): returns now const std::string&
//                           drop M_rawio; add M_rawread,M_rawrblk,M_rawwblk
// 2015-01-09   632   1.0.2  add M_get, M_set, remove M_config
// 2013-02-23   492   1.0.1  use RlogFile.Name();
// 2013-01-27   478   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of class RtclRlinkPort.
*/

#ifndef included_Retro_RtclRlinkPort
#define included_Retro_RtclRlinkPort 1

#include <cstddef>
#include <string>
#include <memory>

#include "librtools/RlogFile.hpp"
#include "librtcltools/RtclProxyBase.hpp"
#include "librtcltools/RtclGetList.hpp"
#include "librtcltools/RtclSetList.hpp"

#include "librlink/RlinkPort.hpp"

namespace Retro {

  class RtclRlinkPort : public RtclProxyBase {
    public:
                    RtclRlinkPort(Tcl_Interp* interp, const char* name);
                   ~RtclRlinkPort();

      friend class RtclRlinkConnect;

    protected:
      int           M_open(RtclArgs& args);
      int           M_close(RtclArgs& args);
      int           M_errcnt(RtclArgs& args);
      int           M_rawread(RtclArgs& args);
      int           M_rawrblk(RtclArgs& args);
      int           M_rawwblk(RtclArgs& args);
      int           M_stats(RtclArgs& args);
      int           M_log(RtclArgs& args);
      int           M_dump(RtclArgs& args);
      int           M_get(RtclArgs& args);
      int           M_set(RtclArgs& args);
      int           M_default(RtclArgs& args);

      void          SetupGetSet();
      bool          TestPort(RtclArgs& args, bool testopen=true);
      void          SetLogFileName(const std::string& name);
      const std::string&  LogFileName() const;

      static int    DoRawRead(RtclArgs& args, RlinkPort& port);
      static int    DoRawRblk(RtclArgs& args, RlinkPort& port, size_t& errcnt);
      static int    DoRawWblk(RtclArgs& args, RlinkPort& port);

    protected:
      RlinkPort::port_uptr_t fupObj;        //!< uptr to managed port
      std::shared_ptr<RlogFile> fspLog;     //!< port log file
      uint32_t      fTraceLevel;            //!< 0=off,1=buf,2=char
      size_t        fErrCnt;                //!< error count
      RtclGetList   fGets;
      RtclSetList   fSets;
  };
  
} // end namespace Retro

//#include "RtclRlinkPort.ipp"

#endif
