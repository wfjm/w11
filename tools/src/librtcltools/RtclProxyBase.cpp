// $Id: RtclProxyBase.cpp 374 2011-03-27 17:02:47Z mueller $
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
// 2011-03-05   366   1.0.1  use AppendResultNewLines() in exception catcher
// 2011-02-20   363   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclProxyBase.cpp 374 2011-03-27 17:02:47Z mueller $
  \brief   Implemenation of RtclProxyBase.
*/

#include <stdexcept>

#include "RtclProxyBase.hpp"
#include "RtclContext.hpp"
#include "Rtcl.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::RtclProxyBase
  \brief FIXME_docs
*/

typedef std::pair<Retro::RtclProxyBase::mmap_it_t, bool>  mmap_ins_t;

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclProxyBase::RtclProxyBase(const std::string& type)
  : fType(type),
    fMapMeth(),
    fInterp(0)
{}

//------------------------------------------+-----------------------------------
//! Destructor

RtclProxyBase::~RtclProxyBase()
{
  if (fInterp) RtclContext::Find(fInterp).UnRegisterProxy(this);
  for (mmap_it_t it=fMapMeth.begin(); it!=fMapMeth.end(); it++) {
    delete it->second;
  }
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclProxyBase::ClassCmdConfig(Tcl_Interp* interp, int objc,
                                  Tcl_Obj* const objv[])
{
  if (objc > 2) {
    Tcl_AppendResult(interp, "-E: no configuration args supported", NULL);
    return TCL_ERROR;
  }
  return TCL_OK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclProxyBase::AddMeth(const std::string& name, 
                            RmethDscBase<RtclArgs>* pmeth)
{
  mmap_ins_t ret = fMapMeth.insert(mmap_val_t(name, pmeth));
  if (ret.second == false)                  // or use !(ret.second)
    throw logic_error(string("RtclProxyBase::AddMeth: duplicate name: ") + 
                      name);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclProxyBase::CreateObjectCmd(Tcl_Interp* interp, const char* name)
{
  fInterp = interp;
  fCmdToken = 
    Tcl_CreateObjCommand(interp, name, ThunkTclObjectCmd, (ClientData) this, 
                         (Tcl_CmdDeleteProc *) ThunkTclCmdDeleteProc);
  RtclContext::Find(interp).RegisterProxy(this);
  Tcl_CreateExitHandler((Tcl_ExitProc*) ThunkTclExitProc, (ClientData) this);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclProxyBase::TclObjectCmd(Tcl_Interp* interp, int objc, 
                                Tcl_Obj* const objv[])
{
  mdsc_t* pmdsc = 0;

  if (objc == 1) {                             // no args
    mmap_cit_t it = fMapMeth.find("$default"); // default method registered ?
    if (it == fMapMeth.end()) {                // if not, complain
      Tcl_WrongNumArgs(interp, 1, objv, "option ?args?");
      return TCL_ERROR;
    }
    pmdsc = it->second;

  } else {                                     // at least method name given 
    string name(Tcl_GetString(objv[1]));
    mmap_cit_t it = fMapMeth.lower_bound(name);
    
    // no leading substring match
    if (it==fMapMeth.end() || name!=it->first.substr(0,name.length())) {
      Tcl_AppendResult(interp, "-E: bad option \"", Tcl_GetString(objv[1]),
                       "\": must be ", NULL);
      const char* delim = "";
      for (mmap_cit_t it1=fMapMeth.begin(); it1!=fMapMeth.end(); it1++) {
        if (it1->first.c_str()[0] != '$') {
          Tcl_AppendResult(interp, delim, it1->first.c_str(), NULL);
          delim = ",";
        }        
      }
      return TCL_ERROR;
    }
    
    pmdsc = it->second;
    
    // check for ambiguous substring match
    if (name != it->first) {
      mmap_cit_t it1 = it;
      it1++;
      if (it1!=fMapMeth.end() && name==it1->first.substr(0,name.length())) {
        Tcl_AppendResult(interp, "-E: ambiguous option \"", 
                         Tcl_GetString(objv[1]), "\": must be ", NULL);
        const char* delim = "";
        for (it1=it; it1!=fMapMeth.end() &&
               name==it1->first.substr(0,name.length()); it1++) {
          Tcl_AppendResult(interp, delim, it1->first.c_str(), NULL);
          delim = ",";
        }
        return TCL_ERROR;
      }
    }
  }
  
  RtclArgs  args(interp, objc, objv, 2);
  return (*pmdsc)(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclProxyBase::ThunkTclObjectCmd(ClientData cdata, Tcl_Interp* interp, 
                                     int objc, Tcl_Obj* const objv[])
{
  if (!cdata) {
    Tcl_AppendResult(interp, "-E: BUG! ThunkTclObjectCmd called with cdata==0",
                     NULL);
    return TCL_ERROR;
  }
  
  try {
    return ((RtclProxyBase*) cdata)->TclObjectCmd(interp, objc, objv);
  } catch (exception& e) {
    Rtcl::AppendResultNewLines(interp);
    Tcl_AppendResult(interp, "-E: exception caught \"", e.what(), "\"", NULL);
  }
  return TCL_ERROR;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclProxyBase::ThunkTclCmdDeleteProc(ClientData cdata)
{
  Tcl_DeleteExitHandler((Tcl_ExitProc*) ThunkTclExitProc, cdata);
  delete ((RtclProxyBase*) cdata);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclProxyBase::ThunkTclExitProc(ClientData cdata)
{
  delete ((RtclProxyBase*) cdata);
  return;
}

//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_RtclProxyBase_NoInline))
#define inline
#include "RtclProxyBase.ipp"
#undef  inline
#endif
