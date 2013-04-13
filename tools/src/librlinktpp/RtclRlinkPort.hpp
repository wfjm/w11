// $Id: RtclRlinkPort.hpp 492 2013-02-24 22:14:47Z mueller $
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
// 2013-02-23   492   1.0.1  use RlogFile.Name();
// 2013-01-27   478   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRlinkPort.hpp 492 2013-02-24 22:14:47Z mueller $
  \brief   Declaration of class RtclRlinkPort.
*/

#ifndef included_Retro_RtclRlinkPort
#define included_Retro_RtclRlinkPort 1

#include <cstddef>
#include <string>

#include "boost/shared_ptr.hpp"

#include "librtcltools/RtclProxyBase.hpp"

#include "librtools/RlogFile.hpp"
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
      int           M_rawio(RtclArgs& args);
      int           M_stats(RtclArgs& args);
      int           M_log(RtclArgs& args);
      int           M_dump(RtclArgs& args);
      int           M_config(RtclArgs& args);
      int           M_default(RtclArgs& args);

      bool          TestOpen(RtclArgs& args);

      static int    DoRawio(RtclArgs& args, RlinkPort* pport, size_t& errcnt);

    protected:
      RlinkPort*    fpObj;                  //!< ptr to managed object
      boost::shared_ptr<RlogFile> fspLog;   //!< port log file
      uint32_t      fTraceLevel;            //!< 0=off,1=buf,2=char
      size_t        fErrCnt;                //!< error count
  };
  
} // end namespace Retro

//#include "RtclRlinkPort.ipp"

#endif
