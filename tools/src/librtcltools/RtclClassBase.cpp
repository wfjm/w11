// $Id: RtclClassBase.cpp 374 2011-03-27 17:02:47Z mueller $
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
  \version $Id: RtclClassBase.cpp 374 2011-03-27 17:02:47Z mueller $
  \brief   Implemenation of RtclClassBase.
*/

#include <string.h>

#include <stdexcept>

#include "RtclClassBase.hpp"
#include "RtclContext.hpp"
#include "RtclOPtr.hpp"
#include "Rtcl.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::RtclClassBase
  \brief FIXME_docs
*/

//------------------------------------------+-----------------------------------
//! Default constructor

RtclClassBase::RtclClassBase(const std::string& type)
  : fType(type),
    fInterp(0)
{}

//------------------------------------------+-----------------------------------
//! Destructor

RtclClassBase::~RtclClassBase()
{
  if (fInterp) RtclContext::Find(fInterp).UnRegisterClass(this);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclClassBase::CreateClassCmd(Tcl_Interp* interp, const char* name)
{
  fInterp = interp;
  fCmdToken = 
    Tcl_CreateObjCommand(interp, name, ThunkTclClassCmd, (ClientData) this, 
                         (Tcl_CmdDeleteProc *) ThunkTclCmdDeleteProc);
  RtclContext::Find(interp).RegisterClass(this);
  Tcl_CreateExitHandler((Tcl_ExitProc*) ThunkTclExitProc, (ClientData) this);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int RtclClassBase::TclClassCmd(Tcl_Interp* interp, int objc, 
                                      Tcl_Obj* const objv[])
{
  if (objc == 1) {
    return ClassCmdList(interp);
  }

  const char* name = Tcl_GetString(objv[1]);
  if (objc == 3 && strcmp(Tcl_GetString(objv[2]), "-delete")==0) {
    return ClassCmdDelete(interp, name);
  }
  
  return ClassCmdCreate(interp, objc, objv);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int RtclClassBase::ClassCmdList(Tcl_Interp* interp)
{
  std::vector<RtclProxyBase*> list;
  RtclContext::Find(interp).ListProxy(list, Type());
  RtclOPtr rlist(Tcl_NewListObj(0, NULL));

  for (size_t i=0; i<list.size(); i++) {
    const char* cmdname = Tcl_GetCommandName(interp, list[i]->Token());
    RtclOPtr rval(Tcl_NewStringObj(cmdname, -1));
    if (Tcl_ListObjAppendElement(interp, rlist, rval) != kOK) return kERR;
  }
  
  Tcl_SetObjResult(interp, rlist);

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int RtclClassBase::ClassCmdDelete(Tcl_Interp* interp, const char* name)
{
  Tcl_CmdInfo cinfo;
  if (Tcl_GetCommandInfo(interp, name, &cinfo) == 0) {
    Tcl_AppendResult(interp, "-E: unknown command name \"", name, "\"", NULL);
    return kERR;
  }
  
  RtclContext& cntx = RtclContext::Find(interp);
  if (!cntx.CheckProxy((RtclProxyBase*) cinfo.objClientData)) {
    Tcl_AppendResult(interp, "-E: command \"", name, "\" is not a RtclProxy", 
                     NULL);
    return kERR;
  }
  if (!cntx.CheckProxy((RtclProxyBase*) cinfo.objClientData, Type())) {
    Tcl_AppendResult(interp, "-E: command \"", name, 
                     "\" is not a RtclProxy of type \"", 
                     Type().c_str(), "\"", NULL);
    return kERR;
  }

  int irc = Tcl_DeleteCommand(interp, name);
  if (irc != kOK) Tcl_AppendResult(interp, "-E: failed to delete \"", name, 
                                   "\"", NULL);
  return irc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclClassBase::ThunkTclClassCmd(ClientData cdata, Tcl_Interp* interp, 
                                    int objc, Tcl_Obj* const objv[])
{
  if (!cdata) {
    Tcl_AppendResult(interp, "-E: BUG! ThunkTclClassCmd called with cdata == 0",
                     NULL);
    return kERR;
  }
  
  try {
    return ((RtclClassBase*) cdata)->TclClassCmd(interp, objc, objv);
  } catch (exception& e) {
    Rtcl::AppendResultNewLines(interp);
    Tcl_AppendResult(interp, "-E: exception caught in ThunkTclClassCmd: \"", 
                     e.what(), "\"", NULL);
  }
  return kERR;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclClassBase::ThunkTclCmdDeleteProc(ClientData cdata)
{
  Tcl_DeleteExitHandler((Tcl_ExitProc*) ThunkTclExitProc, cdata);
  delete ((RtclClassBase*) cdata);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclClassBase::ThunkTclExitProc(ClientData cdata)
{
  delete ((RtclClassBase*) cdata);
  return;
}

//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_RtclClassBase_NoInline))
#define inline
#include "RtclClassBase.ipp"
#undef  inline
#endif
