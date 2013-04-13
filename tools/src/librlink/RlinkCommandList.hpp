// $Id: RlinkCommandList.hpp 495 2013-03-06 17:13:48Z mueller $
//
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-05-06   495   1.0.1  add RlinkContext to Print() args; drop oper<<()
// 2011-03-05   366   1.0    Initial version
// 2011-01-09   354   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkCommandList.hpp 495 2013-03-06 17:13:48Z mueller $
  \brief   Declaration of class RlinkCommandList.
*/

#ifndef included_Retro_RlinkCommandList
#define included_Retro_RlinkCommandList 1

#include <cstddef>
#include <cstdint>
#include <vector>
#include <iostream>

#include "RlinkCommandExpect.hpp"
#include "RlinkCommand.hpp"
#include "RlinkContext.hpp"
#include "RlinkAddrMap.hpp"

namespace Retro {

  class RlinkCommandList {
    public:

                    RlinkCommandList();
                    RlinkCommandList(const RlinkCommandList&);
                   ~RlinkCommandList();

      size_t        AddCommand(RlinkCommand* cmd);
      size_t        AddCommand(const RlinkCommand& cmd);
      size_t        AddCommand(const RlinkCommandList& clist);
      size_t        AddRreg(uint16_t addr);
      size_t        AddRblk(uint16_t addr, size_t size);
      size_t        AddRblk(uint16_t addr, uint16_t* block, size_t size);
      size_t        AddWreg(uint16_t addr, uint16_t data);
      size_t        AddWblk(uint16_t addr, std::vector<uint16_t> block);
      size_t        AddWblk(uint16_t addr, const uint16_t* block, size_t size);
      size_t        AddStat();
      size_t        AddAttn();
      size_t        AddInit(uint16_t addr, uint16_t data);

      void          LastVolatile();
      void          LastExpect(RlinkCommandExpect* exp);
    
      void          Clear();
      size_t        Size() const;

      void          Print(std::ostream& os, const RlinkContext& cntx,
                          const RlinkAddrMap* pamap=0, size_t abase=16, 
                          size_t dbase=16, size_t sbase=16) const;
      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;

      RlinkCommandList& operator=(const RlinkCommandList& rhs);

      RlinkCommand& operator[](size_t ind);
      const RlinkCommand& operator[](size_t ind) const;

    protected: 
      std::vector<RlinkCommand*> fList;     //!< vector of commands 
  };

} // end namespace Retro

#include "RlinkCommandList.ipp"

#endif
