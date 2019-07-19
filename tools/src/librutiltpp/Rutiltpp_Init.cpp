// $Id: Rutiltpp_Init.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2014-08-22   584   1.0.4  use nullptr
// 2013-05-17   512   1.0.3  add RtclSystem::CreateCmds()
// 2013-02-10   485   1.0.2  remove Tcl_InitStubs()
// 2011-03-20   372   1.0.1  renamed ..tcl -> ..tpp
// 2011-03-19   371   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rutiltpp_Init .
*/

#include "tcl.h"

#include <stdexcept>

#include "RtclSystem.hpp"
#include "RtclBvi.hpp"

using namespace std;
using namespace Retro;

extern "C" int Rutiltpp_Init(Tcl_Interp* interp); // -Wmissing-prototypes fix

//------------------------------------------+-----------------------------------
extern "C" int Rutiltpp_Init(Tcl_Interp* interp) 
{
  int irc;

  // declare package name and version
  irc = Tcl_PkgProvide(interp, "rutiltpp", "1.0.0");
  if (irc != TCL_OK) return irc;

  try {
    // register general commands
    RtclSystem::CreateCmds(interp);
    RtclBvi::CreateCmds(interp);
    return TCL_OK;

  } catch (exception& e) {
    Tcl_AppendResult(interp, "-E: exception caught in Rutiltpp_Init: '", 
                     e.what(), "'", nullptr);
  }
  return TCL_ERROR;
}

