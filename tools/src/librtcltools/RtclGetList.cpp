// $Id: RtclGetList.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-01  1076   1.2    use unique_ptr
// 2018-11-16  1070   1.1.1  use auto; use emplace,make_pair; use range loop
// 2015-01-08   631   1.1    add Clear(), add '?' (key list) and '*' (kv list)
// 2014-08-22   584   1.0.1  use nullptr
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of class RtclGetList.
*/

#include <iostream>

#include "librtools/Rexception.hpp"

#include "RtclGet.hpp"
#include "RtclGetList.hpp"
#include "RtclOPtr.hpp"

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
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclGetList::Add(const std::string& name, get_uptr_t&& upget)
{
  auto ret = fMap.emplace(make_pair(name, move(upget)));
  if (ret.second == false) 
     throw Rexception("RtclGetList::Add:", 
                      string("Bad args: duplicate name: '") + name + "'");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclGetList::Clear()
{
  fMap.clear();
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclGetList::M_get(RtclArgs& args)
{
  Tcl_Interp* interp = args.Interp();
  string pname("*");
  if (!args.GetArg("??pname", pname)) return TCL_ERROR;
  if (!args.AllDone()) return TCL_ERROR;

  if (pname == "?") {
    RtclOPtr rlist(Tcl_NewListObj(0,nullptr));
    for (const auto& kv : fMap) {
      RtclOPtr pele(Tcl_NewStringObj(kv.first.c_str(), -1));
      Tcl_ListObjAppendElement(nullptr, rlist, pele);
    }
    Tcl_SetObjResult(interp, rlist);
    return TCL_OK;

  } else if (pname == "*") {
    RtclOPtr rlist(Tcl_NewListObj(0,nullptr));
    for (const auto& kv : fMap) {
      RtclOPtr pele(Tcl_NewStringObj(kv.first.c_str(), -1));
      Tcl_ListObjAppendElement(nullptr, rlist, pele);
      Tcl_ListObjAppendElement(nullptr, rlist, kv.second->operator()());
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

  args.SetResult((it->second)->operator()());
  return TCL_OK;
}

} // end namespace Retro
