// $Id: RlogFile.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-19  1090   1.2.4  use RosPrintf(bool)
// 2018-12-18  1089   1.2.3  use c++ style casts
// 2018-12-17  1085   1.2.2  use std::lock_guard instead of boost
// 2017-03-04   858   2.2.1  use clock_gettime instead of gettimeofday
// 2015-01-08   631   2.2    Open(): now with RerrMsg and cout/cerr support
// 2014-12-10   611   2.1.2  timestamp now usec precision (was msec)
// 2013-10-11   539   2.1.1  fix date print (month was off by one)
// 2013-02-23   492   2.1    add Name(), keep log file name; add Dump()
// 2013-02-22   491   2.0    add Write(),IsNew(), RlogMsg iface; use lockable
// 2011-01-30   357   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RlogFile.
*/

#include <time.h>
#include <errno.h>

#include <iostream>
  
#include "RosFill.hpp"
#include "RosPrintf.hpp"
#include "RlogMsg.hpp"

#include "RlogFile.hpp"

using namespace std;

/*!
  \class Retro::RlogFile
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RlogFile::RlogFile()
  : fpExtStream(nullptr),
    fIntStream(),
    fNew(true),
    fName(),
    fMutex()
{
  ClearTime();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlogFile::RlogFile(std::ostream* os, const std::string& name)
  : fpExtStream(os),
    fIntStream(),
    fNew(false),
    fName(BuildinStreamName(os, name)),
    fMutex()
{
  ClearTime();
}

//------------------------------------------+-----------------------------------
//! Destructor

RlogFile::~RlogFile()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlogFile::Open(std::string name, RerrMsg& emsg)
{
  std::ostream* os = nullptr;
  if      (name == "<cout>" || name == "-") os = &cout;
  else if (name == "<cerr>") os = &cerr;
  else if (name == "<clog>") os = &clog;
  if (os) {
    UseStream(os);
    return true;
  }

  fNew = false;
  fpExtStream = nullptr;
  fName = name;
  fIntStream.open(name.c_str());
  if (!fIntStream.is_open()) 
    emsg.InitErrno("RlogFile::Open", 
                   string("open for '") + name + "' failed: ",
                   errno);
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

void RlogFile::UseStream(std::ostream* os, const std::string& name)
{
  fNew = false;
  if (fIntStream.is_open()) Close();
  fpExtStream = os;
  fName = BuildinStreamName(os, name);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlogFile::Write(const std::string& str, char tag)
{
  ostream& os = fpExtStream ? *fpExtStream : fIntStream;

  lock_guard<RlogFile> lock(*this);

  if (tag) {
    struct timespec ts;
    ::clock_gettime(CLOCK_REALTIME, &ts);

    struct tm tymd;
    ::localtime_r(&ts.tv_sec, &tymd);

    if (tymd.tm_year != fTagYear  ||
        tymd.tm_mon  != fTagMonth ||
        tymd.tm_mday != fTagDay) {

      os << "-+- " 
         << RosPrintf(tymd.tm_year+1900,"d",4) << "-"
         << RosPrintf(tymd.tm_mon+1,"d0",2) << "-"
         << RosPrintf(tymd.tm_mday,"d0",2) << " -+- \n";

      fTagYear  = tymd.tm_year;
      fTagMonth = tymd.tm_mon;
      fTagDay   = tymd.tm_mday;
    }

    os << "-" << tag << "- "
       << RosPrintf(tymd.tm_hour,"d0",2) << ":"
       << RosPrintf(tymd.tm_min,"d0",2) << ":"
       << RosPrintf(tymd.tm_sec,"d0",2) << "."
       << RosPrintf(int(ts.tv_nsec)/1000,"d0",6) << " : ";
  }

  os << str;
  if (str[str.length()-1] != '\n') os << endl;

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlogFile::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlogFile @ " << this << endl;
  os << bl << "  fpExtStream:     " << fpExtStream << endl;
  os << bl << "  fIntStream.isopen " << fIntStream.is_open() << endl;
  os << bl << "  fNew             " << RosPrintf(fNew) << endl;
  os << bl << "  fName            " << fName << endl;
  os << bl << "  fTagYr,Mo,Dy     " << fTagYear << ", " << fTagMonth
                                    << ", " << fTagDay << endl;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlogFile::lock()
{
  fMutex.lock();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlogFile::unlock()
{
  fMutex.unlock();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlogFile& RlogFile::operator<<(const RlogMsg& lmsg)
{
  string str = lmsg.String();
  if (str.length() > 0) Write(str, lmsg.Tag());
  return *this;
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
//! FIXME_docs

  std::string RlogFile::BuildinStreamName(std::ostream* os,
                                          const std::string& str)
{
  if (str.size())  return str;
  if (os == &cout) return string("<cout>");
  if (os == &cerr) return string("<cerr>");
  if (os == &clog) return string("<clog>");
  return string("<?stream?>");
}
  
} // end namespace Retro
