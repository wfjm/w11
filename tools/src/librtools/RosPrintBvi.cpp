// $Id: RosPrintBvi.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-18  1089   1.0.3  use c++ style casts
// 2013-02-03   481   1.0.2  use Rexception
// 2011-03-12   368   1.0.1  allow base=0, will print in hex,oct and bin
// 2011-03-05   366   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RosPrintBvi .
*/

#include "RosPrintBvi.hpp"

#include "Rexception.hpp"

using namespace std;

/*! 
  \class Retro::RosPrintBvi 
  \brief FIXME_docs.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor. FIXME_docs

RosPrintBvi::RosPrintBvi(uint8_t val, size_t base, size_t nbit)
  : fVal(val),
    fBase(base),
    fNbit(nbit)
{
  if (base!=0 && base!=2 && base!=8 && base!=16)
    throw Rexception("RosPrintBvi::<ctor>",
                     "Bad args: base must be 0,2,8, or 16");
  if (nbit<1 || nbit>8)
    throw Rexception("RosPrintBvi::<ctor>",
                     "Bad args: nbit must be in 1,..,8");
}

//------------------------------------------+-----------------------------------
//! Constructor. FIXME_docs

RosPrintBvi::RosPrintBvi(uint16_t val, size_t base, size_t nbit)
  : fVal(val),
    fBase(base),
    fNbit(nbit)
{
  if (base!=0 && base!=2 && base!=8 && base!=16)
    throw Rexception("RosPrintBvi::<ctor>",
                     "Bad args: base must be 0,2,8, or 16");
  if (nbit<1 || nbit>16)
    throw Rexception("RosPrintBvi::<ctor>",
                     "Bad args: nbit must be in 1,..,16");
}

//------------------------------------------+-----------------------------------
//! Constructor. FIXME_docs

RosPrintBvi::RosPrintBvi(uint32_t val, size_t base, size_t nbit)
  : fVal(val),
    fBase(base),
    fNbit(nbit)
{
  if (base!=0 && base!=2 && base!=8 && base!=16)
    throw Rexception("RosPrintBvi::<ctor>",
                     "Bad args: base must be 0,2,8, or 16");
  if (nbit<1 || nbit>32)
    throw Rexception("RosPrintBvi::<ctor>",
                     "Bad args: nbit must be in 1,..,32");
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RosPrintBvi::Print(std::ostream& os) const
{
  if (fBase == 0) {
    os << RosPrintBvi(fVal, 16, fNbit) << "  " 
       << RosPrintBvi(fVal,  8, fNbit) << "  " 
       << RosPrintBvi(fVal,  2, fNbit);
    return;
  }
  
  char buf[33];
  Convert(buf);
  os << buf;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RosPrintBvi::Print(std::string& os) const
{
  if (fBase == 0) {
    os << RosPrintBvi(fVal, 16, fNbit);
    os += "  ";
    os << RosPrintBvi(fVal,  8, fNbit);
    os += "  ";
    os << RosPrintBvi(fVal,  2, fNbit);
    return;
  }

  char buf[33];
  Convert(buf);
  os += buf;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RosPrintBvi::Convert(char* pbuf) const
{

  size_t nwidth = 1;
  if (fBase ==  8) nwidth = 3;
  if (fBase == 16) nwidth = 4;
  uint32_t nmask = (1<<nwidth)-1;

  size_t ndig = (fNbit+nwidth-1)/nwidth;

  for (size_t i=ndig; i>0; i--) {
    uint32_t nibble = ((fVal)>>((i-1)*nwidth)) & nmask;
    nibble += (nibble <= 9) ? '0' : ('a'-10);
    *pbuf++ = char(nibble);
  }

  *pbuf++ = '\0';

  return;
}

} // end namespace Retro

