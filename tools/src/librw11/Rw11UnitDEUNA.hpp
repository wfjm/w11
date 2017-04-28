// $Id: Rw11UnitDEUNA.hpp 887 2017-04-28 19:32:52Z mueller $
//
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-01-29   847   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------


/*!
  \file
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
