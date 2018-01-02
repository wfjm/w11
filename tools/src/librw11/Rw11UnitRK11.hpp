// $Id: Rw11UnitRK11.hpp 983 2018-01-02 20:35:59Z mueller $
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
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-04-20   508   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rw11UnitRK11.
*/

#ifndef included_Retro_Rw11UnitRK11
#define included_Retro_Rw11UnitRK11 1

#include "Rw11UnitDiskBase.hpp"

namespace Retro {

  class Rw11CntlRK11;                       // forw decl to avoid circular incl

  class Rw11UnitRK11 : public Rw11UnitDiskBase<Rw11CntlRK11> {
    public:
                    Rw11UnitRK11(Rw11CntlRK11* pcntl, size_t index);
                   ~Rw11UnitRK11();

      void          SetRkds(uint16_t rkds);
      uint16_t      Rkds() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    protected:
      uint16_t      fRkds;
  };
  
} // end namespace Retro

#include "Rw11UnitRK11.ipp"

#endif
