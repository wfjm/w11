// $Id: RtclRw11VirtDiskRam.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-10-28  1063   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11VirtDiskRam.
*/

#ifndef included_Retro_RtclRw11VirtDiskRam
#define included_Retro_RtclRw11VirtDiskRam 1

#include "librw11/Rw11VirtDiskRam.hpp"

#include "RtclRw11VirtBase.hpp"

namespace Retro {

  class RtclRw11VirtDiskRam : public RtclRw11VirtBase<Rw11VirtDiskRam> {
    public:
                    RtclRw11VirtDiskRam(Rw11VirtDiskRam* pobj);
                   ~RtclRw11VirtDiskRam();

    protected:
      int           M_list(RtclArgs& args);
  };
  
} // end namespace Retro

//#include "RtclRw11VirtDiskRam.ipp"

#endif
