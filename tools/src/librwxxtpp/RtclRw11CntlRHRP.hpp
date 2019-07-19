// $Id: RtclRw11CntlRHRP.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-16   878   1.1    derive from RtclRw11CntlDiskBase
// 2015-05-14   680   1.0    Initial version
// 2015-03-21   659   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11CntlRHRP.
*/

#ifndef included_Retro_RtclRw11CntlRHRP
#define included_Retro_RtclRw11CntlRHRP 1

#include "RtclRw11CntlDiskBase.hpp"
#include "librw11/Rw11CntlRHRP.hpp"

namespace Retro {

  class RtclRw11CntlRHRP : public RtclRw11CntlDiskBase<Rw11CntlRHRP> {
    public:
                    RtclRw11CntlRHRP();
                   ~RtclRw11CntlRHRP();

      virtual int   FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu);

    protected:
      virtual int   M_stats(RtclArgs& args);
  };
  
} // end namespace Retro

//#include "RtclRw11CntlRHRP.ipp"

#endif
