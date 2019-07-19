// $Id: Rw11UnitDZ11.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-05-04  1146   0.1    First draft
// ---------------------------------------------------------------------------


/*!
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
