// $Id: Rtime.cpp 887 2017-04-28 19:32:52Z mueller $
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
// 2017-02-20   854   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of Rtime .
*/
// Note on double conversion precision:
//   double has 52 bits mantissa --> 52*log10(2) = 15.6 dig or ~4.e15 res
//   --> up to ~4.e6sec or ~ 46days we have 1nsec resolution
//   for realclock time stamps: t = ~1.5e9 --> 1/2600000 res --> better 1usec

#include <errno.h>

#include <sstream>

#include "RosFill.hpp"
#include "RosPrintf.hpp"
#include "Rexception.hpp"

#include "Rtime.hpp"

using namespace std;

/*!
  \class Retro::Rtime
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rtime::GetClock(clockid_t clkid)
{
  if (::clock_gettime(clkid, &fTime) != 0) {
    throw Rexception("Rtime::GetClock()", "clock_gettime() failed: ", errno);
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rtime::SetNSec(long nsec)
{
  if (nsec < 0 || nsec > 999999999)
    throw Rexception("Rtime::SetNSec()", "bad args: <0 or >999999999 ");
  fTime.tv_nsec = nsec;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string Rtime::ToString() const
{
  ostringstream sos;
  Print(sos);
  return sos.str();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

double Rtime::Age(clockid_t clkid) const
{
  if (IsZero()) return 0.;
  Rtime now(clkid);
  return double(now - *this);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rtime::Print(std::ostream& os) const
{
  if (fTime.tv_sec < 365*24*3600) {         // looks like dt (<1year)
    os <<  RosPrintf(ToDouble(),"f",18,9);
  } else {
    struct tm tymd;
    ::localtime_r(&fTime.tv_sec, &tymd);
    os << RosPrintf(tymd.tm_year+1900,"d",4) << "-" 
       << RosPrintf(tymd.tm_mon+1,"d0",2) << "-" 
       << RosPrintf(tymd.tm_mday,"d0",2) << " " 
       << RosPrintf(tymd.tm_hour,"d0",2) << ":" 
       << RosPrintf(tymd.tm_min,"d0",2) << ":" 
       << RosPrintf(tymd.tm_sec,"d0",2) << "." 
       << RosPrintf(fTime.tv_nsec,"d0",9);
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rtime::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rtime @ " << this << endl;
  os << bl << "  fTime: " << RosPrintf(fTime.tv_sec,"d",10) 
     << "," << RosPrintf(fTime.tv_nsec,"d",9)
     << " : " << ToString() << endl;
  return;
}


} // end namespace Retro
