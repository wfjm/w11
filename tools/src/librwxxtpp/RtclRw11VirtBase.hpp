// $Id: RtclRw11VirtBase.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-03-11   859   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11VirtBase.
*/

#ifndef included_Retro_RtclRw11VirtBase
#define included_Retro_RtclRw11VirtBase 1

#include "RtclRw11Virt.hpp"

namespace Retro {

  template <class TO>
  class RtclRw11VirtBase : public RtclRw11Virt {
    public:
                    RtclRw11VirtBase(TO* pobj);
                   ~RtclRw11VirtBase();

      TO&           Obj();

    protected:
      TO*           fpObj;                 //!< ptr to object
  };
  
} // end namespace Retro

// implementation is all inline
#include "RtclRw11VirtBase.ipp"

#endif
