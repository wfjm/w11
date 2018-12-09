// $Id: RlinkPortFactory.hpp 1076 2018-12-02 12:45:49Z mueller $
//
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-01  1076   2.0    use unique_ptr
// 2011-03-27   374   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
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
