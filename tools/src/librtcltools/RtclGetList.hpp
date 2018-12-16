// $Id: RtclGetList.hpp 1083 2018-12-15 19:19:16Z mueller $
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
// 2018-12-15  1083   1.2.2  Add(): use rval ref and move semantics
// 2018-12-14  1081   1.2.1  use std::function instead of boost
// 2018-12-01  1076   1.2    use unique_ptr
// 2015-01-08   631   1.1    add Clear()
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Declaration of class \c RtclGetList.
*/

#ifndef included_Retro_RtclGetList
#define included_Retro_RtclGetList 1

#include "tcl.h"

#include <cstdint>
#include <string>
#include <map>
#include <functional>

#include "boost/utility.hpp"

#include "RtclGet.hpp"
#include "librtcltools/RtclArgs.hpp"

namespace Retro {

  class RtclGetList : private boost::noncopyable {
    public:
      typedef std::unique_ptr<RtclGetBase> get_uptr_t;
    
                    RtclGetList();
      virtual      ~RtclGetList();

      void          Add(const std::string& name, get_uptr_t&& upget);

      template <class TP>
      void          Add(const std::string& name, std::function<TP()>&& get);

      void          Clear();
      int           M_get(RtclArgs& args);

    protected: 
      typedef std::map<std::string, get_uptr_t> map_t;

      map_t         fMap;
  };
  
} // end namespace Retro

#include "RtclGetList.ipp"

#endif
