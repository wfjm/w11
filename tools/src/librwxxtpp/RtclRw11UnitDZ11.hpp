// $Id: RtclRw11UnitDZ11.hpp 1146 2019-05-05 06:25:13Z mueller $
//
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-05-04  1146   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
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
