// $Id: Rw11VirtDiskFile.hpp 1167 2019-06-20 10:17:11Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-21  1167   1.1    use RfileFd; remove dtor
// 2017-04-15   875   1.0.2  Open(): add overload with scheme handling
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-04-14   506   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rw11VirtDiskFile.
*/

#ifndef included_Retro_Rw11VirtDiskFile
#define included_Retro_Rw11VirtDiskFile 1

#include "librtools/RfileFd.hpp"

#include "Rw11VirtDisk.hpp"

namespace Retro {

  class Rw11VirtDiskFile : public Rw11VirtDisk {
    public:

      explicit      Rw11VirtDiskFile(Rw11Unit* punit);

      virtual bool  Open(const std::string& url, RerrMsg& emsg);
      bool          Open(const std::string& url, const std::string& scheme,
                         RerrMsg& emsg);

      virtual bool  Read(size_t lba, size_t nblk, uint8_t* data, 
                         RerrMsg& emsg);
      virtual bool  Write(size_t lba, size_t nblk, const uint8_t* data, 
                          RerrMsg& emsg);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // statistics counter indices (now new)
      enum stats {
        kDimStat = Rw11VirtDisk::kDimStat
      };

    protected:
      RfileFd       fFd;
      size_t        fSize;
  };
  
} // end namespace Retro

//#include "Rw11VirtDiskFile.ipp"

#endif
