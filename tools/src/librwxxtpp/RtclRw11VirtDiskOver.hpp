// $Id: RtclRw11VirtDiskOver.hpp 859 2017-03-11 22:36:45Z mueller $
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
// 2013-03-11   859   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11VirtDiskOver.hpp 859 2017-03-11 22:36:45Z mueller $
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
