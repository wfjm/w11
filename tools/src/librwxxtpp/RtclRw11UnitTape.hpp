// $Id: RtclRw11UnitTape.hpp 870 2017-04-08 18:24:34Z mueller $
//
// Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-08   870   1.1    use Rw11UnitTape& ObjUV(); inherit from RtclRw11Unit
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11UnitTape.hpp 870 2017-04-08 18:24:34Z mueller $
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
