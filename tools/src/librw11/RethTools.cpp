// $Id: RethTools.cpp 875 2017-04-15 21:58:50Z mueller $
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
  \version $Id: RethTools.cpp 875 2017-04-15 21:58:50Z mueller $
  \brief   Implemenation of RethTools .
*/

#include "librtools/Rexception.hpp"
#include "librtools/Rtools.hpp"

#include "RethTools.hpp"

using namespace std;

/*!
  \namespace Retro::RethTools
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {
namespace RethTools {

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string Mac2String(uint64_t mac)
{
  const char* codes = "0123456789abcdef";
  string rval;
  rval.reserve(3*6-1);                      // reserve expected length
  for (int ib=0; ib<6; ib++) {
    uint64_t byte = mac & 0xff;
    mac = mac >> 8;
    if (ib > 0) rval += ':';
    rval += codes[(byte>>4) & 0x0f];
    rval += codes[ byte     & 0x0f];
  }
  
  return rval;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
bool String2Mac(const std::string& str, uint64_t& mac, RerrMsg& emsg)
{
  if (str.length() != 17) {
    emsg.Init("RethTools::String2Mac",
              string("invalid string size for '") + str +"'");
    return false;
  }
  mac = 0;
  for (int ib=0; ib<6; ib++) {
    unsigned long byte;
    if (!Rtools::String2Long(str.substr(3*ib,2), byte, emsg, 16)) return false;
    mac |= uint64_t(byte&0xff)<<(8*ib);
    if (ib > 0) {
      char delim = str[3*ib-1];
      if (delim != ':' && delim != '-') {
        emsg.Init("RethTools::String2Mac",
                  string("invalid delimiter '") + delim +"'");
        return false;
      }
    }
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
uint64_t String2Mac(const std::string& str) 
{
  uint64_t mac;
  RerrMsg emsg;
  if (!String2Mac(str, mac, emsg)) throw Rexception(emsg);
  return mac;
}

} // end namespace RethTools
} // end namespace Retro
