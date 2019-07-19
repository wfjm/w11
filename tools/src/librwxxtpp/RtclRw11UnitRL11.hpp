// $Id: RtclRw11UnitRL11.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2014-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.1    use std::shared_ptr instead of boost
// 2014-06-08   561   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11UnitRL11.
*/

#ifndef included_Retro_RtclRw11UnitRL11
#define included_Retro_RtclRw11UnitRL11 1

#include "librw11/Rw11UnitRL11.hpp"
#include "librw11/Rw11CntlRL11.hpp"

#include "RtclRw11UnitDisk.hpp"
#include "RtclRw11UnitBase.hpp"

namespace Retro {

  class RtclRw11UnitRL11 : public RtclRw11UnitBase<Rw11UnitRL11,Rw11UnitDisk,
                                                   RtclRw11UnitDisk> {
    public:
                    RtclRw11UnitRL11(Tcl_Interp* interp,
                                 const std::string& unitcmd,
                                 const std::shared_ptr<Rw11UnitRL11>& spunit);
                   ~RtclRw11UnitRL11();

    protected:
  };
  
} // end namespace Retro

//#include "RtclRw11UnitRL11.ipp"

#endif
