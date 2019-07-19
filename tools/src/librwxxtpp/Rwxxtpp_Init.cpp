// $Id: Rwxxtpp_Init.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2014-08-22   584   1.0.1  use nullptr
// 2013-02-10   485   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rwxxtpp_Init .
*/

#include "tcl.h"

#include <stdexcept>

#include "librtcltools/RtclClassOwned.hpp"
#include "RtclRw11.hpp"

using namespace std;
using namespace Retro;

extern "C" int Rwxxtpp_Init(Tcl_Interp* interp); // -Wmissing-prototypes fix

//------------------------------------------+-----------------------------------
extern "C" int Rwxxtpp_Init(Tcl_Interp* interp) 
{
  int irc;

  // declare package name and version
  irc = Tcl_PkgProvide(interp, "rwxxtpp", "1.0.0");
  if (irc != TCL_OK) return irc;

  try {
    // register class commands
    RtclClassOwned<RtclRw11>::CreateClass(interp, "rw11", "Rw11");
    return TCL_OK;

  } catch (exception& e) {
    Tcl_AppendResult(interp, "-E: exception caught in Rwxxtpp_Init: '", 
                     e.what(), "'", nullptr);
  }
  return TCL_ERROR;
}

