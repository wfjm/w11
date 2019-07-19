// $Id: Rw11UnitPC11.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-04-20  1134   1.1    add AttachDone()
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-05-03   515   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11UnitPC11.
*/

#ifndef included_Retro_Rw11UnitPC11
#define included_Retro_Rw11UnitPC11 1

#include "Rw11UnitStreamBase.hpp"

namespace Retro {

  class Rw11CntlPC11;                       // forw decl to avoid circular incl

  class Rw11UnitPC11 : public Rw11UnitStreamBase<Rw11CntlPC11> {
    public:

                    Rw11UnitPC11(Rw11CntlPC11* pcntl, size_t index);
                   ~Rw11UnitPC11();

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    protected:
      virtual void  AttachDone();

  };
  
} // end namespace Retro

//#include "Rw11UnitPC11.ipp"

#endif
