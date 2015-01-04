// $Id: RlinkCommandExpect.hpp 616 2014-12-21 10:09:25Z mueller $
//
// Copyright 2011-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-12-20   616   1.1    add Done count methods (for rblk/wblk)
// 2011-03-12   368   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkCommandExpect.hpp 616 2014-12-21 10:09:25Z mueller $
  \brief   Declaration of class RlinkCommandExpect.
*/

#ifndef included_Retro_RlinkCommandExpect
#define included_Retro_RlinkCommandExpect 1

#include <cstdint>
#include <vector>

namespace Retro {

  class RlinkCommandExpect {
    public:

                    RlinkCommandExpect();
      explicit      RlinkCommandExpect(uint8_t stat, uint8_t statmsk=0);
                    RlinkCommandExpect(uint8_t stat, uint8_t statmsk,
                                       uint16_t data, uint16_t datamsk=0);
                    RlinkCommandExpect(uint8_t stat, uint8_t statmsk,
                                       const std::vector<uint16_t>& block);
                    RlinkCommandExpect(uint8_t stat, uint8_t statmsk,
                                       const std::vector<uint16_t>& block,
                                       const std::vector<uint16_t>& blockmsk);
                   ~RlinkCommandExpect();

      void          SetStatus(uint8_t stat, uint8_t statmsk=0);
      void          SetData(uint16_t data, uint16_t datamsk=0);
      void          SetDone(uint16_t done, bool check=true);
      void          SetBlock(const std::vector<uint16_t>& block);
      void          SetBlock(const std::vector<uint16_t>& block,
                             const std::vector<uint16_t>& blockmsk);

      uint8_t       StatusValue() const;
      uint8_t       StatusMask() const;
      uint16_t      DataValue() const;
      uint16_t      DataMask() const;
      uint16_t      DoneValue() const;
      const std::vector<uint16_t>& BlockValue() const;
      const std::vector<uint16_t>& BlockMask() const;

      bool          StatusCheck(uint8_t val) const;
      bool          DataCheck(uint16_t val) const;
      bool          DoneCheck(uint16_t val) const;
      bool          BlockCheck(size_t ind, uint16_t val) const;
      size_t        BlockCheck(const uint16_t* pval, size_t size) const;

      bool          StatusIsChecked() const;
      bool          DataIsChecked() const;
      bool          DoneIsChecked() const;
      bool          BlockIsChecked(size_t ind) const;

      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;
    
    protected: 
      uint8_t       fStatusVal;             //!< status value
      uint8_t       fStatusMsk;             //!< status mask
      uint16_t      fDataVal;               //!< data value
      uint16_t      fDataMsk;               //!< data mask
      std::vector<uint16_t> fBlockVal;      //!< block value
      std::vector<uint16_t> fBlockMsk;      //!< block mask
  };
  
} // end namespace Retro

#include "RlinkCommandExpect.ipp"

#endif
