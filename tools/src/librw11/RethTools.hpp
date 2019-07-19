// $Id: RethTools.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-15   875   1.0    Initial version
// 2017-02-04   849   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of class RethTools .
*/

#ifndef included_Retro_RethTools
#define included_Retro_RethTools 1

#include <cstdint>
#include <string>

#include "librtools/RerrMsg.hpp"

namespace Retro {

  namespace RethTools {
    std::string    Mac2String(uint64_t mac);
    bool           String2Mac(const std::string& str, uint64_t& mac,
                              RerrMsg& emsg);
    uint64_t       String2Mac(const std::string& str);
    void           Mac2WList(uint64_t mac, uint16_t wlist[3]);
    uint64_t       WList2Mac(const uint16_t wlist[3]);

  } // end namespace RethTools

} // end namespace Retro

#include "RethTools.ipp"

#endif
