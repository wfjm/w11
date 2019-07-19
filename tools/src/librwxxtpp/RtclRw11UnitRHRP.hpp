// $Id: RtclRw11UnitRHRP.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.2    use std::shared_ptr instead of boost
// 2017-04-08   870   1.1    inherit from RtclRw11UnitBase
// 2015-05-14   680   1.0    Initial version
// 2015-03-21   659   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11UnitRHRP.
*/

#ifndef included_Retro_RtclRw11UnitRHRP
#define included_Retro_RtclRw11UnitRHRP 1

#include "librw11/Rw11UnitRHRP.hpp"
#include "librw11/Rw11CntlRHRP.hpp"

#include "RtclRw11UnitDisk.hpp"
#include "RtclRw11UnitBase.hpp"

namespace Retro {

  class RtclRw11UnitRHRP : public RtclRw11UnitBase<Rw11UnitRHRP,Rw11UnitDisk,
                                                   RtclRw11UnitDisk> {
    public:
                    RtclRw11UnitRHRP(Tcl_Interp* interp,
                                 const std::string& unitcmd,
                                 const std::shared_ptr<Rw11UnitRHRP>& spunit);
                   ~RtclRw11UnitRHRP();

    protected:
  };
  
} // end namespace Retro

//#include "RtclRw11UnitRHRP.ipp"

#endif
