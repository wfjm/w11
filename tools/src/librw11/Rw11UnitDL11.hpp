// $Id: Rw11UnitDL11.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-03-03   494   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11UnitDL11.
*/

#ifndef included_Retro_Rw11UnitDL11
#define included_Retro_Rw11UnitDL11 1

#include "Rw11UnitTermBase.hpp"

namespace Retro {

  class Rw11CntlDL11;                       // forw decl to avoid circular incl

  class Rw11UnitDL11 : public Rw11UnitTermBase<Rw11CntlDL11> {
    public:

                    Rw11UnitDL11(Rw11CntlDL11* pcntl, size_t index);
                   ~Rw11UnitDL11();

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    protected:

  };
  
} // end namespace Retro

//#include "Rw11UnitDL11.ipp"

#endif
