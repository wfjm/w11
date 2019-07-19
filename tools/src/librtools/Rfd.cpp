// $Id: Rfd.cpp 1185 2019-07-12 17:29:12Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-15  1163   1.0.1  SetFd() now type bool
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

bool Rfd::SetFd(int fd)
{
  if (IsOpen())
    throw Rexception(fCnam+"Open()", "bad state: already open");
  fFd = fd;
  return IsOpen();
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
