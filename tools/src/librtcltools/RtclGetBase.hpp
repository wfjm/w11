// $Id: RtclGetBase.hpp 1088 2018-12-17 17:37:00Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Declaration of class \c RtclGetBase.
*/

#ifndef included_Retro_RtclGetBase
#define included_Retro_RtclGetBase 1

#include "tcl.h"

#include <cstdint>
#include <string>

namespace Retro {

  class RtclGetBase {
    public:
                    RtclGetBase();
      virtual      ~RtclGetBase();

      virtual Tcl_Obj*  operator()() const = 0;
  };
  
  
} // end namespace Retro

//#include "RtclGetBase.ipp"

#endif
