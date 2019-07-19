// $Id: Rw11UnitVirt.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-09  1080   1.2    add HasVirt(); return ref for Virt()
// 2018-12-01  1076   1.1    use unique_ptr instead of scoped_ptr
// 2017-04-15   875   1.0.2  add VirtBase()
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-03-03   494   1.0    Initial version
// 2013-02-22   490   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11UnitVirt.
*/

#ifndef included_Retro_Rw11UnitVirt
#define included_Retro_Rw11UnitVirt 1

#include <memory>

#include "Rw11Unit.hpp"

namespace Retro {

  template <class TV>
  class Rw11UnitVirt : public Rw11Unit {
    public:

                    Rw11UnitVirt(Rw11Cntl* pcntl, size_t index);
                   ~Rw11UnitVirt();

      bool          HasVirt() const;
      TV&           Virt();
      const TV&     Virt() const;

      virtual Rw11Virt*  VirtBase() const;
      virtual bool  Attach(const std::string& url, RerrMsg& emsg);
      virtual void  Detach();

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    protected:
      std::unique_ptr<TV> fupVirt;

  };
  
} // end namespace Retro

#include "Rw11UnitVirt.ipp"

#endif
