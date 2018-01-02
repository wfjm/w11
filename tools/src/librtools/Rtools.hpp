// $Id: Rtools.hpp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2011-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-02-18   852   1.0.6  remove TimeOfDayAsDouble()
// 2017-02-11   850   1.0.5  add Word2Bytes() and Bytes2Word()
// 2014-11-23   606   1.0.4  add TimeOfDayAsDouble()
// 2013-05-04   516   1.0.3  add CreateBackupFile(), String2Long()
// 2013-02-13   481   1.0.2  remove ThrowLogic(), ThrowRuntime()
// 2011-04-10   376   1.0.1  add ThrowLogic(), ThrowRuntime()
// 2011-03-12   368   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Declaration of class Rtools .
*/

#ifndef included_Retro_Rtools
#define included_Retro_Rtools 1

#include <cstdint>
#include <string>

#include "RerrMsg.hpp"
#include "RparseUrl.hpp"

namespace Retro {

  struct RflagName {
    uint32_t      mask;
    const char*   name;
  };  

  namespace Rtools {
    std::string     Flags2String(uint32_t flags, const RflagName* fnam, 
                                 char delim='|');

    bool            String2Long(const std::string& str, long& res, 
                                RerrMsg& emsg, int base=10);
    bool            String2Long(const std::string& str, unsigned long& res, 
                                RerrMsg& emsg, int base=10);
    
    bool            CreateBackupFile(const std::string& fname, size_t nbackup, 
                                     RerrMsg& emsg);
    bool            CreateBackupFile(const RparseUrl& purl, RerrMsg& emsg);

    void            Word2Bytes(uint16_t word, uint16_t& byte0, uint16_t& byte1);
    uint16_t        Bytes2Word(uint16_t byte0, uint16_t byte1);

  } // end namespace Rtools

} // end namespace Retro

#include "Rtools.ipp"

#endif
