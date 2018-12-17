// $Id: ReventFd.hpp 1084 2018-12-16 12:23:53Z mueller $
//
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-16  1084   1.0.1  use =delete for noncopyable instead of boost
// 2013-01-14   475   1.0    Initial version
// 2013-01-11   473   0.5    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class \c ReventFd.
*/

#ifndef included_Retro_ReventFd
#define included_Retro_ReventFd 1

namespace Retro {

  class ReventFd {
    public:
                    ReventFd();
      virtual      ~ReventFd();

                    ReventFd(const ReventFd&) = delete;   // noncopyable 
      ReventFd&     operator=(const ReventFd&) = delete;  // noncopyable

      int           Fd() const;
      int           Signal();
      int           Wait();

      operator      int() const;

      static int    SignalFd(int fd);
      static int    WaitFd(int fd);

    protected:

      int           fFd;
};
  
} // end namespace Retro

#include "ReventFd.ipp"

#endif
