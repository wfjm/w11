// $Id: RtraceTools.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-04-27  1140   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
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
