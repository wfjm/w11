// $Id: RethTools.hpp 887 2017-04-28 19:32:52Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-15   875   1.0    Initial version
// 2017-02-04   849   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
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
