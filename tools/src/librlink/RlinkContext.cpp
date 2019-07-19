// $Id: RlinkContext.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-03-16  1122   1.1    BUGFIX: use proper polarity of status mask
// 2018-12-18  1089   1.0.2  use c++ style casts
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-02-23   492   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of class RlinkContext.
 */

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"

#include "RlinkContext.hpp"

using namespace std;

/*!
  \class Retro::RlinkContext
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkContext::RlinkContext()
  : fStatusVal(0),
    fStatusMsk(0x00),
    fErrCnt(0)
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkContext::~RlinkContext()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkContext::Dump(std::ostream& os, int ind, const char* text,
                        int /*detail*/) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkContext @ " << this << endl;

  os << bl << "  fStatusVal:     " << RosPrintBvi(fStatusVal,0) << endl;
  os << bl << "  fStatusMsk:     " << RosPrintBvi(fStatusMsk,0) << endl;
  os << bl << "  fErrCnt:        " << RosPrintf(int(fErrCnt),"d") << endl;  
  return;
}

} // end namespace Retro
