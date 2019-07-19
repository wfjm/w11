// $Id: Rw11CpuW11a.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2014-12-25   621   1.1    adopt to 4k word ibus window
// 2013-03-03   494   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11CpuW11a.
*/

#ifndef included_Retro_Rw11CpuW11a
#define included_Retro_Rw11CpuW11a 1

#include "Rw11Cpu.hpp"

namespace Retro {

  class Rw11CpuW11a : public Rw11Cpu {
    public:

                    Rw11CpuW11a();
                   ~Rw11CpuW11a();

      void          Setup(size_t ind, uint16_t base, uint16_t ibase);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;
 
    protected:
  };
  
} // end namespace Retro

//#include "Rw11CpuW11a.ipp"

#endif
