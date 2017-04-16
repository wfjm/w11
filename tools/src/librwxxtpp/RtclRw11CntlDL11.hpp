// $Id: RtclRw11CntlDL11.hpp 878 2017-04-16 12:28:15Z mueller $
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
// 2017-04-16   878   1.1    derive from RtclRw11CntlTermBase
// 2013-03-06   495   1.0    Initial version
// 2013-02-08   484   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11CntlDL11.hpp 878 2017-04-16 12:28:15Z mueller $
  \brief   Declaration of class RtclRw11CntlDL11.
*/

#ifndef included_Retro_RtclRw11CntlDL11
#define included_Retro_RtclRw11CntlDL11 1

#include "RtclRw11CntlTermBase.hpp"
#include "librw11/Rw11CntlDL11.hpp"

namespace Retro {

  class RtclRw11CntlDL11 : public RtclRw11CntlTermBase<Rw11CntlDL11> {
    public:
                    RtclRw11CntlDL11();
                   ~RtclRw11CntlDL11();

      virtual int   FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu);
  };
  
} // end namespace Retro

//#include "RtclRw11CntlDL11.ipp"

#endif
