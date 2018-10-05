// $Id: Rw11VirtEthTap.hpp 1052 2018-09-30 08:10:52Z mueller $
//
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-15   875   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rw11VirtEthTap.
*/

#ifndef included_Retro_Rw11VirtEthTap
#define included_Retro_Rw11VirtEthTap 1

#include <poll.h>

#include "Rw11VirtEth.hpp"

namespace Retro {

  class Rw11VirtEthTap : public Rw11VirtEth {
    public:

      explicit      Rw11VirtEthTap(Rw11Unit* punit);
                   ~Rw11VirtEthTap();

      virtual bool  Open(const std::string& url, RerrMsg& emsg);

      virtual bool  Snd(const RethBuf& ebuf, RerrMsg& emsg);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    protected:
      int           RcvPollHandler(const pollfd& pfd);

    protected:
      int           fFd;                    //!< fd for pty master side 
  };
  
} // end namespace Retro

//#include "Rw11VirtEthTap.ipp"

#endif
