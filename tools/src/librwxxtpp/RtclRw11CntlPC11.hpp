// $Id: RtclRw11CntlPC11.hpp 887 2017-04-28 19:32:52Z mueller $
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
// 2017-04-16   878   1.1    derive from RtclRw11CntlStreamBase
// 2013-05-03   515   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class RtclRw11CntlPC11.
*/

#ifndef included_Retro_RtclRw11CntlPC11
#define included_Retro_RtclRw11CntlPC11 1

#include "RtclRw11CntlStreamBase.hpp"
#include "librw11/Rw11CntlPC11.hpp"

namespace Retro {

  class RtclRw11CntlPC11 : public RtclRw11CntlStreamBase<Rw11CntlPC11> {
    public:
                    RtclRw11CntlPC11();
                   ~RtclRw11CntlPC11();

      virtual int   FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu);
  };
  
} // end namespace Retro

//#include "RtclRw11CntlPC11.ipp"

#endif
