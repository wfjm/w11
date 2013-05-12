// $Id: RtclGetList.cpp 516 2013-05-05 21:24:52Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclGetList.cpp 516 2013-05-05 21:24:52Z mueller $
  \brief   Implemenation of class RtclGetList.
*/

#include <iostream>

#include "librtools/Rexception.hpp"

#include "RtclGet.hpp"
#include "RtclGetList.hpp"

using namespace std;

/*!
  \class Retro::RtclGetList
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclGetList::RtclGetList()
  : fMap()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclGetList::~RtclGetList()
{
  for (map_cit_t it=fMap.begin(); it != fMap.end(); it++) {
    delete (it->second);
  }
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclGetList::Add(const std::string& name, RtclGetBase* pget)
{
  typedef std::pair<Retro::RtclGetList::map_it_t, bool>  map_ins_t;
  map_ins_t ret = fMap.insert(map_val_t(name, pget));
  if (ret.second == false) 
     throw Rexception("RtclGetList::Add:", 
                      string("Bad args: duplicate name: '") + name + "'");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclGetList::M_get(RtclArgs& args)
{
  string pname;
  if (!args.GetArg("pname", pname)) return TCL_ERROR;

  Tcl_Interp* interp = args.Interp();
  map_cit_t it = fMap.lower_bound(pname);

  // complain if not found
  if (it == fMap.end() || pname != it->first.substr(0,pname.length())) {
    Tcl_AppendResult(interp, "-E: unknown property '", pname.c_str(), 
                     "': must be ", NULL);
    const char* delim = "";
    for (map_cit_t it1=fMap.begin(); it1!=fMap.end(); it1++) {
      Tcl_AppendResult(interp, delim, it1->first.c_str(), NULL);
      delim = ",";
    }
    return TCL_ERROR;
  }

  // check for ambiguous substring match
  map_cit_t it1 = it;
  it1++;
  if (it1!=fMap.end() && pname==it1->first.substr(0,pname.length())) {
    Tcl_AppendResult(interp, "-E: ambiguous property name '", pname.c_str(),
                     "': must be ", NULL);
    const char* delim = "";
    for (it1=it; it1!=fMap.end() &&
           pname==it1->first.substr(0,pname.length()); it1++) {
      Tcl_AppendResult(interp, delim, it1->first.c_str(), NULL);
      delim = ",";
    }

    return TCL_ERROR;
  }

  if (!args.AllDone()) return TCL_ERROR;

  args.SetResult((it->second)->operator()());
  return TCL_OK;
}

} // end namespace Retro
