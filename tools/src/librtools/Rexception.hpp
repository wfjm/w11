// $Id: Rexception.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-10-27  1060   1.3    drop throw() list; use noexcept
// 2017-04-29   888   1.2    BUGFIX: add fErrtxt for proper what() return
// 2014-12-30   625   1.1    add ctor(meth,text,emsg)
// 2013-02-12   487   1.0.1  add ErrMsg() getter
// 2013-01-12   474   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
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
                   ~Rexception();

      virtual const char* what() const noexcept;
      const RerrMsg& ErrMsg() const;

    protected:
      RerrMsg       fErrmsg;                //!< message object
      std::string   fErrtxt;                //!< message text (for what())
  };

} // end namespace Retro

#include "Rexception.ipp"

#endif
