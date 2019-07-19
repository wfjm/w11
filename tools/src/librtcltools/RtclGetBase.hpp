// $Id: RtclGetBase.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
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
