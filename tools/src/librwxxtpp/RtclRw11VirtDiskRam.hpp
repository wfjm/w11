// $Id: RtclRw11VirtDiskRam.hpp 1063 2018-10-29 18:37:42Z mueller $
//
// Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-10-28  1063   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
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
