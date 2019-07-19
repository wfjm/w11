// $Id: RtclRw11CpuBase.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.1    use std::shared_ptr instead of boost
// 2013-02-23   491   1.0    Initial version
// 2013-02-08   484   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11CpuBase.
*/

#ifndef included_Retro_RtclRw11CpuBase
#define included_Retro_RtclRw11CpuBase 1

#include <memory>

#include "RtclRw11Cpu.hpp"

namespace Retro {

  template <class TO>
  class RtclRw11CpuBase : public RtclRw11Cpu {
    public:
                    RtclRw11CpuBase(Tcl_Interp* interp, const char* name,
                                    const std::string& type);
                   ~RtclRw11CpuBase();

      TO&           Obj();
      const std::shared_ptr<TO>&  ObjSPtr();

    protected:
      std::shared_ptr<TO>  fspObj;         //!< sptr to managed object
  };
  
} // end namespace Retro

// implementation is all inline
#include "RtclRw11CpuBase.ipp"

#endif
