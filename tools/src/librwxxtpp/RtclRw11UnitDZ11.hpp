// $Id: RtclRw11UnitDZ11.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-05-04  1146   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11UnitDZ11.
*/

#ifndef included_Retro_RtclRw11UnitDZ11
#define included_Retro_RtclRw11UnitDZ11 1

#include "librw11/Rw11UnitDZ11.hpp"
#include "librw11/Rw11CntlDZ11.hpp"

#include "RtclRw11UnitTerm.hpp"
#include "RtclRw11UnitBase.hpp"

namespace Retro {

  class RtclRw11UnitDZ11 : public RtclRw11UnitBase<Rw11UnitDZ11,Rw11UnitTerm,
                                                   RtclRw11UnitTerm> {
    public:
                    RtclRw11UnitDZ11(Tcl_Interp* interp,
                                const std::string& unitcmd,
                                const std::shared_ptr<Rw11UnitDZ11>& spunit);
                   ~RtclRw11UnitDZ11();

    protected:
  };
  
} // end namespace Retro

//#include "RtclRw11UnitDZ11.ipp"

#endif
