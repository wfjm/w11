// $Id: RtclSetBase.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of class \c RtclSetBase.
*/

#ifndef included_Retro_RtclSetBase
#define included_Retro_RtclSetBase 1

#include "tcl.h"

#include <cstdint>
#include <string>

#include "RtclArgs.hpp"

namespace Retro {

  class RtclSetBase {
    public:
                    RtclSetBase();
      virtual      ~RtclSetBase();

      virtual void  operator()(RtclArgs& args) const = 0;
  };
  
  
} // end namespace Retro

//#include "RtclSetBase.ipp"

#endif
