// $Id: RtclRw11CntlTM11.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-16   878   1.1    derive from RtclRw11CntlTapeBase
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11CntlTM11.
*/

#ifndef included_Retro_RtclRw11CntlTM11
#define included_Retro_RtclRw11CntlTM11 1

#include "RtclRw11CntlTapeBase.hpp"
#include "librw11/Rw11CntlTM11.hpp"

namespace Retro {

  class RtclRw11CntlTM11 : public RtclRw11CntlTapeBase<Rw11CntlTM11> {
    public:
                    RtclRw11CntlTM11();
                   ~RtclRw11CntlTM11();

      virtual int   FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu);

    protected:
      virtual int   M_stats(RtclArgs& args);
  };
  
} // end namespace Retro

//#include "RtclRw11CntlTM11.ipp"

#endif
