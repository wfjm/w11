// $Id: RtclRw11Unit.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-01  1076   1.3    use unique_ptr instead of scoped_ptr
// 2018-09-15  1046   1.2.1  fix for clang: M_virt() now public
// 2017-04-08   870   1.2    drop fpCpu, use added Cpu()=0 instead
// 2017-04-02   863   1.1    add fpVirt,DetachCleanup(),AttachDone(),M_virt()
// 2013-03-03   494   1.0    Initial version
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11Unit.
*/

#ifndef included_Retro_RtclRw11Unit
#define included_Retro_RtclRw11Unit 1

#include <cstddef>
#include <string>
#include <memory>

#include "librtcltools/RtclProxyBase.hpp"
#include "librtcltools/RtclGetList.hpp"
#include "librtcltools/RtclSetList.hpp"

#include "librw11/Rw11Cpu.hpp"
#include "librw11/Rw11Unit.hpp"

#include "RtclRw11Virt.hpp"

namespace Retro {

  class RtclRw11Unit : public RtclProxyBase {
    public:

                    RtclRw11Unit(const std::string& type);
      virtual      ~RtclRw11Unit();

      virtual Rw11Unit&  Obj() = 0;
      virtual Rw11Cpu&   Cpu() const = 0;

    protected:
      virtual void  AttachDone() = 0;
      void          DetachCleanup();
      int           M_get(RtclArgs& args);
      int           M_set(RtclArgs& args);
      int           M_attach(RtclArgs& args);
      int           M_detach(RtclArgs& args);
      int           M_dump(RtclArgs& args);
      int           M_default(RtclArgs& args);
    public:
      int           M_virt(RtclArgs& args);

    protected:
      RtclGetList   fGets;
      RtclSetList   fSets;
      std::unique_ptr<RtclRw11Virt>  fupVirt;
  };
  
} // end namespace Retro

//#include "RtclRw11Unit.ipp"

#endif
