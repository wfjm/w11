// $Id: RtclClassOwned.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-02-20   363   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of class RtclClassOwned.
*/

#ifndef included_Retro_RtclClassOwned
#define included_Retro_RtclClassOwned 1

#include "tcl.h"

#include <string>

#include "RtclClassBase.hpp"

namespace Retro {

  template <class TP>
    class RtclClassOwned : public RtclClassBase {
    public:

      explicit      RtclClassOwned(const std::string& type = std::string());
                   ~RtclClassOwned();

      int           ClassCmdCreate(Tcl_Interp* interp, int objc, 
                                   Tcl_Obj* const objv[]);    

      static void   CreateClass(Tcl_Interp* interp, const char* name,
                                const std::string& type);
  };
  
} // end namespace Retro

// implementation all inline
#include "RtclClassOwned.ipp"

#endif
