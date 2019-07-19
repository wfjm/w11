// $Id: RlinkServerEventLoop.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-01-11   473   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class \c RlinkServerEventLoop.
*/

#ifndef included_Retro_RlinkServerEventLoop
#define included_Retro_RlinkServerEventLoop 1

#include <cstdint>

#include "ReventLoop.hpp"

namespace Retro {

  class RlinkServer;                        // forward dcl

  class RlinkServerEventLoop : public ReventLoop {
    public:
                    RlinkServerEventLoop(RlinkServer* pserv);
      virtual      ~RlinkServerEventLoop();

      virtual void  EventLoop();

    protected: 
      RlinkServer*  fpServer;
};
  
} // end namespace Retro

//#include "RlinkServerEventLoop.ipp"

#endif
