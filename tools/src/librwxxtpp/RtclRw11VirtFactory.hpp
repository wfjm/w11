// $Id: RtclRw11VirtFactory.hpp 859 2017-03-11 22:36:45Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-03-11   859   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11VirtFactory.hpp 859 2017-03-11 22:36:45Z mueller $
  \brief   Declaration of global function RtclRw11VirtFactory.
*/

#ifndef included_Retro_RtclRw11VirtFactory
#define included_Retro_RtclRw11VirtFactory 1

#include "librw11/Rw11Virt.hpp"

#include "RtclRw11Virt.hpp"

namespace Retro {

  RtclRw11Virt* RtclRw11VirtFactory(Rw11Virt* pobj);
  
} // end namespace Retro

#endif
