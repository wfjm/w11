// $Id: RlinkPortFactory.cpp 465 2012-12-27 21:29:38Z mueller $
//
// Copyright 2011-2012 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2012-12-26   465   1.1    add cuff: support
// 2011-03-27   374   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPortFactory.cpp 465 2012-12-27 21:29:38Z mueller $
  \brief   Implemenation of RlinkPortFactory.
*/

#include "RlinkPortFactory.hpp"
#include "RlinkPortFifo.hpp"
#include "RlinkPortTerm.hpp"
#include "RlinkPortCuff.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::RlinkPortFactory
  \brief FIXME_text
*/

//------------------------------------------+-----------------------------------
//! FIXME_text

RlinkPort* Retro::RlinkPortFactory::New(const std::string& url, RerrMsg& emsg)
{
  size_t dpos = url.find_first_of(':');
  if (dpos == string::npos) {
    emsg.Init("RlinkPortFactory::New()", 
              string("no scheme specified in url \"" + url + string("\"")));
    return 0;
  }

  string scheme = url.substr(0,dpos);      // get scheme without ':' delim

  if        (scheme == "fifo") {
    return new RlinkPortFifo();
  } else if (scheme == "term") {
    return new RlinkPortTerm();
  } else if (scheme == "cuff") {
    return new RlinkPortCuff();
  }
  
  emsg.Init("RlinkPortFactory::New()", string("unknown scheme: ") + scheme);
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

RlinkPort* RlinkPortFactory::Open(const std::string& url, RerrMsg& emsg)
{
  RlinkPort* pport = New(url, emsg);
  if (pport == 0) return 0;

  if (pport->Open(url, emsg)) return pport;
  delete pport;
  return 0;
}


//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_RlinkPortFactory_NoInline))
#define inline
//#include "RlinkPortFactory.ipp"
#undef  inline
#endif
