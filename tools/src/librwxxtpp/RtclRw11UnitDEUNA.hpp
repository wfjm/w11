// $Id: RtclRw11UnitDEUNA.hpp 870 2017-04-08 18:24:34Z mueller $
//
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-08   870   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11UnitDEUNA.hpp 870 2017-04-08 18:24:34Z mueller $
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
                                const boost::shared_ptr<Rw11UnitDEUNA>& spunit);
                   ~RtclRw11UnitDEUNA();

    protected:
  };
  
} // end namespace Retro

//#include "RtclRw11UnitDEUNA.ipp"

#endif
