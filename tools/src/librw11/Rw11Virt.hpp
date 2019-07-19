// $Id: Rw11Virt.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.1.4  Stats() not longer const
// 2018-12-16  1084   1.1.3  use =delete for noncopyable instead of boost
// 2017-04-15   875   1.1.2  add Url() const getter
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2017-04-02   864   1.1    add fWProt,WProt()
// 2013-03-06   495   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11Virt.
*/

#ifndef included_Retro_Rw11Virt
#define included_Retro_Rw11Virt 1

#include <string>
#include <iostream>

#include "librtools/RparseUrl.hpp"
#include "librtools/RerrMsg.hpp"
#include "librtools/Rstats.hpp"
#include "Rw11Unit.hpp"

namespace Retro {

  class Rw11Virt {
    public:
      explicit      Rw11Virt(Rw11Unit* punit);
      virtual      ~Rw11Virt();

                    Rw11Virt(const Rw11Virt&) = delete;   // noncopyable 
      Rw11Virt&     operator=(const Rw11Virt&) = delete;  // noncopyable

      Rw11Unit&     Unit() const;
      Rw11Cntl&     Cntl() const;
      Rw11Cpu&      Cpu() const;
      Rw11&         W11() const;
      RlinkServer&  Server() const;
      RlogFile&     LogFile() const;
      virtual bool  WProt() const;

      const RparseUrl& Url() const;
    
      virtual bool  Open(const std::string& url, RerrMsg& emsg) = 0;

      Rstats&       Stats();

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // statistics counter indices
      enum stats {
        kDimStat = 0
      };    

    protected:
      Rw11Unit*     fpUnit;                 //!< back ref to unit
      RparseUrl     fUrl;
      bool          fWProt;                 //!< write protected
      Rstats        fStats;                 //!< statistics
  };
  
} // end namespace Retro

#include "Rw11Virt.ipp"

#endif
