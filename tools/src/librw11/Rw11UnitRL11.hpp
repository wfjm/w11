// $Id: Rw11UnitRL11.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2014-06-08   561   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11UnitRL11.
*/

#ifndef included_Retro_Rw11UnitRL11
#define included_Retro_Rw11UnitRL11 1

#include "Rw11UnitDiskBase.hpp"

namespace Retro {

  class Rw11CntlRL11;                       // forw decl to avoid circular incl

  class Rw11UnitRL11 : public Rw11UnitDiskBase<Rw11CntlRL11> {
    public:
                    Rw11UnitRL11(Rw11CntlRL11* pcntl, size_t index);
                   ~Rw11UnitRL11();

      virtual void  SetType(const std::string& type);

      void          SetRlsta(uint16_t rlsta);
      void          SetRlpos(uint16_t rlpos);
      uint16_t      Rlsta() const;
      uint16_t      Rlpos() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    protected:
      uint16_t      fRlsta;
      uint16_t      fRlpos;
  };
  
} // end namespace Retro

#include "Rw11UnitRL11.ipp"

#endif
