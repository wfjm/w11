// $Id: RtclRw11CntlDEUNA.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-16   878   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11CntlDEUNA.
*/

#ifndef included_Retro_RtclRw11CntlDEUNA
#define included_Retro_RtclRw11CntlDEUNA 1

#include "RtclRw11CntlBase.hpp"
#include "librw11/Rw11CntlDEUNA.hpp"

namespace Retro {

  class RtclRw11CntlDEUNA : public RtclRw11CntlBase<Rw11CntlDEUNA> {
    public:
                    RtclRw11CntlDEUNA();
                   ~RtclRw11CntlDEUNA();

      virtual int   FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu);

    protected:
      virtual int   M_default(RtclArgs& args);
  };
  
} // end namespace Retro

//#include "RtclRw11CntlDEUNA.ipp"

#endif
