// $Id: ReventFd.cpp 1161 2019-06-08 11:52:01Z mueller $
//
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-06-08  1161   1.1    derive from Rfd, inherit Fd
// 2018-12-18  1089   1.0.1  use c++ style casts
// 2013-01-14   475   1.0    Initial version
// 2013-01-11   473   0.5    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of class ReventFd.
*/

#include <errno.h>
#include <unistd.h>
#include <sys/eventfd.h>

#include "ReventFd.hpp"

#include "Rexception.hpp"

using namespace std;

/*!
  \class Retro::ReventFd
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

ReventFd::ReventFd()
  : ReventFd("ReventFd::")
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

ReventFd::ReventFd(const char* cnam)
  : Rfd(cnam)
{
  fFd = ::eventfd(0,0);                    // ini value = 0; no flags
  if (fFd < 0) 
    throw Rexception(fCnam+"ctor", "eventfd() failed: ", errno);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void ReventFd::Signal(uint64_t val)
{
  int irc = ::write(fFd, &val, sizeof(val));
  if (irc < 0) {
    throw Rexception(fCnam+"Signal()", "write() failed: ", errno);
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

uint64_t ReventFd::Wait()
{
  uint64_t buf;
  int irc = ::read(fFd, &buf, sizeof(buf));
  if (irc < 0) {
    if (errno == EAGAIN) return 0;
    throw Rexception(fCnam+"Wait()", "read() failed: ", errno);
  }
  return buf;  
}

} // end namespace Retro
