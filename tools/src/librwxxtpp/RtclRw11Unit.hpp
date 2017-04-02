// $Id: RtclRw11Unit.hpp 863 2017-04-02 11:43:15Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-02   863   1.1    add fpVirt,DetachCleanup(),AttachDone(),M_virt()
// 2013-03-03   494   1.0    Initial version
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11Unit.hpp 863 2017-04-02 11:43:15Z mueller $
  \brief   Declaration of class RtclRw11Unit.
*/

#ifndef included_Retro_RtclRw11Unit
#define included_Retro_RtclRw11Unit 1

#include <cstddef>
#include <string>

#include "boost/scoped_ptr.hpp"

#include "librtcltools/RtclProxyBase.hpp"
#include "librtcltools/RtclGetList.hpp"
#include "librtcltools/RtclSetList.hpp"

#include "librw11/Rw11Cpu.hpp"
#include "librw11/Rw11Unit.hpp"

#include "RtclRw11Virt.hpp"

namespace Retro {

  class RtclRw11Unit : public RtclProxyBase {
    public:

                    RtclRw11Unit(const std::string& type, Rw11Cpu* pcpu);
      virtual      ~RtclRw11Unit();

      virtual Rw11Unit&  Obj() = 0;
      RtclGetList&  GetList();
      RtclSetList&  SetList();

    protected:
      virtual void  AttachDone() = 0;
      void          DetachCleanup();
      int           M_get(RtclArgs& args);
      int           M_set(RtclArgs& args);
      int           M_attach(RtclArgs& args);
      int           M_detach(RtclArgs& args);
      int           M_virt(RtclArgs& args);
      int           M_dump(RtclArgs& args);
      int           M_default(RtclArgs& args);

    protected:
      Rw11Cpu*      fpCpu;
      RtclGetList   fGets;
      RtclSetList   fSets;
      boost::scoped_ptr<RtclRw11Virt>  fpVirt;
  };
  
} // end namespace Retro

#include "RtclRw11Unit.ipp"

#endif
