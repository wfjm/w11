// $Id: RtclNameSet.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-11-16  1070   1.1.2  use auto; use range loop
// 2014-08-22   584   1.1.1  use nullptr
// 2013-05-19   521   1.1    add CheckMatch()
// 2013-02-03   481   1.0.1  use Rexception
// 2011-02-20   363   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclNameSet.
*/

// debug
#include <iostream>

#include "RtclNameSet.hpp"

#include "librtools/Rexception.hpp"

using namespace std;

/*!
  \class Retro::RtclNameSet
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RtclNameSet::RtclNameSet()
  : fSet()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclNameSet::RtclNameSet(const std::string& nset)
  : fSet()
{
  size_t ibeg=0;
  while (true) {
    size_t iend = nset.find_first_of('|', ibeg);
    if (iend-ibeg > 0) {
      string name(nset, ibeg, iend-ibeg);
      auto ret = fSet.insert(name);
        if (ret.second == false)                  // or use !(ret.second)
          throw Rexception("RtclNameSet::<ctor>", "Bad args: " +
                           string("duplicate name '") + name + 
                           "' in set '" + nset + "'");
    }
    if (iend == string::npos) break;
    ibeg = iend+1;
  }
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclNameSet::~RtclNameSet()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclNameSet::Check(Tcl_Interp* interp, std::string& rval,
                        const std::string& tval) const
{
  return CheckMatch(interp, rval, tval, true) > 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
//  irc = 1 -> match
//        0 -> ambiguous match  --> tcl err
//       -1 -> no match         --> tcl err if misserr

int RtclNameSet::CheckMatch(Tcl_Interp* interp, std::string& rval,
                            const std::string& tval, bool misserr) const
{
  rval.clear();
  auto it = fSet.lower_bound(tval);

  // no leading substring match
  if (it==fSet.end() || tval!=it->substr(0,tval.length())) {
    if (misserr) {
      Tcl_AppendResult(interp, "-E: bad option '", tval.c_str(),
                       "': must be ", nullptr);
      const char* delim = "";
      for (auto& o: fSet) {
        Tcl_AppendResult(interp, delim, o.c_str(), nullptr);
        delim = ",";
      }
    }
    return -1;
  }

  // check for ambiguous substring match
  if (tval != *it) {
    auto it1 = it;
    it1++;
    if (it1!=fSet.end() && tval==it1->substr(0,tval.length())) {
      Tcl_AppendResult(interp, "-E: ambiguous option '", tval.c_str(),
                       "': must be ", nullptr);
      const char* delim = "";
      for (it1=it; it1!=fSet.end() &&
             tval==it1->substr(0,tval.length()); it1++) {
        Tcl_AppendResult(interp, delim, it1->c_str(), nullptr);
        delim = ",";
      }
      return 0;
    }
  }
  
  rval = *it;  
  return 1;
}

} // end namespace Retro
