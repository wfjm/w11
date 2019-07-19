// $Id: RerrMsg.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-01-12   474   1.2    add meth+text and meth+text+errnum ctors
// 2011-02-06   359   1.1    use references in interface
// 2011-01-15   356   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RerrMsg.
*/

#ifndef included_Retro_RerrMsg
#define included_Retro_RerrMsg 1

#include <string>
#include <ostream>

namespace Retro {

  class RerrMsg {
    public:
                    RerrMsg();
                    RerrMsg(const RerrMsg& rhs);
                    RerrMsg(const std::string& meth, const std::string& text);
                    RerrMsg(const std::string& meth, const std::string& text,
                            int errnum);
                   ~RerrMsg();

      void          Init(const std::string& meth, const std::string& text);
      void          InitErrno(const std::string& meth, 
                              const std::string& text, int errnum);
      void          InitPrintf(const std::string& meth, 
                               const char* format, ...);

      void          SetMeth(const std::string& meth);
      void          SetText(const std::string& text);

      void          Prepend(const std::string& meth);
      void          Append(const std::string& text);
      void          AppendErrno(int errnum);
      void          AppendPrintf(const char* format, ...);

      const std::string& Meth() const;
      const std::string& Text() const;
      std::string   Message() const;

      void          Swap(RerrMsg& rhs);

      RerrMsg&      operator=(const RerrMsg& rhs);
                    operator std::string() const;

    protected:
      std::string   fMeth;                  //!< originating method
      std::string   fText;                  //!< message text
  };

  std::ostream&	    operator<<(std::ostream& os, const RerrMsg& obj);

} // end namespace Retro

#include "RerrMsg.ipp"

#endif
