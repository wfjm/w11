// $Id: Rw11VirtTermPty.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-03-06   495   1.0    Initial version
// 2013-02-24   492   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11VirtTermPty.
*/

#ifndef included_Retro_Rw11VirtTermPty
#define included_Retro_Rw11VirtTermPty 1

#include <poll.h>

#include "Rw11VirtTerm.hpp"

namespace Retro {

  class Rw11VirtTermPty : public Rw11VirtTerm {
    public:

      explicit      Rw11VirtTermPty(Rw11Unit* punit);
                   ~Rw11VirtTermPty();

      virtual bool  Open(const std::string& url, RerrMsg& emsg);

      virtual bool  Snd(const uint8_t* data, size_t count, RerrMsg& emsg);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    protected:
      int           RcvPollHandler(const pollfd& pfd);

    protected:
      int           fFd;                    //!< fd for pty master side 
  };
  
} // end namespace Retro

//#include "Rw11VirtTermPty.ipp"

#endif
