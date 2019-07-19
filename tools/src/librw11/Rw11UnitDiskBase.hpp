// $Id: Rw11UnitDiskBase.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2013-05-03   515   1.1    use AttachDone(),DetachCleanup(),DetachDone()
// 2013-04-14   506   1.0    Initial version
// 2013-02-22   490   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11UnitDiskBase.
*/

#ifndef included_Retro_Rw11UnitDiskBase
#define included_Retro_Rw11UnitDiskBase 1

#include "Rw11UnitDisk.hpp"

namespace Retro {

  template <class TC>
  class Rw11UnitDiskBase : public Rw11UnitDisk {
    public:

                    Rw11UnitDiskBase(TC* pcntl, size_t index);
                   ~Rw11UnitDiskBase();

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

#include "Rw11UnitDiskBase.ipp"

#endif
