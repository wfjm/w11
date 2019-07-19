// $Id: RlinkPortFifo.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-03-27   374   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------


/*!
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

//#include "RlinkPortFifo.ipp"

#endif
