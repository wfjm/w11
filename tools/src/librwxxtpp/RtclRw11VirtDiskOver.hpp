// $Id: RtclRw11VirtDiskOver.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-03-11   859   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11VirtDiskOver.
*/

#ifndef included_Retro_RtclRw11VirtDiskOver
#define included_Retro_RtclRw11VirtDiskOver 1

#include "librw11/Rw11VirtDiskOver.hpp"

#include "RtclRw11VirtBase.hpp"

namespace Retro {

  class RtclRw11VirtDiskOver : public RtclRw11VirtBase<Rw11VirtDiskOver> {
    public:
                    RtclRw11VirtDiskOver(Rw11VirtDiskOver* pobj);
                   ~RtclRw11VirtDiskOver();

    protected:
      int           M_flush(RtclArgs& args);
      int           M_list(RtclArgs& args);
  };
  
} // end namespace Retro

//#include "RtclRw11VirtDiskOver.ipp"

#endif
