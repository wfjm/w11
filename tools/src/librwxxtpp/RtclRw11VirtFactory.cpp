// $Id: RtclRw11VirtFactory.cpp 1076 2018-12-02 12:45:49Z mueller $
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
// 2017-03-11   589   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of global function RtclRw11VirtFactory.
*/

#include "librw11/Rw11VirtDiskOver.hpp"
#include "librw11/Rw11VirtDiskRam.hpp"

#include "RtclRw11VirtDiskOver.hpp"
#include "RtclRw11VirtDiskRam.hpp"

#include "RtclRw11VirtFactory.hpp"

using namespace std;

// all method definitions in namespace Retro (avoid using in includes...)
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::unique_ptr<RtclRw11Virt> RtclRw11VirtFactory(Rw11Virt* pobj)
{
  // 'factory section', create concrete RtclRw11Virt objects
  typedef std::unique_ptr<RtclRw11Virt> virt_uptr_t;
  
  Rw11VirtDiskOver* pdiskover = dynamic_cast<Rw11VirtDiskOver*>(pobj);
  if (pdiskover) {
    return virt_uptr_t(new RtclRw11VirtDiskOver(pdiskover));
  }  
  Rw11VirtDiskRam* pdiskram = dynamic_cast<Rw11VirtDiskRam*>(pobj);
  if (pdiskram) {
    return virt_uptr_t(new RtclRw11VirtDiskRam(pdiskram));
  }  

  return virt_uptr_t();
}

} // end namespace Retro
