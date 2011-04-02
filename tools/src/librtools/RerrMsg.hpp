// $Id: RerrMsg.hpp 359 2011-02-06 22:37:43Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-02-06   359   1.1    use references in interface
// 2011-01-15   356   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RerrMsg.hpp 359 2011-02-06 22:37:43Z mueller $
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

      void          Grab(RerrMsg& rhs);

      RerrMsg&      operator=(const RerrMsg& rhs);
                    operator std::string() const;

    protected:
      std::string   fMeth;                  //!< originating method
      std::string   fText;                  //!< message text
  };

  std::ostream&	    operator<<(std::ostream& os, const RerrMsg& obj);

} // end namespace Retro

#if !(defined(Retro_NoInline) || defined(Retro_RerrMsg_NoInline))
#include "RerrMsg.ipp"
#endif

#endif
