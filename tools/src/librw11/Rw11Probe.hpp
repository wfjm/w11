// $Id: Rw11Probe.hpp 868 2017-04-07 20:09:33Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2017-02-04   848   1.1    Keep probe data; add DataInt(), DataRem()
// 2013-03-05   495   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11Probe.hpp 868 2017-04-07 20:09:33Z mueller $
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

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;
  };
  
} // end namespace Retro

#include "Rw11Probe.ipp"

#endif
