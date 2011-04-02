// $Id: RlogFile.cpp 365 2011-02-28 07:28:26Z mueller $
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
// 2011-01-30   357   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlogFile.cpp 365 2011-02-28 07:28:26Z mueller $
  \brief   Implemenation of RlogFile.
*/

#include <sys/time.h>

#include "RlogFile.hpp"
#include "RosPrintf.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::RlogFile
  \brief FIXME_docs
*/

//------------------------------------------+-----------------------------------
//! Default constructor

RlogFile::RlogFile()
  : fpExtStream(0),
    fIntStream()
{
  ClearTime();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlogFile::RlogFile(std::ostream* os)
  : fpExtStream(os),
    fIntStream()
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlogFile::~RlogFile()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlogFile::Open(std::string name)
{
  fpExtStream = 0;
  fIntStream.open(name.c_str());
  return fIntStream.is_open();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlogFile::Close()
{
  fIntStream.close();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlogFile::UseStream(std::ostream* os)
{
  if (fIntStream.is_open()) Close();
  fpExtStream = os;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::ostream& RlogFile::operator()(char c)
{
  struct timeval tval;
  gettimeofday(&tval, 0);

  struct tm tymd;
  localtime_r(&tval.tv_sec, &tymd);

  ostream& os = operator()();
  
  if (tymd.tm_year != fTagYear  ||
      tymd.tm_mon  != fTagMonth ||
      tymd.tm_mday != fTagDay) {

    os << "-+- " 
       << RosPrintf(tymd.tm_year+1900,"d",4) << "-"
       << RosPrintf(tymd.tm_mon,"d0",2) << "-"
       << RosPrintf(tymd.tm_mday,"d0",2) << " -+- \n";

    fTagYear  = tymd.tm_year;
    fTagMonth = tymd.tm_mon;
    fTagDay   = tymd.tm_mday;
  }

  int usec = (int)(tval.tv_usec/1000);

  os << "-" << c << "- "
     << RosPrintf(tymd.tm_hour,"d0",2) << ":"
     << RosPrintf(tymd.tm_min,"d0",2) << ":"
     << RosPrintf(tymd.tm_sec,"d0",2) << "."
     << RosPrintf(usec,"d0",3) << " : ";

  return os;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlogFile::ClearTime()
{
  fTagYear  = -1;
  fTagMonth = -1;
  fTagDay   = -1;
  return;
}

//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_RlogFile_NoInline))
#define inline
#include "RlogFile.ipp"
#undef  inline
#endif
