// $Id: RlinkPortFactory.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-01  1076   2.0    use unique_ptr
// 2013-02-23   492   1.2    use RparseUrl
// 2012-12-26   465   1.1    add cuff: support
// 2011-03-27   374   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RlinkPortFactory.
*/

#include "librtools/RparseUrl.hpp"

#include "RlinkPortFifo.hpp"
#include "RlinkPortTerm.hpp"
#include "RlinkPortCuff.hpp"

#include "RlinkPortFactory.hpp"

using namespace std;

/*!
  \class Retro::RlinkPortFactory
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlinkPort::port_uptr_t RlinkPortFactory::New(
                         const std::string& url, RerrMsg& emsg)
{
  string scheme = RparseUrl::FindScheme(url);
  
  if (scheme.length() == 0) { 
    emsg.Init("RlinkPortFactory::New()", 
              string("no scheme specified in url '" + url + "'"));
    return RlinkPort::port_uptr_t();
  }

  if        (scheme == "fifo") {
    return RlinkPort::port_uptr_t(new RlinkPortFifo());
  } else if (scheme == "term") {
    return RlinkPort::port_uptr_t(new RlinkPortTerm());
  } else if (scheme == "cuff") {
    return RlinkPort::port_uptr_t(new RlinkPortCuff());
  }
  
  emsg.Init("RlinkPortFactory::New()", string("unknown scheme: ") + scheme);
  return RlinkPort::port_uptr_t();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlinkPort::port_uptr_t RlinkPortFactory::Open(
                         const std::string& url, RerrMsg& emsg)
{
  auto upport = New(url, emsg);
  if (upport) {                                       // New OK ?
    if (!(upport->Open(url, emsg))) upport.reset();   // Open OK ?
  }
  return upport;
}

} // end namespace Retro
