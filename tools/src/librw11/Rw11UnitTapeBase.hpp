// $Id: Rw11UnitTapeBase.hpp 983 2018-01-02 20:35:59Z mueller $
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
  \brief   Declaration of class Rw11UnitTapeBase.
*/

#ifndef included_Retro_Rw11UnitTapeBase
#define included_Retro_Rw11UnitTapeBase 1

#include "Rw11UnitTape.hpp"

namespace Retro {

  template <class TC>
  class Rw11UnitTapeBase : public Rw11UnitTape {
    public:

                    Rw11UnitTapeBase(TC* pcntl, size_t index);
                   ~Rw11UnitTapeBase();

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

#include "Rw11UnitTapeBase.ipp"

#endif
