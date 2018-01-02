// $Id: Rw11CntlBase.hpp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-15   874   1.0.2  add UnitBase()
// 2017-04-02   865   1.0.1  Dump(): add detail arg
// 2013-03-06   495   1.0    Initial version
// 2013-02-14   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rw11CntlBase.
*/

#ifndef included_Retro_Rw11CntlBase
#define included_Retro_Rw11CntlBase 1

#include "boost/shared_ptr.hpp"

#include "Rw11Cntl.hpp"

namespace Retro {

  template <class TU, size_t NU>
  class Rw11CntlBase : public Rw11Cntl {
    public:

      explicit      Rw11CntlBase(const std::string& type);
                   ~Rw11CntlBase();

      virtual size_t NUnit() const;
      virtual Rw11Unit& UnitBase(size_t index) const;
      TU&           Unit(size_t index) const;
      const boost::shared_ptr<TU>& UnitSPtr(size_t index) const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    protected:
      boost::shared_ptr<TU> fspUnit[NU];
  };
  
} // end namespace Retro

#include "Rw11CntlBase.ipp"

#endif
