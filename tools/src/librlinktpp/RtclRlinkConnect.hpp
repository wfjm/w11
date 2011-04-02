// $Id: RtclRlinkConnect.hpp 375 2011-04-02 07:56:47Z mueller $
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
// 2011-03-27   374   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRlinkConnect.hpp 375 2011-04-02 07:56:47Z mueller $
  \brief   Declaration of class RtclRlinkConnect.
*/

#ifndef included_Retro_RtclRlinkConnect
#define included_Retro_RtclRlinkConnect 1

#include <cstddef>
#include <string>

#include "librtcltools/RtclOPtr.hpp"
#include "librtcltools/RtclProxyOwned.hpp"

#include "librlink/RlinkConnect.hpp"

namespace Retro {

  class RtclRlinkConnect : public RtclProxyOwned<RlinkConnect> {
    public:
                    RtclRlinkConnect(Tcl_Interp* interp, const char* name);
                    ~RtclRlinkConnect();

    protected:
      int           M_open(RtclArgs& args);
      int           M_close(RtclArgs& args);
      int           M_exec(RtclArgs& args);
      int           M_amap(RtclArgs& args);
      int           M_errcnt(RtclArgs& args);
      int           M_wtlam(RtclArgs& args);
      int           M_oob(RtclArgs& args);
      int           M_stats(RtclArgs& args);
      int           M_log(RtclArgs& args);
      int           M_print(RtclArgs& args);
      int           M_dump(RtclArgs& args);
      int           M_config(RtclArgs& args);
      int           M_default(RtclArgs& args);

      bool          GetAddr(RtclArgs& args, RlinkConnect& conn, uint16_t& addr);
      bool          GetVarName(RtclArgs& args, const char* argname, 
                               size_t nind, std::vector<std::string>& varname);
      bool          ConfigBase(RtclArgs& args, size_t& base);
      bool          ClistNonEmpty(RtclArgs& args, 
                                  const RlinkCommandList& clist);

    protected:
      RtclOPtr      fCmdnameObj[8];
      size_t        fErrCnt;
      std::string   fLogFileName;
  };
  
} // end namespace Retro

#if !(defined(Retro_NoInline) || defined(Retro_RtclRlinkConnect_NoInline))
//#include "RtclRlinkConnect.ipp"
#endif

#endif
