// $Id: RlinkPortFactory.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-01  1076   2.0    use unique_ptr
// 2011-03-27   374   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RlinkPortFactory.
*/

#ifndef included_Retro_RlinkPortFactory
#define included_Retro_RlinkPortFactory 1

#include "librtools/RerrMsg.hpp"
#include "RlinkPort.hpp"

namespace Retro {

  class RlinkPortFactory {
    public:
    
      static RlinkPort::port_uptr_t New(const std::string& url, RerrMsg& emsg);
      static RlinkPort::port_uptr_t Open(const std::string& url, RerrMsg& emsg);
  };
  
} // end namespace Retro

//#include "RlinkPortFactory.ipp"

#endif
