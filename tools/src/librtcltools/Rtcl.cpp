// $Id: Rtcl.cpp 369 2011-03-13 22:39:26Z mueller $
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
// 2011-03-13   369   1.0.2  add NewListIntObj(vector<uint8_t>)
// 2011-03-05   366   1.0.1  add AppendResultNewLines()
// 2011-02-26   364   1.0    Initial version
// 2011-02-13   361   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rtcl.cpp 369 2011-03-13 22:39:26Z mueller $
  \brief   Implemenation of Rtcl.
*/

#include "Rtcl.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::Rtcl
  \brief FIXME_docs
*/

//------------------------------------------+-----------------------------------
//! FIXME_docs

Tcl_Obj* Rtcl::NewLinesObj(const std::string& str)
{
  const char* data = str.data();
  int size         = str.length();
  if (size>0 && data[size-1]=='\n') size -= 1;
  return Tcl_NewStringObj(data, size);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Tcl_Obj* Rtcl::NewListIntObj(const std::vector<uint8_t>& vec)
{
  if (vec.size() == 0) return Tcl_NewListObj(0, NULL);
  
  vector<Tcl_Obj*> vobj;
  vobj.reserve(vec.size());
  
  for (size_t i=0; i<vec.size(); i++) {
    vobj.push_back(Tcl_NewIntObj((int)vec[i]));
  }
  return Tcl_NewListObj(vobj.size(), vobj.data());
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Tcl_Obj* Rtcl::NewListIntObj(const std::vector<uint16_t>& vec)
{
  if (vec.size() == 0) return Tcl_NewListObj(0, NULL);
  
  vector<Tcl_Obj*> vobj;
  vobj.reserve(vec.size());
  
  for (size_t i=0; i<vec.size(); i++) {
    vobj.push_back(Tcl_NewIntObj((int)vec[i]));
  }
  return Tcl_NewListObj(vobj.size(), vobj.data());
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rtcl::SetVar(Tcl_Interp* interp, const std::string& varname, Tcl_Obj* pobj)
{
  Tcl_Obj* pret = 0;
  
  size_t pos_pbeg = varname.find_first_of('(');
  size_t pos_pend = varname.find_first_of(')');
  if (pos_pbeg != string::npos || pos_pend != string::npos) {
    if (pos_pbeg == string::npos || pos_pbeg == 0 ||  
        pos_pend == string::npos || pos_pend != varname.length()-1 ||
        pos_pend-pos_pbeg <= 1) {
      Tcl_AppendResult(interp, "illformed array name \"", varname.c_str(), 
                       "\"", NULL);
      return false;
    }
    string arrname(varname.substr(0,pos_pbeg));
    string elename(varname.substr(pos_pbeg+1, pos_pend-pos_pbeg-1));
    
    pret = Tcl_SetVar2Ex(interp, arrname.c_str(), elename.c_str(), pobj, 
                         TCL_LEAVE_ERR_MSG);
  } else {
    pret = Tcl_SetVar2Ex(interp, varname.c_str(), NULL, pobj, 
                         TCL_LEAVE_ERR_MSG);
  }

  return pret!=0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rtcl::SetVarOrResult(Tcl_Interp* interp, const std::string& varname, 
                          Tcl_Obj* pobj)
{
  if (varname != "-") {
    return SetVar(interp, varname, pobj);
  }
  Tcl_SetObjResult(interp, pobj);
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rtcl::AppendResultNewLines(Tcl_Interp* interp)
{
  // check whether ObjResult is non-empty, in that case add an '\n'
  // that allows to append output from multiple AppendResultLines properly
  const char* res =  Tcl_GetStringResult(interp);
  if (res && res[0]) {
    Tcl_AppendResult(interp, "\n", NULL);
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rtcl::SetResult(Tcl_Interp* interp, const std::string& str)
{
  Tcl_SetObjResult(interp, NewLinesObj(str));
  return;
}

//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_Rtcl_NoInline))
#define inline
#include "Rtcl.ipp"
#undef  inline
#endif
