// $Id: RlinkContext.cpp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-02-23   492   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
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
    fStatusMsk(0xff),
    fErrCnt(0)
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkContext::~RlinkContext()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkContext::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkContext @ " << this << endl;

  os << bl << "  fStatusVal:     " << RosPrintBvi(fStatusVal,0) << endl;
  os << bl << "  fStatusMsk:     " << RosPrintBvi(fStatusMsk,0) << endl;
  os << bl << "  fErrCnt:        " << RosPrintf((int)fErrCnt,"d") << endl;  
  return;
}

} // end namespace Retro
