// $Id: RethBuf.cpp 881 2017-04-17 18:52:26Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-16   880   1.0    Initial version
// 2017-02-12   850   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RethBuf.cpp 881 2017-04-17 18:52:26Z mueller $
  \brief   Implemenation of RethBuf.
*/

#include <stdlib.h>
#include <unistd.h>

#include <arpa/inet.h>

#include <sstream>

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"

#include "RethBuf.hpp"
#include "RethTools.hpp"

using namespace std;

/*!
  \class Retro::RethBuf
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions
const size_t RethBuf::kMaxSize;
const size_t RethBuf::kMinSize;
const size_t RethBuf::kCrcSize;
const size_t RethBuf::kWOffDstMac;
const size_t RethBuf::kWOffSrcMac;
const size_t RethBuf::kWOffTyp;

//------------------------------------------+-----------------------------------
//! Default constructor
RethBuf::RethBuf()
  : fTime(),
    fSize(0)
{}

//------------------------------------------+-----------------------------------
//! Destructor
RethBuf::~RethBuf()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

uint16_t RethBuf::Type() const
{
  return ntohs(Buf16()[kWOffTyp]);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

ssize_t RethBuf::Read(int fd)
{
  ssize_t irc = ::read(fd, fBuf, kMaxSize);
  fSize = (irc > 0) ? irc : 0;
  return irc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

ssize_t RethBuf::Write(int fd) const
{
  return ::write(fd, fBuf, fSize);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string RethBuf::FrameInfo() const
{
  std::ostringstream sos;
  sos << RethTools::Mac2String(MacSource())
      << " > " << RethTools::Mac2String(MacDestination())
      << " typ: " << RosPrintBvi(Type(),16)
      << " siz: " << RosPrintf(Size(),"d",4);
  return sos.str();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RethBuf::Dump(std::ostream& os, int ind, const char* text,
                   int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RethBuf @ " << this << endl;
  os << bl << "  fTime: " << fTime << endl;
  os << bl << "  fBuf:  " << FrameInfo() << endl;

  if (detail < 0) return;                   // detail<0 --> info only

  int ibeg  = 0;
  int imax  = int(Size())-1;
  for (int iline=0; ; iline++) {
    if (ibeg > imax) break;
    if (detail <= 0 && iline >= 6) break;   // detail>1 --> full buffer
    int iend  = ibeg + 15;
    int igap  = 0;
    if (iend > imax) {
      igap = iend - imax;
      iend = imax;
    }
    os << bl << "    " << RosPrintf(ibeg,"x0", 4) << ":";
    // print hex
    for (int i=ibeg; i<=iend; i++) os << " " << RosPrintf(Buf8()[i],"x0", 2);
    for (int i=0;    i<igap;  i++) os << "   ";
    // print ascii
    os << "  ";
    for (int i=ibeg; i<=iend; i++) {
      char c = char(Buf8()[i]);
      if (c < 0x20 || c >= 0x7F) c = '.';
      os << RosPrintf(char(c),"c");
    }
    os << endl;
    ibeg += 16;
  }
  
  return;
}

} // end namespace Retro
