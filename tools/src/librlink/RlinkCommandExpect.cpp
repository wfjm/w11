// $Id: RlinkCommandExpect.cpp 488 2013-02-16 18:49:47Z mueller $
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
// 2011-11-28   434   1.0.1  Dump(): use proper cast for lp64 compatibility
// 2011-03-12   368   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkCommandExpect.cpp 488 2013-02-16 18:49:47Z mueller $
  \brief   Implemenation of class RlinkCommandExpect.
 */

// debug
#include <iostream>

#include <algorithm>

#include "RlinkCommandExpect.hpp"

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"

using namespace std;

/*!
  \class Retro::RlinkCommandExpect
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkCommandExpect::RlinkCommandExpect()
  : fStatusVal(0),
    fStatusMsk(0xff),
    fDataVal(0),
    fDataMsk(0xffff),
    fBlockVal(),
    fBlockMsk()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlinkCommandExpect::RlinkCommandExpect(uint8_t stat, uint8_t statmsk)
  : fStatusVal(stat),
    fStatusMsk(statmsk),
    fDataVal(0),
    fDataMsk(0xffff),
    fBlockVal(),
    fBlockMsk()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlinkCommandExpect::RlinkCommandExpect(uint8_t stat, uint8_t statmsk,
                                       uint16_t data, uint16_t datamsk)
  : fStatusVal(stat),
    fStatusMsk(statmsk),
    fDataVal(data),
    fDataMsk(datamsk),
    fBlockVal(),
    fBlockMsk()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlinkCommandExpect::RlinkCommandExpect(uint8_t stat, uint8_t statmsk,
                                       const std::vector<uint16_t>& block)
  : fStatusVal(stat),
    fStatusMsk(statmsk),
    fDataVal(0),
    fDataMsk(0xffff),
    fBlockVal(block),
    fBlockMsk()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlinkCommandExpect::RlinkCommandExpect(uint8_t stat, uint8_t statmsk,
                                       const std::vector<uint16_t>& block,
                                       const std::vector<uint16_t>& blockmsk)
  : fStatusVal(stat),
    fStatusMsk(statmsk),
    fDataVal(0),
    fDataMsk(0xffff),
    fBlockVal(block),
    fBlockMsk(blockmsk)
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkCommandExpect::~RlinkCommandExpect()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkCommandExpect::BlockCheck(size_t ind, uint16_t val) const
{
  if (ind >= fBlockVal.size()) return true;
  uint16_t eval = fBlockVal[ind];
  uint16_t emsk = (ind < fBlockMsk.size()) ? fBlockMsk[ind] : 0x0000;
  return (val|emsk) == (eval|emsk);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandExpect::BlockCheck(const uint16_t* pval, size_t size) const
{
  size_t nerr = 0;
  for (size_t i=0; i<size; i++) {
    if (i >= fBlockVal.size()) break;
    uint16_t eval = fBlockVal[i];
    uint16_t emsk = (i < fBlockMsk.size()) ? fBlockMsk[i] : 0x0000;
    if ((pval[i]|emsk) != (eval|emsk)) nerr += 1;
  }

  return nerr;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkCommandExpect::BlockIsChecked(size_t ind) const
{
  if (ind >= fBlockVal.size()) return false;
  if (ind >= fBlockMsk.size()) return true;
  return fBlockMsk[ind] != 0xffff;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandExpect::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkCommandExpect @ " << this << endl;

  os << bl << "  fStatusVal:     " << RosPrintBvi(fStatusVal,0) << endl;
  os << bl << "  fStatusMsk:     " << RosPrintBvi(fStatusMsk,0) << endl;
  os << bl << "  fDataVal:       " << RosPrintBvi(fDataVal,0) << endl;
  os << bl << "  fDataMsk:       " << RosPrintBvi(fDataMsk,0) << endl;
  os << bl << "  fBlockVal.size: " << RosPrintf(fBlockVal.size(),"d",3) << endl;
  os << bl << "  fBlockMsk.size: " << RosPrintf(fBlockMsk.size(),"d",3) << endl;
  if (fBlockVal.size() > 0) {
    os << bl << "  fBlockVal & Msk data: ";
    size_t width = (fBlockMsk.size()>0) ? 9 : 4;
    size_t ncol  = max(((size_t) 1), (80-ind-4-5)/(width+1));
    for (size_t i=0; i< fBlockVal.size(); i++) {
      if (i%ncol == 0) os << "\n" << bl << "    " << RosPrintf(i,"d",3) << ": ";
      
      os << RosPrintBvi(fBlockVal[i],16);
      if (fBlockMsk.size()>0) {
        if (i<fBlockMsk.size() && fBlockMsk[i]!=0x0000) {
          os << "," <<  RosPrintBvi(fBlockMsk[i],16);
        } else {
          os << "     ";
        }
      }
      os << " ";
    }
    os << endl;
  }
  
  return;
}

} // end namespace Retro
