// $Id: RtclRw11VirtFactory.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-02  1076   2.0    use unique_ptr
// 2017-03-11   859   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of global function RtclRw11VirtFactory.
*/

#ifndef included_Retro_RtclRw11VirtFactory
#define included_Retro_RtclRw11VirtFactory 1

#include <memory>

#include "librw11/Rw11Virt.hpp"

#include "RtclRw11Virt.hpp"

namespace Retro {

  std::unique_ptr<RtclRw11Virt> RtclRw11VirtFactory(Rw11Virt* pobj);
  
} // end namespace Retro

#endif
