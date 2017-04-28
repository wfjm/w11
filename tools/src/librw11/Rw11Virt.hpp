// $Id: Rw11Virt.hpp 887 2017-04-28 19:32:52Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-15   875   1.1.2  add Url() const getter
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2017-04-02   864   1.1    add fWProt,WProt()
// 2013-03-06   495   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rw11Virt.
*/

#ifndef included_Retro_Rw11Virt
#define included_Retro_Rw11Virt 1

#include <string>
#include <iostream>

#include "boost/utility.hpp"

#include "librtools/RparseUrl.hpp"
#include "librtools/RerrMsg.hpp"
#include "librtools/Rstats.hpp"
#include "Rw11Unit.hpp"

namespace Retro {

  class Rw11Virt : private boost::noncopyable {
    public:
      explicit      Rw11Virt(Rw11Unit* punit);
      virtual      ~Rw11Virt();

      Rw11Unit&     Unit() const;
      Rw11Cntl&     Cntl() const;
      Rw11Cpu&      Cpu() const;
      Rw11&         W11() const;
      RlinkServer&  Server() const;
      RlogFile&     LogFile() const;
      virtual bool  WProt() const;

      const RparseUrl& Url() const;
    
      virtual bool  Open(const std::string& url, RerrMsg& emsg) = 0;

      const Rstats& Stats() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // statistics counter indices
      enum stats {
        kDimStat = 0
      };    

    protected:
      Rw11Unit*     fpUnit;                 //<! back ref to unit
      RparseUrl     fUrl;
      bool          fWProt;                 //<! write protected
      Rstats        fStats;                 //<! statistics
  };
  
} // end namespace Retro

#include "Rw11Virt.ipp"

#endif
