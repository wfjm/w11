// $Id: RtclRw11Virt.hpp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-03-11   859   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class RtclRw11Virt.
*/

#ifndef included_Retro_RtclRw11Virt
#define included_Retro_RtclRw11Virt 1

#include "librw11/Rw11Virt.hpp"

#include "librtcltools/RtclGetList.hpp"
#include "librtcltools/RtclSetList.hpp"

#include "librtcltools/RtclCmdBase.hpp"

namespace Retro {

  class RtclRw11Virt : public RtclCmdBase {
    public:
                    RtclRw11Virt(Rw11Virt* pvirt);
                   ~RtclRw11Virt();

      Rw11Virt*     Virt() const;

    protected:
      int           M_get(RtclArgs& args);
      int           M_set(RtclArgs& args);
      int           M_stats(RtclArgs& args);
      int           M_dump(RtclArgs& args);

    protected:
      Rw11Virt*     fpVirt;
      RtclGetList   fGets;
      RtclSetList   fSets;
  };
  
} // end namespace Retro

#include "RtclRw11Virt.ipp"

#endif
