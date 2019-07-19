// $Id: Rtools.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-10-26  1059   1.0.7  add Catch2Cerr()
// 2017-02-18   852   1.0.6  remove TimeOfDayAsDouble()
// 2017-02-11   850   1.0.5  add Word2Bytes() and Bytes2Word()
// 2014-11-23   606   1.0.4  add TimeOfDayAsDouble()
// 2013-05-04   516   1.0.3  add CreateBackupFile(), String2Long()
// 2013-02-13   481   1.0.2  remove ThrowLogic(), ThrowRuntime()
// 2011-04-10   376   1.0.1  add ThrowLogic(), ThrowRuntime()
// 2011-03-12   368   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of class Rtools .
*/

#ifndef included_Retro_Rtools
#define included_Retro_Rtools 1

#include <cstdint>
#include <string>
#include <functional>

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

    void            Catch2Cerr(const char* msg, std::function<void()> func);

  } // end namespace Rtools

} // end namespace Retro

#include "Rtools.ipp"

#endif
