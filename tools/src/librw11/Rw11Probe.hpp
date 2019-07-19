// $Id: Rw11Probe.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-22  1091   1.1.2  Dump() not longer virtual (-Wnon-virtual-dtor fix)
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2017-02-04   848   1.1    Keep probe data; add DataInt(), DataRem()
// 2013-03-05   495   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11Probe.
*/

#ifndef included_Retro_Rw11Probe
#define included_Retro_Rw11Probe 1

namespace Retro {

  struct Rw11Probe {
      uint16_t      fAddr;
      bool          fProbeInt;
      bool          fProbeRem;
      bool          fProbeDone;
      bool          fFoundInt;
      bool          fFoundRem;
      uint16_t      fDataInt;
      uint16_t      fDataRem;

      explicit      Rw11Probe(uint16_t addr = 0, bool probeint = false, 
                              bool proberem = false);

      bool          Found() const;

      char          IndicatorInt() const;
      char          IndicatorRem() const;
      uint16_t      DataInt() const;
      uint16_t      DataRem() const;

      void          Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;
  };
  
} // end namespace Retro

#include "Rw11Probe.ipp"

#endif
