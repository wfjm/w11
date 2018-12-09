// $Id: RtclSetList.cpp 1076 2018-12-02 12:45:49Z mueller $
//
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-01  1076   1.2    use unique_ptr
// 2018-11-16  1070   1.1.1  use auto; use emplace,make_pair; use range loop
// 2015-01-08   631   1.1    add Clear(), add '?' (key list)
// 2014-08-22   584   1.0.1  use nullptr
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of class RtclSetList.
*/

#include <iostream>

#include "librtools/Rexception.hpp"

#include "RtclSet.hpp"
#include "RtclSetList.hpp"
#include "RtclOPtr.hpp"

using namespace std;

/*!
  \class Retro::RtclSetList
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclSetList::RtclSetList()
  : fMap()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclSetList::~RtclSetList()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclSetList::Add(const std::string& name, set_uptr_t&& upset)
{
  auto ret = fMap.emplace(make_pair(name, move(upset)));
  if (ret.second == false) 
    throw Rexception("RtclSetList::Add:", 
                     string("Bad args: duplicate name: '") + name + "'");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclSetList::Clear()
{
  fMap.clear();
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclSetList::M_set(RtclArgs& args)
{
  Tcl_Interp* interp = args.Interp();
  string pname;
  if (!args.GetArg("pname", pname)) return TCL_ERROR;

  if (pname == "?") {
    if (!args.AllDone()) return TCL_ERROR;
    RtclOPtr rlist(Tcl_NewListObj(0,nullptr));
    for (const auto& kv : fMap) {
      RtclOPtr pele(Tcl_NewStringObj(kv.first.c_str(), -1));
      Tcl_ListObjAppendElement(nullptr, rlist, pele);
    }
    Tcl_SetObjResult(interp, rlist);
    return TCL_OK;
  }

  auto it = fMap.lower_bound(pname);

  // complain if not found
  if (it == fMap.end() || pname != it->first.substr(0,pname.length())) {
    Tcl_AppendResult(interp, "-E: unknown property '", pname.c_str(), 
                     "': must be ", nullptr);
    const char* delim = "";
    for (auto& o: fMap) {
      Tcl_AppendResult(interp, delim, o.first.c_str(), nullptr);
      delim = ",";
    }
    return TCL_ERROR;
  }

  // check for ambiguous substring match
  auto it1 = it;
  it1++;
  if (it1!=fMap.end() && pname==it1->first.substr(0,pname.length())) {
    Tcl_AppendResult(interp, "-E: ambiguous property name '", pname.c_str(),
                     "': must be ", nullptr);
    const char* delim = "";
    for (it1=it; it1!=fMap.end() &&
           pname==it1->first.substr(0,pname.length()); it1++) {
      Tcl_AppendResult(interp, delim, it1->first.c_str(), nullptr);
      delim = ",";
    }

    return TCL_ERROR;
  }

  Tcl_Obj* pobj;
  if (!args.GetArg("val", pobj)) return TCL_ERROR;
  if (!args.AllDone()) return TCL_ERROR;

  try {
    (it->second)->operator()(args);
  } catch (Rexception& e) {
    Tcl_AppendResult(args.Interp(), "-E: ", e.ErrMsg().Text().c_str(), nullptr);
    return TCL_ERROR;
  } catch (exception& e) {
    Tcl_AppendResult(args.Interp(), "-E: ", e.what(), nullptr);
    return TCL_ERROR;
  }
  
  return TCL_OK;
}

} // end namespace Retro
