// $Id: RtraceTools.hpp 1140 2019-04-28 10:21:21Z mueller $
//
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-04-27  1140   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Declaration of class RtraceTools .
*/

#ifndef included_Retro_RtraceTools
#define included_Retro_RtraceTools 1

#include <cstdint>

#include "librtools/RlogMsg.hpp"

namespace Retro {

  namespace RtraceTools {
    void           TraceBuffer(RlogMsg& lmsg, const uint16_t* pbuf,
                               size_t done, uint32_t level);
    void           TraceChar(RlogMsg& lmsg, uint8_t chr);

  } // end namespace RtraceTools

} // end namespace Retro

#endif
