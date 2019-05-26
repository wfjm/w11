// $Id: RtclRw11CntlDZ11.hpp 1146 2019-05-05 06:25:13Z mueller $
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
  \brief   Declaration of class RtclRw11CntlDZ11.
*/

#ifndef included_Retro_RtclRw11CntlDZ11
#define included_Retro_RtclRw11CntlDZ11 1

#include "RtclRw11CntlTermBase.hpp"
#include "librw11/Rw11CntlDZ11.hpp"

namespace Retro {

  class RtclRw11CntlDZ11 : public RtclRw11CntlTermBase<Rw11CntlDZ11> {
    public:
                    RtclRw11CntlDZ11();
                   ~RtclRw11CntlDZ11();

      virtual int   FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu);
  };
  
} // end namespace Retro

//#include "RtclRw11CntlDZ11.ipp"

#endif
