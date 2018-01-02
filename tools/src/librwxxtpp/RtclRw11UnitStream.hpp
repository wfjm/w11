// $Id: RtclRw11UnitStream.hpp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-08   870   1.1    use Rw11UnitStream& ObjUV(); inh from RtclRw11Unit
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
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
