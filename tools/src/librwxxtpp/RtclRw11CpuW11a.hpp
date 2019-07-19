// $Id: RtclRw11CpuW11a.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-02-16   488   1.0    Initial version
// 2013-02-02   480   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11CpuW11a.
*/

#ifndef included_Retro_RtclRw11CpuW11a
#define included_Retro_RtclRw11CpuW11a 1

#include "RtclRw11CpuBase.hpp"
#include "librw11/Rw11CpuW11a.hpp"

namespace Retro {

  class RtclRw11CpuW11a : public RtclRw11CpuBase<Rw11CpuW11a> {
    public:
                    RtclRw11CpuW11a(Tcl_Interp* interp, const char* name);
                   ~RtclRw11CpuW11a();

    protected:
      void          SetupGetSet();

  };
  
} // end namespace Retro

//#include "RtclRw11CpuW11a.ipp"

#endif
