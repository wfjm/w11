// $Id: Rtools.hpp 486 2013-02-10 22:34:43Z mueller $
//
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-02-13   481   1.0.2  remove ThrowLogic(), ThrowRuntime()
// 2011-04-10   376   1.0.1  add ThrowLogic(), ThrowRuntime()
// 2011-03-12   368   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rtools.hpp 486 2013-02-10 22:34:43Z mueller $
  \brief   Declaration of class Rtools .
*/

#ifndef included_Retro_Rtools
#define included_Retro_Rtools 1

#include <cstdint>
#include <string>

namespace Retro {

  struct RflagName {
    uint32_t      mask;
    const char*   name;
  };  

  namespace Rtools {
    std::string     Flags2String(uint32_t flags, const RflagName* fnam, 
                                 char delim='|');
  };

} // end namespace Retro

//#include "Rtools.ipp"

#endif
