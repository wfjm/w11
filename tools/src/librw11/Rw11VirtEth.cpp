// $Id: Rw11VirtEth.cpp 887 2017-04-28 19:32:52Z mueller $
//
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-07   868   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of Rw11VirtEth.
*/
#include <memory>

#include "librtools/RparseUrl.hpp"
#include "librtools/RosFill.hpp"
#include "Rw11VirtEthTap.hpp"

#include "Rw11VirtEth.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtEth
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtEth::Rw11VirtEth(Rw11Unit* punit)
  : Rw11Virt(punit),
    fChannelId(),
    fRcvCb()
{
  fStats.Define(kStatNVTRcvPoll,     "NVTRcvPoll", "VT RcvPollHandler() calls");
  fStats.Define(kStatNVTSnd,         "NVTSnd",       "VT Snd() calls");
  fStats.Define(kStatNVTRcvByt,      "NVTRcvByt",    "VT bytes received");
  fStats.Define(kStatNVTSndByt,      "NVTSndByt",    "VT bytes send");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtEth::~Rw11VirtEth()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rw11VirtEth* Rw11VirtEth::New(const std::string& url, Rw11Unit* punit,
                                RerrMsg& emsg)
{
  string scheme = RparseUrl::FindScheme(url, "tcp");
  unique_ptr<Rw11VirtEth> p;
  
  if        (scheme == "tap") {             // scheme -> tap:
    p.reset(new Rw11VirtEthTap(punit));
    if (p->Open(url, emsg)) return p.release();

  } else {                                  // scheme -> no match
    emsg.Init("Rw11VirtEth::New", string("Scheme '") + scheme +
              "' is not supported");

  }
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtEth::Dump(std::ostream& os, int ind, const char* text,
                       int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtEth @ " << this << endl;

  os << bl << "  fChannelId:      " << fChannelId << endl;
  Rw11Virt::Dump(os, ind, " ^", detail);
  return;
}

} // end namespace Retro
