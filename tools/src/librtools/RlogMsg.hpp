// $Id: RlogMsg.hpp 1084 2018-12-16 12:23:53Z mueller $
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
// 2013-02-22   490   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Declaration of class RlogMsg.
*/

#ifndef included_Retro_RlogMsg
#define included_Retro_RlogMsg 1

#include <sstream>

namespace Retro {

  class RlogFile;                           // forw decl to avoid circular incl

  class RlogMsg {
    public:
      explicit      RlogMsg(char tag = 0);
                    RlogMsg(RlogFile& lfile, char tag = 0);
                   ~RlogMsg();

                    RlogMsg(const RlogMsg&) = delete;    // noncopyable 
      RlogMsg&      operator=(const RlogMsg&) = delete;  // noncopyable
    
      void          SetTag(char tag);
      void          SetString(const std::string& str);

      char          Tag() const;
      std::string   String() const;

      std::ostream& operator()();

    protected:
      std::stringstream  fStream;                //!< string stream
      RlogFile*     fLfile;
      char          fTag;
  };

  template <class T>
  std::ostream&     operator<<(RlogMsg& lmsg, const T& val);
  
} // end namespace Retro

#include "RlogMsg.ipp"

#endif
