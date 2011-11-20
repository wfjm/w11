// $Id: RlinkCrc8.cpp 410 2011-09-18 11:23:09Z mueller $
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
// 2011-09-17   410   1.1    use now a6 polynomial for crc8
// 2011-02-27   365   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkCrc8.cpp 410 2011-09-18 11:23:09Z mueller $
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
    0,  77, 154, 215, 121,  52, 227, 174,   // from gen_crc8_tbl
  242, 191, 104,  37, 139, 198,  17,  92,
  169, 228,  51, 126, 208, 157,  74,   7,
   91,  22, 193, 140,  34, 111, 184, 245,
   31,  82, 133, 200, 102,  43, 252, 177,
  237, 160, 119,  58, 148, 217,  14,  67,
  182, 251,  44,  97, 207, 130,  85,  24,
   68,   9, 222, 147,  61, 112, 167, 234,
   62, 115, 164, 233,  71,  10, 221, 144,
  204, 129,  86,  27, 181, 248,  47,  98,
  151, 218,  13,  64, 238, 163, 116,  57,
  101,  40, 255, 178,  28,  81, 134, 203,
   33, 108, 187, 246,  88,  21, 194, 143,
  211, 158,  73,   4, 170, 231,  48, 125,
  136, 197,  18,  95, 241, 188, 107,  38,
  122,  55, 224, 173,   3,  78, 153, 212,
  124,  49, 230, 171,   5,  72, 159, 210,
  142, 195,  20,  89, 247, 186, 109,  32,
  213, 152,  79,   2, 172, 225,  54, 123,
   39, 106, 189, 240,  94,  19, 196, 137,
   99,  46, 249, 180,  26,  87, 128, 205,
  145, 220,  11,  70, 232, 165, 114,  63,
  202, 135,  80,  29, 179, 254,  41, 100,
   56, 117, 162, 239,  65,  12, 219, 150,
   66,  15, 216, 149,  59, 118, 161, 236,
  176, 253,  42, 103, 201, 132,  83,  30,
  235, 166, 113,  60, 146, 223,   8,  69,
   25,  84, 131, 206,  96,  45, 250, 183,
   93,  16, 199, 138,  36, 105, 190, 243,
  175, 226,  53, 120, 214, 155,  76,   1,
  244, 185, 110,  35, 141, 192,  23,  90,
    6,  75, 156, 209, 127,  50, 229, 168
};

//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_RlinkCrc8_NoInline))
#define inline
#include "RlinkCrc8.ipp"
#undef  inline
#endif
