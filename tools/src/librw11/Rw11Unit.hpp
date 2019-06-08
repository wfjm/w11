// $Id: Rw11Unit.hpp 1160 2019-06-07 17:30:17Z mueller $
//
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-06-07  1160   1.1.5  Stats() not longer const
// 2018-12-16  1084   1.1.4  use =delete for noncopyable instead of boost
// 2017-04-15   875   1.1.3  add VirtBase(), IsAttached(), AttachUrl()
// 2017-04-07   868   1.1.2  Dump(): add detail arg
// 2015-05-13   680   1.1.1  add Enabled()
// 2013-05-03   515   1.1    use AttachDone(),DetachCleanup(),DetachDone()
// 2013-05-01   513   1.0.1  add fAttachOpts, (Set)AttachOpts()
// 2013-03-06   495   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rw11Unit.
*/

#ifndef included_Retro_Rw11Unit
#define included_Retro_Rw11Unit 1

#include <string>

#include "librtools/Rstats.hpp"
#include "librtools/RerrMsg.hpp"
#include "librlink/RlinkServer.hpp"

#include "librtools/Rbits.hpp"
#include "Rw11Cntl.hpp"

namespace Retro {

  class Rw11Virt;                           // forw decl to avoid circular incl

  class Rw11Unit : public Rbits {
    public:

                    Rw11Unit(Rw11Cntl* pcntl, size_t index);
      virtual      ~Rw11Unit();

                    Rw11Unit(const Rw11Unit&) = delete;   // noncopyable 
      Rw11Unit&     operator=(const Rw11Unit&) = delete;  // noncopyable

      size_t        Index() const;
      std::string   Name() const;

      void          SetAttachOpts(const std::string& opts);
      const std::string& AttachOpts() const;

      Rw11Cntl&     CntlBase() const;
      Rw11Cpu&      Cpu() const;
      Rw11&         W11() const;
      RlinkServer&  Server() const;
      RlinkConnect& Connect() const;
      RlogFile&     LogFile() const;
      virtual bool  Enabled() const;

      virtual Rw11Virt*  VirtBase() const = 0;
      bool          IsAttached() const;
      const std::string& AttachUrl() const;
    
      virtual bool  Attach(const std::string& url, RerrMsg& emsg);
      virtual void  Detach();

      Rstats&       Stats();
      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // statistics counter indices
      enum stats {
        kDimStat = 0
      };    

    protected:
      virtual void  AttachDone();
      virtual void  DetachCleanup();
      virtual void  DetachDone();

    private:
                    Rw11Unit() {}           //!< default ctor blocker

    protected:
      Rw11Cntl*     fpCntlBase;             //!< plain Rw11Cntl ptr
      size_t        fIndex;                 //!< unit number
      std::string   fAttachOpts;            //!< unit context options for attach
      Rstats        fStats;                 //!< statistics
  };
  
} // end namespace Retro

#include "Rw11Unit.ipp"

#endif
