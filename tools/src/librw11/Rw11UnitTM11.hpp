// $Id: Rw11UnitTM11.hpp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rw11UnitTM11.
*/

#ifndef included_Retro_Rw11UnitTM11
#define included_Retro_Rw11UnitTM11 1

#include "Rw11UnitTapeBase.hpp"

namespace Retro {

  class Rw11CntlTM11;                       // forw decl to avoid circular incl

  class Rw11UnitTM11 : public Rw11UnitTapeBase<Rw11CntlTM11> {
    public:
                    Rw11UnitTM11(Rw11CntlTM11* pcntl, size_t index);
                   ~Rw11UnitTM11();

      void          SetTmds(uint16_t tmds);
      uint16_t      Tmds() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    protected:
      uint16_t      fTmds;
  };
  
} // end namespace Retro

#include "Rw11UnitTM11.ipp"

#endif
