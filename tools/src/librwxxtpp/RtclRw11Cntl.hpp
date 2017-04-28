// $Id: RtclRw11Cntl.hpp 887 2017-04-28 19:32:52Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-16   878   1.1.2  add UnitCommands(); add Class(); M_default virtual
// 2015-03-27   660   1.1.1  add M_start
// 2015-01-03   627   1.1    M_stats now virtual
// 2013-03-06   495   1.0    Initial version
// 2013-02-08   484   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class RtclRw11Cntl.
*/

#ifndef included_Retro_RtclRw11Cntl
#define included_Retro_RtclRw11Cntl 1

#include <cstddef>
#include <string>

#include "librtcltools/RtclProxyBase.hpp"
#include "librtcltools/RtclGetList.hpp"
#include "librtcltools/RtclSetList.hpp"

#include "librw11/Rw11Cntl.hpp"
#include "RtclRw11Cpu.hpp"

namespace Retro {

  class RtclRw11Cntl : public RtclProxyBase {
    public:

                    RtclRw11Cntl(const std::string& type,
                                 const std::string& cclass);
      virtual      ~RtclRw11Cntl();

      virtual Rw11Cntl&  Obj() = 0;
      virtual int   FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu) = 0;

    protected:
      int           M_get(RtclArgs& args);
      int           M_set(RtclArgs& args);
      int           M_probe(RtclArgs& args);
      int           M_start(RtclArgs& args);
      virtual int   M_stats(RtclArgs& args);
      int           M_dump(RtclArgs& args);
      virtual int   M_default(RtclArgs& args);

      Tcl_Obj*      UnitCommands();
      const std::string&  Class() const;

    protected:
      std::string   fClass;
      RtclGetList   fGets;
      RtclSetList   fSets;
  };
  
} // end namespace Retro

//#include "RtclRw11Cntl.ipp"

#endif
