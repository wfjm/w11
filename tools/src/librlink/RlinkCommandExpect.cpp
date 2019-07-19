// $Id: RlinkCommandExpect.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-21  1090   1.1.3  use constructor delegation
// 2018-12-18  1089   1.1.2  use c++ style casts
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2015-04-02   661   1.1    expect logic: remove stat from Expect, invert mask
// 2011-11-28   434   1.0.1  Dump(): use proper cast for lp64 compatibility
// 2011-03-12   368   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------

/*!
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
  : RlinkCommandExpect(0,0x0)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlinkCommandExpect::RlinkCommandExpect(uint16_t data, uint16_t datamsk)
  : fDataVal(data),
    fDataMsk(datamsk),
    fBlockVal(),
    fBlockMsk()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlinkCommandExpect::RlinkCommandExpect(const std::vector<uint16_t>& block)
  : fDataVal(0),
    fDataMsk(0x0),
    fBlockVal(block),
    fBlockMsk()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlinkCommandExpect::RlinkCommandExpect(const std::vector<uint16_t>& block,
                                       const std::vector<uint16_t>& blockmsk)
  : fDataVal(0),
    fDataMsk(0x0),
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
  uint16_t emsk = (ind < fBlockMsk.size()) ? fBlockMsk[ind] : 0xffff;
  return (val & emsk) == eval;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandExpect::BlockCheck(const uint16_t* pval, size_t size) const
{
  size_t nerr = 0;
  for (size_t i=0; i<size; i++) {
    if (i >= fBlockVal.size()) break;
    uint16_t eval = fBlockVal[i];
    uint16_t emsk = (i < fBlockMsk.size()) ? fBlockMsk[i] : 0xffff;
    if ((pval[i] & emsk) != eval) nerr += 1;
  }

  return nerr;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkCommandExpect::BlockIsChecked(size_t ind) const
{
  if (ind >= fBlockVal.size()) return false;
  if (ind >= fBlockMsk.size()) return true;
  return fBlockMsk[ind] != 0x0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandExpect::Dump(std::ostream& os, int ind, const char* text,
                              int /*detail*/) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkCommandExpect @ " << this << endl;

  os << bl << "  fDataVal:       " << RosPrintBvi(fDataVal,0) << endl;
  os << bl << "  fDataMsk:       " << RosPrintBvi(fDataMsk,0) << endl;
  os << bl << "  fBlockVal.size: " << RosPrintf(fBlockVal.size(),"d",3) << endl;
  os << bl << "  fBlockMsk.size: " << RosPrintf(fBlockMsk.size(),"d",3) << endl;
  if (fBlockVal.size() > 0) {
    os << bl << "  fBlockVal & Msk data: ";
    size_t width = (fBlockMsk.size()>0) ? 9 : 4;
    size_t ncol  = max(size_t(1), (80-ind-4-5)/(width+1));
    for (size_t i=0; i< fBlockVal.size(); i++) {
      if (i%ncol == 0) os << "\n" << bl << "    " << RosPrintf(i,"d",3) << ": ";
      
      os << RosPrintBvi(fBlockVal[i],16);
      if (fBlockMsk.size()>0) {
        if (i<fBlockMsk.size() && fBlockMsk[i]!=0xffff) {
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
