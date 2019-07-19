// $Id: Rw11VirtTermPty.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-02-23  1114   1.0.5  use std::bind instead of lambda
// 2018-12-15  1082   1.0.4  use lambda instead of boost::bind
// 2018-10-27  1059   1.0.3  coverity fixup (uncaught exception in dtor)
// 2017-04-15   875   1.0.2  Open(): set default scheme
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-03-06   495   1.0    Initial version
// 2013-02-24   492   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rw11VirtTermPty.
*/
#define _XOPEN_SOURCE 600

#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>

#include <functional>

#include "librtools/RosFill.hpp"
#include "Rw11VirtTermPty.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::Rw11VirtTermPty
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtTermPty::Rw11VirtTermPty(Rw11Unit* punit)
  : Rw11VirtTerm(punit),
    fFd(-1)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtTermPty::~Rw11VirtTermPty()
{
  if (fFd>=2) {
    Rtools::Catch2Cerr(__func__,
                       [this](){ Server().RemovePollHandler(fFd); } );
    ::close(fFd);
  }
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTermPty::Open(const std::string& url, RerrMsg& emsg)
{
  if (!fUrl.Set(url, "", "pty", emsg)) return false;

  int fd = posix_openpt(O_RDWR);
  if (fd < 0) {
    emsg.InitErrno("Rw11VirtTermPty::Open", "posix_openpt() failed: ", errno);
    return false;
  }

  int irc = grantpt(fd);
  if (irc < 0) {
    emsg.InitErrno("Rw11VirtTermPty::Open", "grantpt() failed: ", errno);
    ::close(fd);
    return false;
  }
  
  irc = unlockpt(fd);
  if (irc < 0) {
    emsg.InitErrno("Rw11VirtTermPty::Open", "unlockpt() failed: ", errno);
    ::close(fd);
    return false;
  }
  
  char* pname = ptsname(fd);
  if (pname == nullptr) {
    emsg.InitErrno("Rw11VirtTermPty::Open", "ptsname() failed: ", errno);
    ::close(fd);
    return false;
  }
  
  fFd = fd;
  fChannelId = pname;

  Server().AddPollHandler(bind(&Rw11VirtTermPty::RcvPollHandler, this, _1), 
                          fFd, POLLIN);

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTermPty::Snd(const uint8_t* data, size_t count, RerrMsg& emsg)
{
  fStats.Inc(kStatNVTSnd);
  ssize_t irc = write(fFd, data, count);
  if (irc != ssize_t(count)) {
    emsg.InitErrno("Rw11VirtTermPty::Snd", "write() failed: ", errno);
    return false;
  }
  fStats.Inc(kStatNVTSndByt, double(count));
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11VirtTermPty::RcvPollHandler(const pollfd& pfd)
{
  fStats.Inc(kStatNVTRcvPoll);
  // bail-out and cancel handler if poll returns an error event
  if (pfd.revents & (~pfd.events)) return -1;

  uint8_t buf[1024];
  ssize_t irc = read(fFd, buf, 1024);

  if (irc > 0) {
    fRcvCb(buf, size_t(irc));
    fStats.Inc(kStatNVTRcvByt, double(irc));
  }
  
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtTermPty::Dump(std::ostream& os, int ind, const char* text,
                           int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtTermPty @ " << this << endl;

  os << bl << "  fFd:             " << fFd << endl;
  Rw11VirtTerm::Dump(os, ind+2, "", detail);
  return;
}


} // end namespace Retro
