// $Id: RtclBvi.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-03-27   374   1.0    Initial version
// 2011-02-18   362   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of class RtclBvi.
*/

#ifndef included_Retro_RtclBvi
#define included_Retro_RtclBvi 1

#include "tcl.h"

namespace Retro {

  class RtclBvi {
    public:
      static void   CreateCmds(Tcl_Interp* interp);

    protected:
      enum ConvMode {kStr2Int = 0,
                     kInt2Str};
    
      static int    DoCmd(ClientData cdata, Tcl_Interp* interp, 
                           int objc, Tcl_Obj* const objv[]);
      static Tcl_Obj* DoConv(Tcl_Interp* interp, ConvMode mode, Tcl_Obj* val, 
                             char form, int nbit);
      static bool   CheckFormat(Tcl_Interp* interp, int objc,
                                Tcl_Obj* const objv[], bool& list, 
                                char& form, int& nbit);
  };
  
} // end namespace Retro

//#include "RtclBvi.ipp"

#endif
