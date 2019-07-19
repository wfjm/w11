// $Id: RtclRw11CntlDZ11.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-05-04  1146   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
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
