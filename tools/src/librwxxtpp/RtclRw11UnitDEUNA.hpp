// $Id: RtclRw11UnitDEUNA.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2014-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.1    use std::shared_ptr instead of boost
// 2017-04-08   870   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11UnitDEUNA.
*/

#ifndef included_Retro_RtclRw11UnitDEUNA
#define included_Retro_RtclRw11UnitDEUNA 1

#include "librw11/Rw11UnitDEUNA.hpp"
#include "librw11/Rw11CntlDEUNA.hpp"

#include "RtclRw11UnitBase.hpp"

namespace Retro {

class RtclRw11UnitDEUNA : public RtclRw11UnitBase<Rw11UnitDEUNA,Rw11Unit,
                                                  RtclRw11Unit> {
    public:
                    RtclRw11UnitDEUNA(Tcl_Interp* interp,
                                const std::string& unitcmd,
                                const std::shared_ptr<Rw11UnitDEUNA>& spunit);
                   ~RtclRw11UnitDEUNA();

    protected:
  };
  
} // end namespace Retro

//#include "RtclRw11UnitDEUNA.ipp"

#endif
