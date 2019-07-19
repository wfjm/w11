// $Id: RlinkChannel.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.0.2  use std::shared_ptr instead of boost
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-02-23   492   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of class RlinkChannel.
 */

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/Rexception.hpp"

#include "RlinkChannel.hpp"

using namespace std;

/*!
  \class Retro::RlinkChannel
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkChannel::RlinkChannel(const std::shared_ptr<RlinkConnect>& spconn)
  : fContext(),
    fspConn(spconn)
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkChannel::~RlinkChannel()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkChannel::Exec(RlinkCommandList& clist, RerrMsg& emsg)
{
  if (!fspConn)
    throw Rexception("RlinkChannel::Exec", "Bad state: fspConn == 0");
  
  return fspConn->Exec(clist, emsg);
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkChannel::Dump(std::ostream& os, int ind, const char* text,
                        int /*detail*/) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkChannel @ " << this << endl;

  fContext.Dump(os, ind+2, "fContext: ");
  if (fspConn) {
    fspConn->Dump(os, ind+2, "fspConn: ");
  } else {
    os << bl << "  fspConn:         " <<  fspConn.get() << endl;
  }
  
  return;
}

} // end namespace Retro
