// $Id: Rtools.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-18  1089   1.0.9  use c++ style casts
// 2018-10-26  1059   1.0.8  add Catch2Cerr()
// 2017-02-18   852   1.0.7  remove TimeOfDayAsDouble()
// 2014-11-23   606   1.0.6  add TimeOfDayAsDouble()
// 2014-11-08   602   1.0.5  add (int) cast in snprintf to match %d type
// 2014-08-22   584   1.0.4  use nullptr
// 2013-05-04   516   1.0.3  add CreateBackupFile()
// 2013-02-13   481   1.0.2  remove Throw(Logic|Runtime)(); use Rexception
// 2011-04-10   376   1.0.1  add ThrowLogic(), ThrowRuntime()
// 2011-03-12   368   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rtools .
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#include <iostream>
#include <vector>

#include "Rexception.hpp"

#include "Rtools.hpp"

using namespace std;

/*!
  \namespace Retro::Rtools
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {
namespace Rtools {

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string Flags2String(uint32_t flags, const RflagName* fnam, char delim)
{
  if (fnam == nullptr)
    throw Rexception("Rtools::Flags2String()","Bad args: fnam==nullptr");

  string rval;
  while (fnam->mask) {
    if (flags & fnam->mask) {
      if (!rval.empty()) rval += delim;
      rval += fnam->name;
    }
    fnam++;
  }
  return rval;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool String2Long(const std::string& str, long& res, RerrMsg& emsg, int base)
{
  char* endptr;
  res = ::strtol(str.c_str(), &endptr, base);
  if (*endptr == 0) return true;

  emsg.Init("Rtools::String2Long", 
            string("conversion error in '") + str +"'");
  res = 0;
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool String2Long(const std::string& str, unsigned long& res,
                 RerrMsg& emsg, int base)
{
  char* endptr;
  res = ::strtoul(str.c_str(), &endptr, base);
  if (*endptr == 0) return true;

  emsg.Init("Rtools::String2Long", 
            string("conversion error in '") + str +"'");
  res = 0;
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool CreateBackupFile(const std::string& fname, size_t nbackup, RerrMsg& emsg)
{
  if (nbackup == 0) return true;
  
  size_t dotpos = fname.find_last_of('.');
  string fbase = fname.substr(0,dotpos);
  string fext  = fname.substr(dotpos);
  
  if (nbackup > 99) {
    emsg.Init("Rtools::CreateBackupFile", 
              "only up to 99 backup levels supported");
    return false;
  }
  
  vector<string> fnames;
  fnames.push_back(fname);
  for (size_t i=1; i<=nbackup; i++) {
    char fnum[4];
    ::snprintf(fnum, sizeof(fnum), "%d", int(i));
    fnames.push_back(fbase + "_" + fnum + fext);
  }
  
  for (size_t i=nbackup; i>0; i--) {
    string fnam_new = fnames[i];
    string fnam_old = fnames[i-1];

    struct stat sbuf;
    int irc = ::stat(fnam_old.c_str(), &sbuf);
    if (irc < 0) {
      if (errno == ENOENT) continue;
      emsg.InitErrno("Rtools::CreateBackupFile", 
                     string("stat() for '") + fnam_old + "'failed: ", errno);
      return false;
    }
    if (S_ISREG(sbuf.st_mode) == 0) {
      emsg.Init("Rtools::CreateBackupFile", 
                "backups only supported for regular files");
      return false;
    }
    // here we know old file exists and is a regular file
    /* coverity[toctou] */
    irc = ::rename(fnam_old.c_str(), fnam_new.c_str());
    if (irc < 0) {
      emsg.InitErrno("Rtools::CreateBackupFile", 
                     string("rename() for '") + fnam_old + "' -> '" +
                     fnam_new + "'failed: ", errno);
      return false;
    }
  }

  return true;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

bool CreateBackupFile(const RparseUrl& purl, RerrMsg& emsg)
{
  string bck;
  if (!purl.FindOpt("app") && purl.FindOpt("bck", bck)) {
    unsigned long nbck;
    if (!Rtools::String2Long(bck, nbck, emsg)) return false;
    if (nbck > 0) {
      if (!Rtools::CreateBackupFile(purl.Path(), nbck, emsg)) return false;
    }
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Catch2Cerr(const char* msg, std::function<void()> func)
{
  try {
    func();
  } catch (Rexception& e) {
    cerr << "Catch2Cerr-E: exception '" << e.ErrMsg().Text()
         << "' thrown in " << e.ErrMsg().Meth()
         << " caught and dropped in " << msg << endl;
   } catch (exception& e) {
    cerr << "Catch2Cerr-E: exception '" << e.what()
         << "' caught and dropped in " << msg << endl;
  } catch(...) {
    cerr << "Catch2Cerr-E: non std::exception"
         << " caught and dropped in " << msg << endl;
  }
  return;
}

} // end namespace Rtools
} // end namespace Retro
