// $Id: RlinkCrc16.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2014-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-22  1091   1.0.1  Drop empty dtors for pod-only classes
// 2014-11-08   602   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class \c RlinkCrc16.
*/

#ifndef included_Retro_RlinkCrc16
#define included_Retro_RlinkCrc16 1

#include <cstdint>
#include <vector>

namespace Retro {

  class RlinkCrc16 {
    public:
                    RlinkCrc16();

      void          Clear();
      void          AddData(uint8_t data);
      uint16_t      Crc() const;    

    protected: 

      uint16_t      fCrc;                   //!< current crc value
      static const uint16_t fCrc16Table[256];   // doxed in cpp
  };
  
} // end namespace Retro

#include "RlinkCrc16.ipp"

#endif
