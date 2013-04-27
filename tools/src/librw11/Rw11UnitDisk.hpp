// $Id: Rw11UnitDisk.hpp 509 2013-04-21 20:46:20Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-04-19   507   1.0    Initial version
// 2013-02-19   490   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11UnitDisk.hpp 509 2013-04-21 20:46:20Z mueller $
  \brief   Declaration of class Rw11UnitDisk.
*/

#ifndef included_Retro_Rw11UnitDisk
#define included_Retro_Rw11UnitDisk 1

#include "Rw11VirtDisk.hpp"

#include "Rw11UnitVirt.hpp"

namespace Retro {

  class Rw11UnitDisk : public Rw11UnitVirt<Rw11VirtDisk> {
    public:
                    Rw11UnitDisk(Rw11Cntl* pcntl, size_t index);
                   ~Rw11UnitDisk();

      virtual void  SetType(const std::string& type);

      const std::string& Type() const;
      size_t        NCylinder() const;
      size_t        NHead() const;
      size_t        NSector() const;
      size_t        BlockSize() const;
      size_t        NBlock() const;

      uint32_t      Chs2Lba(uint16_t cy, uint16_t hd, uint16_t se);
      void          Lba2Chs(uint32_t lba, uint16_t& cy, uint16_t& hd, 
                            uint16_t& se);

      void          SetWProt(bool wprot);
      bool          WProt() const;

      bool          VirtRead(size_t lba, size_t nblk, uint8_t* data, 
                             RerrMsg& emsg);
      bool          VirtWrite(size_t lba, size_t nblk, const uint8_t* data, 
                              RerrMsg& emsg);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected:
      std::string   fType;
      size_t        fNCyl;
      size_t        fNHead;
      size_t        fNSect;
      size_t        fBlksize;
      size_t        fNBlock;
      bool          fWProt;
  };
  
} // end namespace Retro

#include "Rw11UnitDisk.ipp"

#endif
