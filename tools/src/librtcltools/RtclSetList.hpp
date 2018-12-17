// $Id: RtclSetList.hpp 1084 2018-12-16 12:23:53Z mueller $
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
// 2018-12-16  1084   1.2.3  use =delete for noncopyable instead of boost
// 2018-12-15  1083   1.2.2  Add(): use rval ref and move semantics
// 2018-12-14  1081   1.2.1  use std::function instead of boost
// 2018-12-01  1076   1.2    use unique_ptr
// 2015-01-08   631   1.1    add Clear()
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Declaration of class \c RtclSetList.
*/

#ifndef included_Retro_RtclSetList
#define included_Retro_RtclSetList 1

#include "tcl.h"

#include <cstdint>
#include <string>
#include <map>
#include <functional>

#include "RtclSet.hpp"
#include "librtcltools/RtclArgs.hpp"

namespace Retro {

  class RtclSetList {
    public:
      typedef std::unique_ptr<RtclSetBase> set_uptr_t;

                    RtclSetList();
      virtual      ~RtclSetList();

                    RtclSetList(const RtclSetList&) = delete;   // noncopyable 
      RtclSetList&  operator=(const RtclSetList&) = delete;     // noncopyable

      void          Add(const std::string& name, set_uptr_t&& upset);

      template <class TP>
      void          Add(const std::string& name, 
                        std::function<void(TP)>&& set);

      void          Clear();
      int           M_set(RtclArgs& args);

    protected: 
      typedef std::map<std::string, set_uptr_t> map_t;

      map_t         fMap;
  };
  
} // end namespace Retro

#include "RtclSetList.ipp"

#endif
