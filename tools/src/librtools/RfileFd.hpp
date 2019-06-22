// $Id: RfileFd.hpp 1167 2019-06-20 10:17:11Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-15  1163   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class \c RfileFd.
*/

#ifndef included_Retro_RfileFd
#define included_Retro_RfileFd 1

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "Rfd.hpp"
#include "RerrMsg.hpp"


namespace Retro {

  class RfileFd : public Rfd {
    public:
                    RfileFd();
      explicit      RfileFd(const char* cnam);
    
                    RfileFd(const RfileFd&) = delete;    // noncopyable 
      RfileFd&      operator=(const RfileFd&) = delete;  // noncopyable

      bool          Open(const char* fname, int flags, RerrMsg& emsg);
      bool          Stat(struct stat *sbuf, RerrMsg& emsg);
      off_t         Seek(off_t offset, int whence, RerrMsg& emsg);
      bool          Truncate(off_t length, RerrMsg& emsg);
      ssize_t       Read(void *buf, size_t count, RerrMsg& emsg);
      bool          WriteAll(const void *buf, size_t count, RerrMsg& emsg);

};
  
} // end namespace Retro

//#include "RfileFd.ipp"

#endif
