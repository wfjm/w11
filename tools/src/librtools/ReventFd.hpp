// $Id: ReventFd.hpp 1185 2019-07-12 17:29:12Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-08  1161   1.1    derive from Rfd, inherit Fd
// 2018-12-16  1084   1.0.1  use =delete for noncopyable instead of boost
// 2013-01-14   475   1.0    Initial version
// 2013-01-11   473   0.5    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class \c ReventFd.
*/

#ifndef included_Retro_ReventFd
#define included_Retro_ReventFd 1

#include "Rfd.hpp"

namespace Retro {

  class ReventFd : public Rfd {
    public:
                    ReventFd();
      explicit      ReventFd(const char* cnam);

                    ReventFd(const ReventFd&) = delete;   // noncopyable 
      ReventFd&     operator=(const ReventFd&) = delete;  // noncopyable

      void          Signal(uint64_t val=1);
      uint64_t      Wait();
};
  
} // end namespace Retro

//#include "ReventFd.ipp"

#endif
