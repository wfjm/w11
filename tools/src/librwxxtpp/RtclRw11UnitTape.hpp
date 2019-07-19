// $Id: RtclRw11UnitTape.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-08   870   1.1    use Rw11UnitTape& ObjUV(); inherit from RtclRw11Unit
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11UnitTape.
*/

#ifndef included_Retro_RtclRw11UnitTape
#define included_Retro_RtclRw11UnitTape 1

#include "librw11/Rw11UnitTape.hpp"

#include "RtclRw11Unit.hpp"

namespace Retro {

  class RtclRw11UnitTape : public RtclRw11Unit {
    public:
                    RtclRw11UnitTape(const std::string& type);
                   ~RtclRw11UnitTape();

      virtual Rw11UnitTape&  ObjUV() = 0;
    
    protected:
      void          SetupGetSet();


  };
  
} // end namespace Retro

//#include "RtclRw11UnitTape.ipp"

#endif
