// $Id: Rw11UnitStreamBase.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-05-04   515   1.0    Initial version
// 2013-05-01   513   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11UnitStreamBase.
*/

#ifndef included_Retro_Rw11UnitStreamBase
#define included_Retro_Rw11UnitStreamBase 1

#include "Rw11UnitStream.hpp"

namespace Retro {

  template <class TC>
  class Rw11UnitStreamBase : public Rw11UnitStream {
    public:

                    Rw11UnitStreamBase(TC* pcntl, size_t index);
                   ~Rw11UnitStreamBase();

      TC&           Cntl() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    protected:
      virtual void  AttachDone();
      virtual void  DetachDone();

    protected:
      TC*           fpCntl;
  };
  
} // end namespace Retro

#include "Rw11UnitStreamBase.ipp"

#endif
