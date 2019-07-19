// $Id: RtclRw11UnitDisk.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-08   870   1.1    use Rw11UnitDisk& ObjUV(); inherit from RtclRw11Unit
// 2013-04-19   507   1.0    Initial version
// 2013-02-22   490   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11UnitDisk.
*/

#ifndef included_Retro_RtclRw11UnitDisk
#define included_Retro_RtclRw11UnitDisk 1

#include "librw11/Rw11UnitDisk.hpp"

#include "RtclRw11Unit.hpp"

namespace Retro {

  class RtclRw11UnitDisk : public RtclRw11Unit {
    public:
                    RtclRw11UnitDisk(const std::string& type);
                   ~RtclRw11UnitDisk();

      virtual Rw11UnitDisk&  ObjUV() = 0;

    protected:
      void          SetupGetSet();

  };
  
} // end namespace Retro

//#include "RtclRw11UnitDisk.ipp"

#endif
