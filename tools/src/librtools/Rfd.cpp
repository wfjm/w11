// $Id: Rfd.cpp 1161 2019-06-08 11:52:01Z mueller $
//
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-06-07  1161   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of class RtimerFd.
*/

#include <errno.h>
#include <unistd.h>

#include <iostream>

#include "Rfd.hpp"

#include "Rexception.hpp"

using namespace std;

/*!
  \class Retro::Rfd
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rfd::Rfd()
  : fFd(-1),
    fCnam("Rfd::")
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rfd::Rfd(Rfd&& rhs)
  : fFd(rhs.fFd),
    fCnam(move(rhs.fCnam))
{
  rhs.fFd = -1;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rfd::Rfd(const char* cnam)
  : fFd(-1),
    fCnam(cnam)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rfd::~Rfd()
{
  if (IsOpen()) CloseOrCerr();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rfd::SetFd(int fd)
{
  if (IsOpen())
    throw Rexception(fCnam+"Open()", "bad state: already open");
  fFd = fd;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rfd::Close()
{
  if (IsOpenNonStd()) {
    ::close(fFd);
    fFd = -1;
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rfd::Close(RerrMsg& emsg)
{
  if (!IsOpen()) {
    emsg.Init(fCnam+"Close()", "bad state: not open");
    return false;
  }
  if (!IsOpenNonStd()) {
    fFd = -1;
    return true;
  }
  
  int irc = ::close(fFd);
  fFd = -1;
  if (irc < 0) {
    emsg.InitErrno(fCnam+"Close()", "close() failed: ", errno);
    return false;
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rfd::CloseOrCerr()
{
  RerrMsg emsg;
  if (!Close(emsg)) cerr << emsg.Meth() << "-E: " << emsg.Text() << endl;
  return;
}

} // end namespace Retro
