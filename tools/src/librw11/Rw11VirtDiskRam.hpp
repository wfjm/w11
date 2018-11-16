// $Id: Rw11VirtDiskRam.hpp 1066 2018-11-10 11:21:53Z mueller $
//
// Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-10-28  1063   1.0    Initial version
// 2018-10-27  1061   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
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
    
      pattyp        fPatTyp;                //!< pattern type
      bmap_t        fBlkMap;
  };
  
} // end namespace Retro

//#include "Rw11VirtDiskRam.ipp"

#endif
