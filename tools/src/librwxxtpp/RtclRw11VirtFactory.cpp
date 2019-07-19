// $Id: RtclRw11VirtFactory.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-02  1076   2.0    use unique_ptr
// 2017-03-11   589   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
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
