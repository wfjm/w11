// $Id: Rlinktpp_Init.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2014-08-22   584   1.0.6  use nullptr
// 2013-02-10   485   1.0.5  remove Tcl_InitStubs()
// 2013-01-27   478   1.0.4  add rlinkport
// 2013-01-12   474   1.0.3  add rlinkserver
// 2011-03-20   372   1.0.2  renamed ..tcl -> ..tpp
// 2011-03-19   371   1.0.1  moved Bvi into librtoolstcl
// 2011-03-14   370   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rlinktpp_Init .
*/

#include "tcl.h"

#include <stdexcept>

#include "librtcltools/RtclClassOwned.hpp"
#include "RtclRlinkPort.hpp"
#include "RtclRlinkConnect.hpp"
#include "RtclRlinkServer.hpp"

using namespace std;
using namespace Retro;

extern "C" int Rlinktpp_Init(Tcl_Interp* interp); // -Wmissing-prototypes fix

//------------------------------------------+-----------------------------------
extern "C" int Rlinktpp_Init(Tcl_Interp* interp) 
{
  int irc;

  // declare package name and version
  irc = Tcl_PkgProvide(interp, "rlinktpp", "1.0.0");
  if (irc != TCL_OK) return irc;

  try {
    // register class commands
    RtclClassOwned<RtclRlinkPort>::CreateClass(interp, "rlinkport",
                                               "RlinkPort");
    RtclClassOwned<RtclRlinkConnect>::CreateClass(interp, "rlinkconnect",
                                                  "RlinkConnect");
    RtclClassOwned<RtclRlinkServer>::CreateClass(interp, "rlinkserver",
                                                 "RlinkServer");
    return TCL_OK;

  } catch (exception& e) {
    Tcl_AppendResult(interp, "-E: exception caught in Rlinktpp_Init: '", 
                     e.what(), "'", nullptr);
  }
  return TCL_ERROR;
}

