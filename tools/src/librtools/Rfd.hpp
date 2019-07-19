// $Id: Rfd.hpp 1185 2019-07-12 17:29:12Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-15  1163   1.0.1  SetFd() now type bool
// 2019-06-07  1161   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class \c Rfd.
*/

#ifndef included_Retro_Rfd
#define included_Retro_Rfd 1

#include <string>

#include "RerrMsg.hpp"

namespace Retro {

  class Rfd {
    public:
                    Rfd();
                    Rfd(Rfd&& rhs);                  // move ctor 
      explicit      Rfd(const char* cnam);
      virtual      ~Rfd();
    
                    Rfd(const Rfd&) = delete;        // noncopyable 
      Rfd&          operator=(const Rfd&) = delete;  // noncopyable

      bool          SetFd(int fd);
      int           Fd() const;

      bool          IsOpen() const;
      bool          IsOpenNonStd() const;
      void          Close();
      bool          Close(RerrMsg& emsg);
      void          CloseOrCerr();

      explicit      operator bool() const;

    protected:

      int           fFd;
      std::string   fCnam;
};
  
} // end namespace Retro

#include "Rfd.ipp"

#endif
