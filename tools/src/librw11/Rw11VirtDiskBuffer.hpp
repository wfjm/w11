// $Id: Rw11VirtDiskBuffer.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-03-10   859   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
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
