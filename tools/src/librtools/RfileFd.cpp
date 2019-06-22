// $Id: RfileFd.cpp 1167 2019-06-20 10:17:11Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-15  1163   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of class RfileFd.
*/
#include <errno.h>

#include "RfileFd.hpp"

using namespace std;

/*!
  \class Retro::RfileFd
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

RfileFd::RfileFd()
  : RfileFd("RfileFd::")
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RfileFd::RfileFd(const char* cnam)
  : Rfd(cnam)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RfileFd::Open(const char* fname, int flags, RerrMsg& emsg)
{
  Close();
  if (!SetFd(::open(fname, flags))) {
    emsg.InitErrno(fCnam+"Open()", 
                   string("open() for '") + fname + "' failed: ", errno);
  }
  return IsOpen();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RfileFd::Stat(struct stat *sbuf, RerrMsg& emsg)
{
  if (::fstat(fFd, sbuf) < 0) {
    emsg.InitErrno(fCnam+"Stat()", "stat() failed: ", errno);
    return false;
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

off_t RfileFd::Seek(off_t offset, int whence, RerrMsg& emsg)
{
  if (::lseek(fFd, offset, whence) < 0) {
    emsg.InitErrno(fCnam+"Seek()", "seek() failed: ", errno);
    return false;
  }
  return true;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RfileFd::Truncate(off_t length, RerrMsg& emsg)
{
  if (::ftruncate(fFd, length) < 0) {
    emsg.InitErrno(fCnam+"Truncate()", "ftruncate() failed: ", errno);
    return false;
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

ssize_t RfileFd::Read(void *buf, size_t count, RerrMsg& emsg)
{
  ssize_t irc = ::read(fFd, buf, count);
  if (irc < 0) {
    emsg.InitErrno(fCnam+"Read()", "read() failed: ", errno);
  }
  return irc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RfileFd::WriteAll(const void *buf, size_t count, RerrMsg& emsg)
{
  ssize_t irc = ::write(fFd, buf, count);
  if (irc < ssize_t(count)) {
    emsg.InitErrno("WriteAll()", "write() failed: ", errno);
    return false;
  }
  return true;
}

} // end namespace Retro
