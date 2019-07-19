// $Id: RlinkCommandExpect.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1077   1.2.2  SetBlock: add move versions
// 2017-04-07   868   1.2.1  Dump(): add detail arg
// 2015-04-02   661   1.2    expect logic: remove stat from Expect, invert mask
// 2014-12-20   616   1.1    add Done count methods (for rblk/wblk)
// 2011-03-12   368   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------


/*!
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
                    RlinkCommandExpect(uint16_t data, uint16_t datamsk=0xffff);
                    RlinkCommandExpect(const std::vector<uint16_t>& block);
                    RlinkCommandExpect(const std::vector<uint16_t>& block,
                                       const std::vector<uint16_t>& blockmsk);
                   ~RlinkCommandExpect();

      void          SetData(uint16_t data, uint16_t datamsk=0);
      void          SetDone(uint16_t done, bool check=true);
      void          SetBlock(const std::vector<uint16_t>& block);
      void          SetBlock(std::vector<uint16_t>&& block);
      void          SetBlock(const std::vector<uint16_t>& block,
                             const std::vector<uint16_t>& blockmsk);
      void          SetBlock(std::vector<uint16_t>&& block,
                             std::vector<uint16_t>&& blockmsk);

      uint16_t      DataValue() const;
      uint16_t      DataMask() const;
      uint16_t      DoneValue() const;
      const std::vector<uint16_t>& BlockValue() const;
      const std::vector<uint16_t>& BlockMask() const;

      bool          DataCheck(uint16_t val) const;
      bool          DoneCheck(uint16_t val) const;
      bool          BlockCheck(size_t ind, uint16_t val) const;
      size_t        BlockCheck(const uint16_t* pval, size_t size) const;

      bool          DataIsChecked() const;
      bool          DoneIsChecked() const;
      bool          BlockIsChecked(size_t ind) const;

      void          Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;
    
    protected: 
      uint16_t      fDataVal;               //!< data value
      uint16_t      fDataMsk;               //!< data mask
      std::vector<uint16_t> fBlockVal;      //!< block value
      std::vector<uint16_t> fBlockMsk;      //!< block mask
  };
  
} // end namespace Retro

#include "RlinkCommandExpect.ipp"

#endif
