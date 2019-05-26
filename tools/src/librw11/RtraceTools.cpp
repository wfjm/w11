// $Id: RtraceTools.cpp 1149 2019-05-12 21:00:29Z mueller $
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
// 2019-05-12  1149   1.0.1  add level 5 (full word dump)
// 2019-04-27  1140   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RethTools .
*/

#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"

#include "RtraceTools.hpp"

using namespace std;

/*!
  \namespace Retro::RtraceTools
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {
namespace RtraceTools {

//------------------------------------------+-----------------------------------
//! FIXME_docs

void TraceBuffer(RlogMsg& lmsg, const uint16_t* pbuf, size_t done,
                 uint32_t level)
{
  size_t nchar = 0;
  switch (level) {
  case 2:                                   // level=2: compact ascii --------
    for (size_t i=0; i < done; i++) {
      uint8_t ochr = pbuf[i] & 0377;
      if (ochr>=040 && ochr<0177) {
        if (nchar == 0) lmsg << "\n      '";
        lmsg << char(ochr);
        nchar += 1;
        if (nchar >= 64) {
          lmsg << "'";
          nchar = 0;
        }          
      } else {
        if (nchar > 0) lmsg << "'";
        lmsg << "\n      ";
        TraceChar(lmsg, ochr);
        nchar = 0;
      }
    }
    if (nchar > 0) lmsg << "'";
    break;

  case 3:                                   // level=3: compact octal --------
    for (size_t i=0; i < done; i++) {
      if (nchar == 0) lmsg << "\n      ";
      uint8_t ochr = pbuf[i] & 0377;
      lmsg << ' ' << RosPrintBvi(ochr,8);
      nchar += 1;
      if (nchar >= 16) nchar = 0;
    }
    break;

  case 4:                                   // level=4: octal + ascii --------
    for (size_t i=0; i < done; i++) {
      if (nchar == 0) lmsg << "\n      ";
      uint8_t ochr = pbuf[i] & 0377;
      lmsg << "  " << RosPrintBvi(ochr,8) << ' ';
      TraceChar(lmsg, ochr);
      nchar += 1;
      if (nchar >= 6) nchar = 0;
    }
    break;
    
  case 5:                                   // level=4: full word dump -------
    for (size_t i=0; i < done; i++) {
      bool    val  = (pbuf[i]     & 0x8000) != 0;
      uint8_t size = (pbuf[i]>>8) & 0177;
      uint8_t ochr =  pbuf[i] & 0377;
      lmsg << "\n      " << RosPrintf(i,"d",3)
           << " : " << val
           << " " << RosPrintf(size,"d",3)
           << " " << RosPrintBvi(size,8)
           << " : " << RosPrintBvi(ochr,8)
           << " ";
      TraceChar(lmsg, ochr);
    }
    break;
  }
  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void TraceChar(RlogMsg& lmsg, uint8_t chr)
{
  lmsg << ((chr&0200) ? "|" : " ");
  uint8_t chr7 = chr & 0177;
  if (chr7 < 040) {
    switch (chr7) {
    case 010: lmsg << "BS "; break;
    case 011: lmsg << "HT "; break;
    case 012: lmsg << "LF "; break;
    case 013: lmsg << "VT "; break;
    case 014: lmsg << "FF "; break;
    case 015: lmsg << "CR "; break;
    case 033: lmsg << "ESC"; break;
    default:  lmsg << "^" << char('@'+chr7) << " ";
    }
  } else {
    if (chr7 < 0177) {
      lmsg << "'" << char(chr7) << "'";
    } else {
      lmsg << "DEL";
    }
  }
  return;
} 

} // end namespace RtraceTools
} // end namespace Retro
