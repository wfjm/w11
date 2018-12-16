// $Id: RtclCmdBase.hpp 1083 2018-12-15 19:19:16Z mueller $
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
// 2018-12-15  1083   1.1.3  AddMeth(): use rval ref and move semantics
// 2018-12-14  1081   1.1.2  use std::function instead of boost
// 2017-04-02   865   1.1.1  add GetArgsDump()
// 2017-04-02   863   1.1    add DelMeth(),TstMeth(); add M_info() and '?'
//                           rename fMapMeth -> fMethMap
// 2013-04-26   511   1.0.1  AddMeth() now public
// 2013-02-02   480   1.0    Initial version (refactored out from ProxyBase)
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Declaration of class RtclCmdBase.
*/

#ifndef included_Retro_RtclCmdBase
#define included_Retro_RtclCmdBase 1

#include "tcl.h"

#include <string>
#include <map>
#include <functional>

#include "boost/utility.hpp"

#include "RtclArgs.hpp"

namespace Retro {

  class RtclCmdBase : private boost::noncopyable {
    public:
      typedef std::function<int(RtclArgs&)> methfo_t;

      typedef std::map<std::string, methfo_t> mmap_t;
      typedef mmap_t::iterator         mmap_it_t;
      typedef mmap_t::const_iterator   mmap_cit_t;

                    RtclCmdBase();
      virtual      ~RtclCmdBase();

      int           DispatchCmd(RtclArgs& args);
      void          AddMeth(const std::string& name, methfo_t&& methfo);
      void          DelMeth(const std::string& name);
      bool          TstMeth(const std::string& name);
        
    // some constants (also defined in cpp)
      static const int kOK  = TCL_OK;       //!<
      static const int kERR = TCL_ERROR;    //!<

    protected:
      bool          GetArgsDump(RtclArgs& args, int& detail);
      int           M_info(RtclArgs& args);

    protected:
      mmap_t        fMethMap;               //!< map for named methods
  };
  
} // end namespace Retro

//#include "RtclCmdBase.ipp"

#endif
