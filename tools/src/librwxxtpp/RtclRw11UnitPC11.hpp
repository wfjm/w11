// $Id: RtclRw11UnitPC11.hpp 887 2017-04-28 19:32:52Z mueller $
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
// 2013-05-03   515   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
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
                                const boost::shared_ptr<Rw11UnitPC11>& spunit);
                   ~RtclRw11UnitPC11();

    protected:
  };
  
} // end namespace Retro

//#include "RtclRw11UnitPC11.ipp"

#endif
