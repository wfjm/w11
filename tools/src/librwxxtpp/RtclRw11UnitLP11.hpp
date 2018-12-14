// $Id: RtclRw11UnitLP11.hpp 1078 2018-12-08 14:19:03Z mueller $
//
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-07  1078   1.2    use std::shared_ptr instead of boost
// 2017-04-08   870   1.1    inherit from RtclRw11UnitBase
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class RtclRw11UnitLP11.
*/

#ifndef included_Retro_RtclRw11UnitLP11
#define included_Retro_RtclRw11UnitLP11 1

#include "librw11/Rw11UnitLP11.hpp"
#include "librw11/Rw11CntlLP11.hpp"

#include "RtclRw11UnitStream.hpp"
#include "RtclRw11UnitBase.hpp"

namespace Retro {

class RtclRw11UnitLP11 : public RtclRw11UnitBase<Rw11UnitLP11,Rw11UnitStream,
                                                 RtclRw11UnitStream> {
    public:
                    RtclRw11UnitLP11(Tcl_Interp* interp,
                                const std::string& unitcmd,
                                const std::shared_ptr<Rw11UnitLP11>& spunit);
                   ~RtclRw11UnitLP11();

    protected:
  };
  
} // end namespace Retro

//#include "RtclRw11UnitLP11.ipp"

#endif
