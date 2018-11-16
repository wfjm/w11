// $Id: Rw11VirtDiskOver.hpp 1066 2018-11-10 11:21:53Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-06-05   907   1.0.2  more detailed stats
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2017-03-10   859   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rw11VirtDiskOver.
*/

#ifndef included_Retro_Rw11VirtDiskOver
#define included_Retro_Rw11VirtDiskOver 1

#include <map>

#include "Rw11VirtDiskBuffer.hpp"

#include "Rw11VirtDiskFile.hpp"

namespace Retro {

  class Rw11VirtDiskOver : public Rw11VirtDiskFile {
    public:

      typedef std::map<uint32_t,Rw11VirtDiskBuffer> bmap_t;

      explicit      Rw11VirtDiskOver(Rw11Unit* punit);
                   ~Rw11VirtDiskOver();

      virtual bool  WProt() const;

      virtual bool  Open(const std::string& url, RerrMsg& emsg);

      virtual bool  Read(size_t lba, size_t nblk, uint8_t* data, 
                         RerrMsg& emsg);
      virtual bool  Write(size_t lba, size_t nblk, const uint8_t* data, 
                          RerrMsg& emsg);

      bool          Flush(RerrMsg& emsg);
      void          List(std::ostream& os) const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // statistics counter indices (now new)
      enum stats {
        kStatNVDORead = Rw11VirtDiskFile::kDimStat,
        kStatNVDOReadBlkFF,
        kStatNVDOReadBlkFP,
        kStatNVDOReadBlkO,
        kStatNVDOWrite,
        kStatNVDOWriteBlk,
        kStatNVDOFlush,
        kDimStat
      };    

    protected:
      bmap_t        fBlkMap;
  };
  
} // end namespace Retro

//#include "Rw11VirtDiskOver.ipp"

#endif
