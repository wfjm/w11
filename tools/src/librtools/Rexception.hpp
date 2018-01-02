// $Id: Rexception.hpp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-29   888   1.2    BUGFIX: add fErrtxt for proper what() return
// 2014-12-30   625   1.1    add ctor(meth,text,emsg)
// 2013-02-12   487   1.0.1  add ErrMsg() getter
// 2013-01-12   474   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rexception.
*/

#ifndef included_Retro_Rexception
#define included_Retro_Rexception 1

#include <stdexcept>
#include <string>

#include "RerrMsg.hpp"

namespace Retro {

  class Rexception : public std::exception {
    public:
                    Rexception();
                    Rexception(const RerrMsg& errmsg);
                    Rexception(const std::string& meth,
                               const std::string& text);
                    Rexception(const std::string& meth, 
                               const std::string& text, int errnum);
                    Rexception(const std::string& meth, 
                               const std::string& text, const RerrMsg& errmsg);
                   ~Rexception() throw();

      virtual const char* what() const throw();
      const RerrMsg& ErrMsg() const;

    protected:
      RerrMsg       fErrmsg;                //!< message object
      std::string   fErrtxt;                //!< message text (for what())
  };

} // end namespace Retro

#include "Rexception.ipp"

#endif
