// $Id: RlinkPortFifo.cpp 375 2011-04-02 07:56:47Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-03-27   374   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPortFifo.cpp 375 2011-04-02 07:56:47Z mueller $
  \brief   Implemenation of RlinkPortFifo.
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

#include "RlinkPortFifo.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::RlinkPortFifo
  \brief FIXME_text
*/

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkPortFifo::RlinkPortFifo()
  : RlinkPort()
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkPortFifo::~RlinkPortFifo()
{}

//------------------------------------------+-----------------------------------
//! FIXME_text

bool RlinkPortFifo::Open(const std::string& url, RerrMsg& emsg)
{
  if (IsOpen()) Close();

  if (!ParseUrl(url, "|keep|", emsg)) return false;

  // Note: _rx fifo must be opened before the _tx fifo, otherwise the test
  //       bench might close with EOF on read prematurely (is a race condition).

  fFdWrite = OpenFifo(UrlPath() + "_rx", true, emsg);
  if (fFdWrite < 0) return false;
  
  fFdRead = OpenFifo(UrlPath() + "_tx", false, emsg);
  if (fFdRead < 0) {
    close(fFdWrite);
    fFdWrite = -1;
    return false;
  }

  fIsOpen  = true;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

int RlinkPortFifo::OpenFifo(const std::string& name, bool snd, RerrMsg& emsg)
{
  struct stat stat_fifo;

  int irc;
  
  irc = stat(name.c_str(), &stat_fifo);
  if (irc == 0) {
    if ((stat_fifo.st_mode & S_IFIFO) == 0) {
      emsg.Init("RlinkPortFifo::OpenFiFo()",
                string("\"") + name + string("\" exists but is not a pipe"));
      return -1;
    }
  } else {
    mode_t mode = S_IRUSR | S_IWUSR;        // user read and write allowed
    irc = mkfifo(name.c_str(), mode);
    if (irc != 0) {
      emsg.InitErrno("RlinkPortFifo::OpenFifo()", 
                     string("mkfifo() for \"") + name + string("\" failed: "),
                     errno);
      return -1;
    }    
  }

  irc = open(name.c_str(), snd ? O_WRONLY : O_RDONLY);
  if (irc < 0) {
    emsg.InitErrno("RlinkPortFifo::OpenFifo()", 
                   string("open() for \"") + name + string("\" failed: "),
                   errno);
    return -1;
  }

  return irc;
}

//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_RlinkPortFifo_NoInline))
#define inline
//#include "RlinkPortFifo.ipp"
#undef  inline
#endif
