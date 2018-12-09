// $Id: RtclRw11VirtFactory.hpp 1076 2018-12-02 12:45:49Z mueller $
//
// Copyright 2017-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-02  1076   2.0    use unique_ptr
// 2017-03-11   859   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
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
