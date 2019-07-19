// $Id: RtclRlinkServer.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.2.1  use std::shared_ptr instead of boost
// 2018-12-01  1076   1.2    use unique_ptr
// 2015-04-04   662   1.1    add M_get, M_set; remove 'server -trace'
// 2013-02-05   482   1.0.1  add shared_ptr to RlinkConnect object
// 2013-01-12   474   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of class RtclRlinkServer.
*/

#ifndef included_Retro_RtclRlinkServer
#define included_Retro_RtclRlinkServer 1

#include <cstddef>
#include <list>
#include <memory>

#include "librtcltools/RtclOPtr.hpp"
#include "librtcltools/RtclProxyOwned.hpp"
#include "librtcltools/RtclGetList.hpp"
#include "librtcltools/RtclSetList.hpp"
#include "RtclAttnShuttle.hpp"

#include "librlink/RlinkServer.hpp"

namespace Retro {

  class RlinkConnect;

  class RtclRlinkServer : public RtclProxyOwned<RlinkServer> {
    public:
                    RtclRlinkServer(Tcl_Interp* interp, const char* name);
                   ~RtclRlinkServer();

      virtual int   ClassCmdConfig(RtclArgs& args);

    protected:
      int           M_server(RtclArgs& args);
      int           M_attn(RtclArgs& args);
      int           M_stats(RtclArgs& args);
      int           M_print(RtclArgs& args);
      int           M_dump(RtclArgs& args);
      int           M_get(RtclArgs& args);
      int           M_set(RtclArgs& args);
      int           M_default(RtclArgs& args);

    protected:
      typedef std::unique_ptr<RtclAttnShuttle> ahdl_uptr_t;
      typedef std::list<ahdl_uptr_t> alist_t;

      std::shared_ptr<RlinkConnect> fspConn;
      alist_t       fAttnHdl; //!< list of attn handlers
      RtclGetList   fGets;
      RtclSetList   fSets;
  };
  
} // end namespace Retro

//#include "RtclRlinkServer.ipp"

#endif
