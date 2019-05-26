// $Id: Rw11UnitDZ11.hpp 1146 2019-05-05 06:25:13Z mueller $
//
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-05-04  1146   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rw11UnitDZ11.
*/

#ifndef included_Retro_Rw11UnitDZ11
#define included_Retro_Rw11UnitDZ11 1

#include "Rw11UnitTermBase.hpp"

namespace Retro {

  class Rw11CntlDZ11;                       // forw decl to avoid circular incl

  class Rw11UnitDZ11 : public Rw11UnitTermBase<Rw11CntlDZ11> {
    public:

                    Rw11UnitDZ11(Rw11CntlDZ11* pcntl, size_t index);
                   ~Rw11UnitDZ11();

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    protected:

  };
  
} // end namespace Retro

//#include "Rw11UnitDZ11.ipp"

#endif
