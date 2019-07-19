// $Id: RtclRw11UnitStream.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-08   870   1.1    use Rw11UnitStream& ObjUV(); inh from RtclRw11Unit
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11UnitStream.
*/

#ifndef included_Retro_RtclRw11UnitStream
#define included_Retro_RtclRw11UnitStream 1

#include "librw11/Rw11UnitStream.hpp"

#include "RtclRw11Unit.hpp"

namespace Retro {

  class RtclRw11UnitStream : public RtclRw11Unit {
    public:
                    RtclRw11UnitStream(const std::string& type);
                   ~RtclRw11UnitStream();

      virtual Rw11UnitStream&  ObjUV() = 0;

    protected:
      void          SetupGetSet();
    
  };
  
} // end namespace Retro

//#include "RtclRw11UnitStream.ipp"

#endif
