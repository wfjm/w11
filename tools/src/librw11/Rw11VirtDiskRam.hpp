// $Id: Rw11VirtDiskRam.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2018-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-05-01  1143   1.1    add noboot option 
// 2018-10-28  1063   1.0    Initial version
// 2018-10-27  1061   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11VirtDiskRam.
*/

#ifndef included_Retro_Rw11VirtDiskRam
#define included_Retro_Rw11VirtDiskRam 1

#include <map>

#include "Rw11VirtDiskBuffer.hpp"

#include "Rw11VirtDisk.hpp"

namespace Retro {

  class Rw11VirtDiskRam : public Rw11VirtDisk {
    public:

      typedef std::map<uint32_t,Rw11VirtDiskBuffer> bmap_t;

      explicit      Rw11VirtDiskRam(Rw11Unit* punit);
                   ~Rw11VirtDiskRam();
    
      virtual bool  Open(const std::string& url, RerrMsg& emsg);
      bool          Open(const std::string& url, const std::string& scheme,
                         RerrMsg& emsg);

      virtual bool  Read(size_t lba, size_t nblk, uint8_t* data, 
                         RerrMsg& emsg);
      virtual bool  Write(size_t lba, size_t nblk, const uint8_t* data, 
                          RerrMsg& emsg);

      void          List(std::ostream& os) const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // statistics counter indices (now new)
      enum stats {
        kStatNVDReadRam = Rw11VirtDisk::kDimStat,
        kStatNVDWriteOver,
        kDimStat
      };

    protected:
      void          ReadPattern(size_t lba, uint8_t* data);
    
    protected:
      enum pattyp {
        kPatZero = 0,
        kPatOnes,
        kPatDead,
        kPatTest
      };
    
      bool          fNoBoot;
      pattyp        fPatTyp;                //!< pattern type
      bmap_t        fBlkMap;
  };
  
} // end namespace Retro

//#include "Rw11VirtDiskRam.ipp"

#endif
