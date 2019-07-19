// $Id: RlinkChannel.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.0.2  use std::shared_ptr instead of boost
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-02-23   492   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RlinkChannel.
*/

#ifndef included_Retro_RlinkChannel
#define included_Retro_RlinkChannel 1

#include <memory>

#include "RlinkContext.hpp"
#include "RlinkConnect.hpp"
#include "RlinkCommandList.hpp"

namespace Retro {

  class RlinkChannel {
    public:
      explicit      RlinkChannel(const std::shared_ptr<RlinkConnect>& spconn);
                   ~RlinkChannel();

      RlinkConnect& Connect();
      RlinkContext& Context();

      bool          Exec(RlinkCommandList& clist, RerrMsg& emsg);

      void          Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;
    
    protected: 
      RlinkContext  fContext;               //!< stat check and errcnt context
      std::shared_ptr<RlinkConnect> fspConn; //!< ptr to connect
  };
  
} // end namespace Retro

#include "RlinkChannel.ipp"

#endif
