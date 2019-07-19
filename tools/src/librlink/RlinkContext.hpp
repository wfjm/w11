// $Id: RlinkContext.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-03-16  1122   1.2    BUGFIX: use proper polarity of status mask
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2015-03-28   660   1.1    add SetStatus(Value|Mask)()
// 2013-02-23   492   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RlinkContext.
*/

#ifndef included_Retro_RlinkContext
#define included_Retro_RlinkContext 1

#include <cstdint>

namespace Retro {

  class RlinkContext {
    public:
                    RlinkContext();
                   ~RlinkContext();

      void          SetStatus(uint8_t stat, uint8_t statmsk=0x00);

      void          SetStatusValue(uint8_t stat);
      void          SetStatusMask(uint8_t statmsk);

      uint8_t       StatusValue() const;
      uint8_t       StatusMask() const;

      bool          StatusIsChecked() const;
      bool          StatusCheck(uint8_t val) const;

      void          IncErrorCount(size_t inc = 1);
      void          ClearErrorCount();
      size_t        ErrorCount() const;

      void          Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;
    
    protected: 
      uint8_t       fStatusVal;             //!< status value
      uint8_t       fStatusMsk;             //!< status mask
      size_t        fErrCnt;                //!< error count
  };
  
} // end namespace Retro

#include "RlinkContext.ipp"

#endif
