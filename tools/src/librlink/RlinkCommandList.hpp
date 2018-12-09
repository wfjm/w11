// $Id: RlinkCommandList.hpp 1076 2018-12-02 12:45:49Z mueller $
//
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-01  1076   1.4    use unique_ptr
// 2017-04-02   865   1.3.1  Dump(): add detail arg
// 2015-04-02   661   1.3    expect logic: add SetLastExpect methods
// 2014-11-23   606   1.2    new rlink v4 iface
// 2014-08-02   576   1.1    rename LastExpect->SetLastExpect
// 2013-05-06   495   1.0.1  add RlinkContext to Print() args; drop oper<<()
// 2011-03-05   366   1.0    Initial version
// 2011-01-09   354   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class RlinkCommandList.
*/

#ifndef included_Retro_RlinkCommandList
#define included_Retro_RlinkCommandList 1

#include <cstddef>
#include <cstdint>
#include <vector>
#include <iostream>
#include <memory>

#include "RlinkCommandExpect.hpp"
#include "RlinkCommand.hpp"
#include "RlinkContext.hpp"
#include "RlinkAddrMap.hpp"

namespace Retro {

  class RlinkCommandList {
    public:
      typedef std::unique_ptr<RlinkCommand>        cmd_uptr_t;
      typedef std::unique_ptr<RlinkCommandExpect>  exp_uptr_t;

                    RlinkCommandList();
                    RlinkCommandList(const RlinkCommandList&);
                   ~RlinkCommandList();

      size_t        AddCommand(cmd_uptr_t&& upcmd);
      size_t        AddCommand(const RlinkCommand& cmd);
      size_t        AddCommand(const RlinkCommandList& clist);
      size_t        AddRreg(uint16_t addr);
      size_t        AddRblk(uint16_t addr, size_t size);
      size_t        AddRblk(uint16_t addr, uint16_t* block, size_t size);
      size_t        AddWreg(uint16_t addr, uint16_t data);
      size_t        AddWblk(uint16_t addr, std::vector<uint16_t> block);
      size_t        AddWblk(uint16_t addr, const uint16_t* block, size_t size);
      size_t        AddLabo();
      size_t        AddAttn();
      size_t        AddInit(uint16_t addr, uint16_t data);

      void          SetLastExpectStatus(uint8_t stat, uint8_t statmsk=0xff);
      void          SetLastExpectData(uint16_t data, uint16_t datamsk=0xffff);
      void          SetLastExpectDone(uint16_t done);
      void          SetLastExpectBlock(const std::vector<uint16_t>& block);
      void          SetLastExpectBlock(const std::vector<uint16_t>& block,
                                       const std::vector<uint16_t>& blockmsk);
      void          SetLastExpect(exp_uptr_t&& upexp);
    
      void          ClearLaboIndex();
      void          SetLaboIndex(int ind);
      int           LaboIndex() const;
      bool          LaboActive() const;
    
      void          Clear();
      size_t        Size() const;

      void          Print(std::ostream& os, const RlinkAddrMap* pamap=0, 
                          size_t abase=16, size_t dbase=16, 
                          size_t sbase=16) const;
      void          Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

      RlinkCommandList& operator=(const RlinkCommandList& rhs);

      RlinkCommand& operator[](size_t ind);
      const RlinkCommand& operator[](size_t ind) const;

    protected: 
      std::vector<cmd_uptr_t> fList;        //!< vector of commands
      int           fLaboIndex;             //!< index of active labo (-1 if no)
  };

} // end namespace Retro

#include "RlinkCommandList.ipp"

#endif
