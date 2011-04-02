// $Id: RlinkCrc8.cpp 365 2011-02-28 07:28:26Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-02-27   365   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkCrc8.cpp 365 2011-02-28 07:28:26Z mueller $
  \brief   Implemenation of class RlinkCrc8.
 */

#include "RlinkCrc8.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::RlinkCrc8
  \brief FIXME_text
*/

//------------------------------------------+-----------------------------------
//! FIXME_docs
// from gen_crc8_tbl

const uint8_t RlinkCrc8::fCrc8Table[256] =
{
    0,  29,  58,  39, 116, 105,  78,  83,
  232, 245, 210, 207, 156, 129, 166, 187,
  205, 208, 247, 234, 185, 164, 131, 158,
   37,  56,  31,   2,  81,  76, 107, 118,
  135, 154, 189, 160, 243, 238, 201, 212,
  111, 114,  85,  72,  27,   6,  33,  60,
   74,  87, 112, 109,  62,  35,   4,  25,
  162, 191, 152, 133, 214, 203, 236, 241,
   19,  14,  41,  52, 103, 122,  93,  64,
  251, 230, 193, 220, 143, 146, 181, 168,
  222, 195, 228, 249, 170, 183, 144, 141,
   54,  43,  12,  17,  66,  95, 120, 101,
  148, 137, 174, 179, 224, 253, 218, 199,
  124,  97,  70,  91,   8,  21,  50,  47,
   89,  68,  99, 126,  45,  48,  23,  10,
  177, 172, 139, 150, 197, 216, 255, 226,
   38,  59,  28,   1,  82,  79, 104, 117,
  206, 211, 244, 233, 186, 167, 128, 157,
  235, 246, 209, 204, 159, 130, 165, 184,
    3,  30,  57,  36, 119, 106,  77,  80,
  161, 188, 155, 134, 213, 200, 239, 242,
   73,  84, 115, 110,  61,  32,   7,  26,
  108, 113,  86,  75,  24,   5,  34,  63,
  132, 153, 190, 163, 240, 237, 202, 215,
   53,  40,  15,  18,  65,  92, 123, 102,
  221, 192, 231, 250, 169, 180, 147, 142,
  248, 229, 194, 223, 140, 145, 182, 171,
   16,  13,  42,  55, 100, 121,  94,  67,
  178, 175, 136, 149, 198, 219, 252, 225,
   90,  71,  96, 125,  46,  51,  20,   9,
  127,  98,  69,  88,  11,  22,  49,  44,
  151, 138, 173, 176, 227, 254, 217, 196
};

//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_RlinkCrc8_NoInline))
#define inline
#include "RlinkCrc8.ipp"
#undef  inline
#endif
