// $Id: tclshcpp.cpp 1185 2019-07-12 17:29:12Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2014-11-07   601   1.0    Initial version

// This code is the minimal code for a tclsh, as recommended by
//   http://wiki.tcl.tk/1315
// but also equivalent to the code in tclAppInit.c which is the source of
// tclsh when all ifdefs and options have been removed.
//
// Only difference to the plain C version is the inclusion of <iostream>.
// This ensures that the C++ basing I/O streams are initialized before the
// Tcl interpreter starts.
//
// If iostream is not included one gets core dumps when a 'package require'
// loads a dynamic library which has C++ code and unresolved references.
// With  iostream included one gets a proper error message.
//

#include "tcl.h"
#include <iostream>

int main(int argc, char **argv)
{
  extern int Tcl_AppInit(Tcl_Interp *interp);
  Tcl_Main(argc, argv, Tcl_AppInit);
  return 0;
}

int Tcl_AppInit(Tcl_Interp *interp)
{
  if (Tcl_Init(interp) == TCL_ERROR) return TCL_ERROR;
  Tcl_SetVar(interp, "tcl_rcFileName", "~/.tclshrc", TCL_GLOBAL_ONLY);
  return TCL_OK;
}
