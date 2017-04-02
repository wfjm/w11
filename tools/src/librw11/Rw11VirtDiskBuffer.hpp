// $Id: Rw11VirtDiskBuffer.hpp 859 2017-03-11 22:36:45Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-03-10   859   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11VirtDiskBuffer.hpp 859 2017-03-11 22:36:45Z mueller $
  \brief   Declaration of class Rw11VirtDiskBuffer.
*/

#ifndef included_Retro_Rw11VirtDiskBuffer
#define included_Retro_Rw11VirtDiskBuffer 1

#include <cstdint>
#include <vector>

namespace Retro {

  class Rw11VirtDiskBuffer {
    public:

      explicit      Rw11VirtDiskBuffer(size_t blksize);
                   ~Rw11VirtDiskBuffer();

      void          Read(uint8_t* data);
      void          Write(const uint8_t* data);

      size_t        BlockSize() const;
      uint8_t*      Data();
      const uint8_t* Data() const;
      uint32_t      NWrite() const;

    protected:
      std::vector<uint8_t> fBuf;
      uint32_t      fNWrite;
  };
  
} // end namespace Retro

#include "Rw11VirtDiskBuffer.ipp"

#endif
