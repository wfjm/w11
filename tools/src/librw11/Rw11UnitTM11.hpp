// $Id: Rw11UnitTM11.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
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
