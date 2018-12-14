// $Id: RtclRw11UnitDEUNA.hpp 1078 2018-12-08 14:19:03Z mueller $
//
// Copyright 2014-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-07  1078   1.1    use std::shared_ptr instead of boost
// 2017-04-08   870   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------


/*!
  \file
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
