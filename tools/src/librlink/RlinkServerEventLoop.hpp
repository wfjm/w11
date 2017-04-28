// $Id: RlinkServerEventLoop.hpp 887 2017-04-28 19:32:52Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-01-11   473   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
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
