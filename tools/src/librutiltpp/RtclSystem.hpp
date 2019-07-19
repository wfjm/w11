// $Id: RtclSystem.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-05-17   521   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
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
