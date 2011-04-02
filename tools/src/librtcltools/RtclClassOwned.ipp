// $Id: RtclClassOwned.ipp 365 2011-02-28 07:28:26Z mueller $
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
// 2011-02-20   363   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclClassOwned.ipp 365 2011-02-28 07:28:26Z mueller $
  \brief   Implemenation (inline) of class RtclClassOwned.
*/

#include <iostream>

#include "RtclProxyBase.hpp"

/*!
  \class Retro::RtclClassOwned
  \brief FIXME_docs
*/

// all method definitions in namespace Retro (avoid using in includes...)
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

template <class TP>
RtclClassOwned<TP>::RtclClassOwned(const std::string& type)
  : RtclClassBase(type)
{}

//------------------------------------------+-----------------------------------
//! Destructor

template <class TP>
RtclClassOwned<TP>::~RtclClassOwned()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TP>
inline int RtclClassOwned<TP>::ClassCmdCreate(Tcl_Interp* interp, int objc, 
                                              Tcl_Obj* const objv[])
{
  TP* pobj = new TP(interp, Tcl_GetString(objv[1]));
  if (pobj->ClassCmdConfig(interp, objc, objv) != kOK) {
    delete pobj;
    return kERR;
  }
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TP>
inline void RtclClassOwned<TP>::CreateClass(Tcl_Interp* interp, 
                                            const char* name, 
                                            const std::string& type)
{
  RtclClassOwned<TP>* p = new RtclClassOwned<TP>(type);
  p->CreateClassCmd(interp, name);
  return;
}

} // end namespace Retro
