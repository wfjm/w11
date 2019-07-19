// $Id: RtclRw11UnitPC11.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.2    use std::shared_ptr instead of boost
// 2017-04-08   870   1.1    inherit from RtclRw11UnitBase
// 2013-05-03   515   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11UnitPC11.
*/

#ifndef included_Retro_RtclRw11UnitPC11
#define included_Retro_RtclRw11UnitPC11 1

#include "librw11/Rw11UnitPC11.hpp"
#include "librw11/Rw11CntlPC11.hpp"

#include "RtclRw11UnitStream.hpp"
#include "RtclRw11UnitBase.hpp"

namespace Retro {

class RtclRw11UnitPC11 : public RtclRw11UnitBase<Rw11UnitPC11,Rw11UnitStream,
                                                 RtclRw11UnitStream> {
    public:
                    RtclRw11UnitPC11(Tcl_Interp* interp,
                                const std::string& unitcmd,
                                const std::shared_ptr<Rw11UnitPC11>& spunit);
                   ~RtclRw11UnitPC11();

    protected:
  };
  
} // end namespace Retro

//#include "RtclRw11UnitPC11.ipp"

#endif
