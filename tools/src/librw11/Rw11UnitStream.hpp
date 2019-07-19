// $Id: Rw11UnitStream.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-09  1080   1.0.2  Pos() not const anymore
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-05-04   515   1.0    Initial version
// 2013-05-01   513   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11UnitStream.
*/

#ifndef included_Retro_Rw11UnitStream
#define included_Retro_Rw11UnitStream 1

#include "Rw11VirtStream.hpp"

#include "Rw11UnitVirt.hpp"

namespace Retro {

  class Rw11UnitStream : public Rw11UnitVirt<Rw11VirtStream> {
    public:
                    Rw11UnitStream(Rw11Cntl* pcntl, size_t index);
                   ~Rw11UnitStream();

      void          SetPos(int pos);
      int           Pos();

      int           VirtRead(uint8_t* data, size_t count, RerrMsg& emsg);
      bool          VirtWrite(const uint8_t* data, size_t count, RerrMsg& emsg);
      bool          VirtFlush(RerrMsg& emsg);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // statistics counter indices
      enum stats {
        kStatNPreAttDrop = Rw11Unit::kDimStat,
        kStatNPreAttMiss,
        kDimStat
      };

    protected:
  };
  
} // end namespace Retro

//#include "Rw11UnitStream.ipp"

#endif
