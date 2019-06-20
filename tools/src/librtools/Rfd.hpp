// $Id: Rfd.hpp 1163 2019-06-15 07:26:57Z mueller $
//
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
