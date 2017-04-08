// $Id: RtclRw11UnitDL11.hpp 870 2017-04-08 18:24:34Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-08   870   1.1    inherit from RtclRw11UnitBase
// 2013-03-01   493   1.0    Initial version
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11UnitDL11.hpp 870 2017-04-08 18:24:34Z mueller $
  \brief   Declaration of class RtclRw11UnitDL11.
*/

#ifndef included_Retro_RtclRw11UnitDL11
#define included_Retro_RtclRw11UnitDL11 1

#include "librw11/Rw11UnitDL11.hpp"
#include "librw11/Rw11CntlDL11.hpp"

#include "RtclRw11UnitTerm.hpp"
#include "RtclRw11UnitBase.hpp"

namespace Retro {

  class RtclRw11UnitDL11 : public RtclRw11UnitBase<Rw11UnitDL11,Rw11UnitTerm,
                                                   RtclRw11UnitTerm> {
    public:
                    RtclRw11UnitDL11(Tcl_Interp* interp,
                                const std::string& unitcmd,
                                const boost::shared_ptr<Rw11UnitDL11>& spunit);
                   ~RtclRw11UnitDL11();

    protected:
  };
  
} // end namespace Retro

//#include "RtclRw11UnitDL11.ipp"

#endif
