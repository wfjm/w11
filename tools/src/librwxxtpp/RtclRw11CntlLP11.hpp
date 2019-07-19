// $Id: RtclRw11CntlLP11.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-16   878   1.1    derive from RtclRw11CntlStreamBase
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11CntlLP11.
*/

#ifndef included_Retro_RtclRw11CntlLP11
#define included_Retro_RtclRw11CntlLP11 1

#include "RtclRw11CntlStreamBase.hpp"
#include "librw11/Rw11CntlLP11.hpp"

namespace Retro {

  class RtclRw11CntlLP11 : public RtclRw11CntlStreamBase<Rw11CntlLP11> {
    public:
                    RtclRw11CntlLP11();
                   ~RtclRw11CntlLP11();

      virtual int   FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu);
  };
  
} // end namespace Retro

//#include "RtclRw11CntlLP11.ipp"

#endif
