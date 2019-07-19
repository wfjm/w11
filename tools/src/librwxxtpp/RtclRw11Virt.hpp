// $Id: RtclRw11Virt.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-03-11   859   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11Virt.
*/

#ifndef included_Retro_RtclRw11Virt
#define included_Retro_RtclRw11Virt 1

#include "librw11/Rw11Virt.hpp"

#include "librtcltools/RtclGetList.hpp"
#include "librtcltools/RtclSetList.hpp"

#include "librtcltools/RtclCmdBase.hpp"

namespace Retro {

  class RtclRw11Virt : public RtclCmdBase {
    public:
                    RtclRw11Virt(Rw11Virt* pvirt);
                   ~RtclRw11Virt();

      Rw11Virt*     Virt() const;

    protected:
      int           M_get(RtclArgs& args);
      int           M_set(RtclArgs& args);
      int           M_stats(RtclArgs& args);
      int           M_dump(RtclArgs& args);

    protected:
      Rw11Virt*     fpVirt;
      RtclGetList   fGets;
      RtclSetList   fSets;
  };
  
} // end namespace Retro

#include "RtclRw11Virt.ipp"

#endif
