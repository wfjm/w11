// $Id: Rw11UnitDEUNA.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-01-29   847   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11UnitDEUNA.
*/

#ifndef included_Retro_Rw11UnitDEUNA
#define included_Retro_Rw11UnitDEUNA 1

#include "Rw11VirtEth.hpp"

#include "Rw11UnitVirt.hpp"

namespace Retro {

  class Rw11CntlDEUNA;                       // forw decl to avoid circular incl

  class Rw11UnitDEUNA : public Rw11UnitVirt<Rw11VirtEth> {
    public:
                    Rw11UnitDEUNA(Rw11CntlDEUNA* pcntl, size_t index);
                   ~Rw11UnitDEUNA();

      Rw11CntlDEUNA&  Cntl() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    protected:
      virtual void  AttachDone();
      virtual void  DetachDone();

    protected:
      Rw11CntlDEUNA*  fpCntl;

  };
  
} // end namespace Retro

#include "Rw11UnitDEUNA.ipp"

#endif
