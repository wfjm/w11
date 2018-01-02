// $Id: ReventFd.hpp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-01-14   475   1.0    Initial version
// 2013-01-11   473   0.5    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class \c ReventFd.
*/

#ifndef included_Retro_ReventFd
#define included_Retro_ReventFd 1

#include "boost/utility.hpp"

namespace Retro {

  class ReventFd : private boost::noncopyable {
    public:
                    ReventFd();
      virtual      ~ReventFd();

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
