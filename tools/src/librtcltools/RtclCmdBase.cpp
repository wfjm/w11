// $Id: RtclCmdBase.cpp 887 2017-04-28 19:32:52Z mueller $
//
// Copyright 2011-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-02   865   1.1.1  add GetArgsDump()
// 2017-04-02   863   1.1    add DelMeth(),TstMeth(); add M_info() and '?'
//                           rename fMapMeth -> fMethMap
// 2017-03-11   859   1.1    support now sub-command handling
// 2014-08-22   584   1.0.3  use nullptr
// 2013-02-10   485   1.0.2  add static const defs
// 2013-02-05   483   1.0.1  remove 'unknown specified, full match only' logic
// 2013-02-02   480   1.0    Initial version (refactored out from ProxyBase)
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclCmdBase.
*/

#include "RtclCmdBase.hpp"

#include "librtools/Rexception.hpp"
#include "librtcltools/RtclNameSet.hpp"

#include "Rtcl.hpp"
#include "RtclOPtr.hpp"

using namespace std;

/*!
  \class Retro::RtclCmdBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const int RtclCmdBase::kOK;
const int RtclCmdBase::kERR;

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclCmdBase::RtclCmdBase()
  : fMethMap()
{}

//------------------------------------------+-----------------------------------
//! Destructor

RtclCmdBase::~RtclCmdBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclCmdBase::DispatchCmd(RtclArgs& args)
{
  mmap_cit_t it_match;

  Tcl_Interp* interp = args.Interp();

  if (size_t(args.Objc()) == args.NDone()) {// no args left -> no method name
    it_match = fMethMap.find("$default");   // default method registered ?
    if (it_match != fMethMap.end()) {
      return (it_match->second)(args);
    }
    // or fail
    Tcl_WrongNumArgs(interp, args.NDone(), args.Objv(), "option ?args?");
    return kERR;
  }
  
  string name;
  args.GetArg("cmd", name);                 // will always succeed
  it_match = fMethMap.lower_bound(name);

  // handle '?'
  if (name == "?") return M_info(args);
    
  // no leading substring match
  if (it_match==fMethMap.end() || 
      name!=it_match->first.substr(0,name.length())) {

    mmap_cit_t it_un = fMethMap.find("$unknown"); // unknown method registered ?
    if (it_un!=fMethMap.end()) {
      return (it_un->second)(args);
    }
    
    Tcl_AppendResult(interp, "-E: bad option '", name.c_str(),
                     "': must be ", nullptr);
    const char* delim = "";
    for (const auto& kv : fMethMap) {
      if (kv.first.c_str()[0] != '$') {
        Tcl_AppendResult(interp, delim, kv.first.c_str(), nullptr);
        delim = ",";
      }        
    }
    return kERR;
  }
    
  // check for ambiguous substring match
  if (name != it_match->first) {
    mmap_cit_t it1 = it_match;
    it1++;
    if (it1!=fMethMap.end() && name==it1->first.substr(0,name.length())) {
      Tcl_AppendResult(interp, "-E: ambiguous option '", 
                       name.c_str(), "': must be ", nullptr);
      const char* delim = "";
      for (it1=it_match; it1!=fMethMap.end() &&
             name==it1->first.substr(0,name.length()); it1++) {
        Tcl_AppendResult(interp, delim, it1->first.c_str(), nullptr);
        delim = ",";
      }
      return kERR;
    }
  }
  
  return (it_match->second)(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclCmdBase::AddMeth(const std::string& name, const methfo_t& methfo)
{
  auto ret = fMethMap.emplace(name, methfo);
  if (ret.second == false)                  // or use !(ret.second)
    throw Rexception("RtclCmdBase::AddMeth:", 
                     string("Bad args: duplicate name: '") + name + "'");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclCmdBase::DelMeth(const std::string& name)
{
  if (fMethMap.erase(name) == 0)            // balk if not existing
    throw Rexception("RtclCmdBase::DelMeth:", 
                     string("Bad args: non-existing name: '") + name + "'");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclCmdBase::TstMeth(const std::string& name)
{
  return fMethMap.find(name) != fMethMap.end();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclCmdBase::GetArgsDump(RtclArgs& args, int& detail)
{
  static RtclNameSet optset("-brief|-v|-vv|-vvv");
  detail = 0;
  string opt;

  while (args.NextOpt(opt, optset)) {
    if      (opt == "-brief") { detail = -1;}
    else if (opt == "-v")     { detail = +1;}
    else if (opt == "-vv")    { detail = +2;}
    else if (opt == "-vvv")   { detail = +3;}
    else                      { detail =  0;}
  }
  
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclCmdBase::M_info(RtclArgs& args)
{
  Tcl_Interp* interp = args.Interp();
  string cname("");
  if (!args.GetArg("??cname", cname)) return TCL_ERROR;
  if (!args.AllDone()) return TCL_ERROR;

  RtclOPtr rlist(Tcl_NewListObj(0,nullptr));
  if (cname == "") {                        // no name --> return all
    for (const auto& kv : fMethMap) {
      if (kv.first[0] == '$') continue;     // skip $nnn internals
      RtclOPtr pele(Tcl_NewStringObj(kv.first.c_str(), -1));
      Tcl_ListObjAppendElement(nullptr, rlist, pele);
    }
  
  } else {                                  // name seen --> return matches
    auto it_match = fMethMap.lower_bound(cname);
    for (auto it=it_match; it!=fMethMap.end() &&
           cname==it->first.substr(0,cname.length()); it++) {
      RtclOPtr pele(Tcl_NewStringObj(it->first.c_str(), -1));
      Tcl_ListObjAppendElement(nullptr, rlist, pele);
    }
  }

  Tcl_SetObjResult(interp, rlist);
  return TCL_OK;
}

} // end namespace Retro
