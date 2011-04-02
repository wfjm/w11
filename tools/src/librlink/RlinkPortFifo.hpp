// $Id: RlinkPortFifo.hpp 375 2011-04-02 07:56:47Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-03-27   374   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkPortFifo.hpp 375 2011-04-02 07:56:47Z mueller $
  \brief   Declaration of class RlinkPortFifo.
*/

#ifndef included_Retro_RlinkPortFifo
#define included_Retro_RlinkPortFifo 1

#include "RlinkPort.hpp"

namespace Retro {

  class RlinkPortFifo : public RlinkPort {
    public:

                    RlinkPortFifo();
      virtual       ~RlinkPortFifo();

      virtual bool  Open(const std::string& url, RerrMsg& emsg);

    private: 
      int           OpenFifo(const std::string&, bool snd, RerrMsg& emsg);

  };
  
} // end namespace Retro

#if !(defined(Retro_NoInline) || defined(Retro_RlinkPortFifo_NoInline))
//#include "RlinkPortFifo.ipp"
#endif

#endif
