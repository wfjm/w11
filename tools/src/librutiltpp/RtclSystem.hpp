// $Id: RtclSystem.hpp 887 2017-04-28 19:32:52Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-05-17   521   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Declaration of class RtclSystem.
*/

#ifndef included_Retro_RtclSystem
#define included_Retro_RtclSystem 1

#include "tcl.h"

namespace Retro {

  class RtclSystem {
    public:
      static void   CreateCmds(Tcl_Interp* interp);
    
      static int    Isatty(ClientData cdata, Tcl_Interp* interp, 
                           int objc, Tcl_Obj* const objv[]);
      static int    SignalAction(ClientData cdata, Tcl_Interp* interp, 
                                 int objc, Tcl_Obj* const objv[]);
      static int    WaitPid(ClientData cdata, Tcl_Interp* interp, 
                            int objc, Tcl_Obj* const objv[]);

    private:
  };
  
} // end namespace Retro

//#include "RtclSystem.ipp"

#endif
