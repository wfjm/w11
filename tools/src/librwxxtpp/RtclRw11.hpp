// $Id: RtclRw11.hpp 1081 2018-12-14 22:29:42Z mueller $
//
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-07  1078   1.1    use std::shared_ptr instead of boost
// 2017-04-16   876   1.0.3  add CpuCommands()
// 2017-04-02   866   1.0.2  add M_set
// 2015-03-28   660   1.0.1  add M_get
// 2013-03-06   495   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Declaration of class RtclRw11.
*/

#ifndef included_Retro_RtclRw11
#define included_Retro_RtclRw11 1

#include <cstddef>
#include <string>
#include <memory>

#include "librtcltools/RtclProxyOwned.hpp"
#include "librtcltools/RtclGetList.hpp"
#include "librtcltools/RtclSetList.hpp"

#include "librlink/RlinkServer.hpp"
#include "librw11/Rw11.hpp"

namespace Retro {
  
  class RtclRw11 : public RtclProxyOwned<Rw11> {
    public:
                    RtclRw11(Tcl_Interp* interp, const char* name);
                   ~RtclRw11();

      virtual int   ClassCmdConfig(RtclArgs& args);

    protected:
      int           M_get(RtclArgs& args);
      int           M_set(RtclArgs& args);
      int           M_start(RtclArgs& args);
      int           M_dump(RtclArgs& args);
      int           M_default(RtclArgs& args);

      Tcl_Obj*      CpuCommands();

    protected:
      std::shared_ptr<RlinkServer> fspServ;
      RtclGetList   fGets;
      RtclSetList   fSets;
  };
  
} // end namespace Retro

//#include "RtclRw11.ipp"

#endif
