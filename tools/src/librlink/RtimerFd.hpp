// $Id: RtimerFd.hpp 887 2017-04-28 19:32:52Z mueller $
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
// 2017-02-18   852   1.0    Initial version
// 2013-01-11   473   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class \c RtimerFd.
*/

#ifndef included_Retro_RtimerFd
#define included_Retro_RtimerFd 1

#include <time.h>

#include "boost/utility.hpp"

#include "librtools/Rtime.hpp"


namespace Retro {

  class RtimerFd : private boost::noncopyable {
    public:
                    RtimerFd();
      virtual      ~RtimerFd();

      void          Open(clockid_t clkid=CLOCK_MONOTONIC);
      bool          IsOpen() const;
      void          Close();
      void          SetRelative(const Rtime& dt);
      void          SetRelative(double dt);
      void          Cancel();
      uint64_t      Read();

      int           Fd() const;
      explicit      operator bool() const;

    protected:

      int           fFd;
};
  
} // end namespace Retro

#include "RtimerFd.ipp"

#endif
