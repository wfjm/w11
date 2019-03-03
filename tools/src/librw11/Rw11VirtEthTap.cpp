// $Id: Rw11VirtEthTap.cpp 1114 2019-02-23 18:01:55Z mueller $
//
// Copyright 2014-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-02-23  1114   1.0.4  use std::bind instead of lambda
// 2018-12-15  1082   1.0.3  use lambda instead of boost::bind
// 2018-11-30  1075   1.0.2  use list-init
// 2018-10-27  1059   1.0.1  coverity fixup (uncaught exception in dtor)
//                           BUGFIX: coverity (buffer not null terminated)
// 2017-04-15   875   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of Rw11VirtEthTap.
*/
#define _XOPEN_SOURCE 600

#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>

#include <sys/ioctl.h>
#include <net/if.h>
#include <linux/if_tun.h>

#include <functional>

#include "librtools/RosFill.hpp"
#include "librtools/Rtools.hpp"

#include "Rw11VirtEthTap.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::Rw11VirtEthTap
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtEthTap::Rw11VirtEthTap(Rw11Unit* punit)
  : Rw11VirtEth(punit),
    fFd(-1)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtEthTap::~Rw11VirtEthTap()
{
  if (fFd>=2) {
    Rtools::Catch2Cerr(__func__,
                       [this](){ Server().RemovePollHandler(fFd); } );
    ::close(fFd);
  }
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtEthTap::Open(const std::string& url, RerrMsg& emsg)
{
  if (!fUrl.Set(url, "", "tap", emsg)) return false;
  
  if (fUrl.Path().size() >= IFNAMSIZ-1) {
    emsg.Init("Rw11VirtEthTap::Open()", 
              string("device name '") + fUrl.Path() + "' too long");
    return false;
  }

  int fd = ::open("/dev/net/tun", O_RDWR);
  if (fd < 0) {
    emsg.InitErrno("Rw11VirtEthTap::Open()", 
                   "open(/dev/net/tun) failed: ", errno);
    return false;
  }

  struct ifreq ifr = {};
  ::strncpy(ifr.ifr_name, fUrl.Path().c_str(), IFNAMSIZ-1); 
  ifr.ifr_flags = IFF_TAP|IFF_NO_PI;

  if (::ioctl(fd, TUNSETIFF, &ifr) < 0) {
    emsg.InitErrno("Rw11VirtEthTap::Open()", 
                   string("ioctl for '") + fUrl.Path() + "' failed:", errno);
    ::close(fd);
    return false;    
  }
  
  fFd = fd;

  Server().AddPollHandler(bind(&Rw11VirtEthTap::RcvPollHandler, this, _1), 
                          fFd, POLLIN);
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtEthTap::Snd(const RethBuf& ebuf, RerrMsg& emsg)
{
  fStats.Inc(kStatNVTSnd);
  ssize_t irc = ebuf.Write(fFd);
  if (irc != ssize_t(ebuf.Size())) {
    emsg.InitErrno("Rw11VirtEthTap::Snd", "write() failed: ", errno);
    return false;
  }
  fStats.Inc(kStatNVTSndByt, double(ebuf.Size()));
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11VirtEthTap::RcvPollHandler(const pollfd& pfd)
{
  fStats.Inc(kStatNVTRcvPoll);
  // bail-out and cancel handler if poll returns an error event
  if (pfd.revents & (~pfd.events)) return -1;

  RethBuf::pbuf_t pbuf(new RethBuf());
  ssize_t irc = pbuf->Read(fFd);

  if (irc > 0) {
    pbuf->SetTime();
    fRcvCb(pbuf);
    fStats.Inc(kStatNVTRcvByt, double(irc));
  }
  
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtEthTap::Dump(std::ostream& os, int ind, const char* text,
                          int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtEthTap @ " << this << endl;

  os << bl << "  fFd:             " << fFd << endl;
  Rw11VirtEth::Dump(os, ind+2, "", detail);
  return;
}


} // end namespace Retro
