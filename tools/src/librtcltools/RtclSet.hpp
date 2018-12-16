// $Id: RtclSet.hpp 1083 2018-12-15 19:19:16Z mueller $
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
// 2018-12-15  1083   1.0.2  ctor: use rval ref and move semantics
// 2018-12-14  1081   1.0.1  use std::function instead of boost
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Declaration of class \c RtclSet.
*/

#ifndef included_Retro_RtclSet
#define included_Retro_RtclSet 1

#include "tcl.h"

#include <cstdint>
#include <string>
#include <functional>

#include "librtools/Rexception.hpp"
#include "RtclSetBase.hpp"

namespace Retro {

  template <class TP>
  class RtclSet : public RtclSetBase {
    public:
      explicit      RtclSet(std::function<void(TP)>&& set);
                   ~RtclSet();

      virtual void  operator()(RtclArgs& args) const;

    protected: 
      std::function<void(TP)> fSet;
  };
  
  
} // end namespace Retro

#include "RtclSet.ipp"

#endif
