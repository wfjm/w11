// $Id: RlinkCommandList.cpp 1077 2018-12-07 19:37:03Z mueller $
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
// 2018-12-07  1077   1.4.1  SetLastExpectBlock: add move versions
// 2018-12-01  1076   1.4    use unique_ptr
// 2018-10-28  1062   1.3.3  replace boost/foreach
// 2018-09-16  1047   1.3.2  coverity fixup (uninitialized scalar)
// 2017-04-02   865   1.3.1  Dump(): add detail arg
// 2015-04-02   661   1.3    expect logic: add SetLastExpect methods
// 2014-11-23   606   1.2    new rlink v4 iface
// 2014-08-02   576   1.1    rename LastExpect->SetLastExpect
// 2013-05-06   495   1.0.3  add RlinkContext to Print() args
// 2013-02-03   481   1.0.2  use Rexception
// 2011-04-25   380   1.0.1  use boost/foreach
// 2011-03-05   366   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of class RlinkCommandList.
 */

#include <string>

#include "RlinkCommandList.hpp"

#include "librtools/RosPrintf.hpp"
#include "librtools/RosFill.hpp"
#include "librtools/Rexception.hpp"

using namespace std;

/*!
  \class Retro::RlinkCommandList
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkCommandList::RlinkCommandList()
  : fList(),
    fLaboIndex(-1)
{
  fList.reserve(16);                        // should prevent most re-alloc's
}

//------------------------------------------+-----------------------------------
//! Copy constructor

RlinkCommandList::RlinkCommandList(const RlinkCommandList& rhs)
  : fList(),
    fLaboIndex(-1)
{
  operator=(rhs);
}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkCommandList::~RlinkCommandList()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddCommand(cmd_uptr_t&& upcmd)
{
  size_t ind = fList.size();
  fList.push_back(move(upcmd));
  return ind;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddCommand(const RlinkCommand& cmd)
{
  return AddCommand(cmd_uptr_t(new RlinkCommand(cmd)));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddCommand(const RlinkCommandList& clist)
{
  size_t ind = fList.size();
  for (auto& upcmd: clist.fList) AddCommand(*upcmd);
  return ind;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddRreg(uint16_t addr)
{
  cmd_uptr_t upcmd(new RlinkCommand());
  upcmd->CmdRreg(addr);
  return AddCommand(move(upcmd));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddRblk(uint16_t addr, size_t size)
{
  cmd_uptr_t upcmd(new RlinkCommand());
  upcmd->CmdRblk(addr, size);
  return AddCommand(move(upcmd));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddRblk(uint16_t addr, uint16_t* block, size_t size)
{
  cmd_uptr_t upcmd(new RlinkCommand());
  upcmd->CmdRblk(addr, block, size);
  return AddCommand(move(upcmd));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddWreg(uint16_t addr, uint16_t data)
{
  cmd_uptr_t upcmd(new RlinkCommand());
  upcmd->CmdWreg(addr, data);
  return AddCommand(move(upcmd));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddWblk(uint16_t addr, std::vector<uint16_t> block)
{
  cmd_uptr_t upcmd(new RlinkCommand());
  upcmd->CmdWblk(addr, block);
  return AddCommand(move(upcmd));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddWblk(uint16_t addr, const uint16_t* block,
                                 size_t size)
{
  cmd_uptr_t upcmd(new RlinkCommand());
  upcmd->CmdWblk(addr, block, size);
  return AddCommand(move(upcmd));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddLabo()
{
  cmd_uptr_t upcmd(new RlinkCommand());
  upcmd->CmdLabo();
  return AddCommand(move(upcmd));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddAttn()
{
  cmd_uptr_t upcmd(new RlinkCommand());
  upcmd->CmdAttn();
  return AddCommand(move(upcmd));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddInit(uint16_t addr, uint16_t data)
{
  cmd_uptr_t upcmd(new RlinkCommand());
  upcmd->CmdInit(addr, data);
  return AddCommand(move(upcmd));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::SetLastExpectStatus(uint8_t stat, uint8_t statmsk)
{
  if (fList.empty())
    throw Rexception("RlinkCommandList::SetLastExpectStatus()",
                     "Bad state: list empty");
  fList.back()->SetExpectStatus(stat, statmsk);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::SetLastExpectData(uint16_t data, uint16_t datamsk)
{
  if (fList.empty())
    throw Rexception("RlinkCommandList::SetLastExpectData()",
                     "Bad state: list empty");
  RlinkCommand& cmd = *fList.back();
  cmd.EnsureExpect().SetData(data, datamsk);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::SetLastExpectDone(uint16_t done)
{
  if (fList.empty())
    throw Rexception("RlinkCommandList::SetLastExpectDone()",
                     "Bad state: list empty");
  RlinkCommand& cmd = *fList.back();
  cmd.EnsureExpect().SetDone(done);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::SetLastExpectBlock(const std::vector<uint16_t>& block)
{
  if (fList.empty())
    throw Rexception("RlinkCommandList::SetLastExpectBlock()",
                     "Bad state: list empty");
  RlinkCommand& cmd = *fList.back();
  cmd.EnsureExpect().SetBlock(block);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::SetLastExpectBlock(std::vector<uint16_t>&& block)
{
  if (fList.empty())
    throw Rexception("RlinkCommandList::SetLastExpectBlock()",
                     "Bad state: list empty");
  RlinkCommand& cmd = *fList.back();
  cmd.EnsureExpect().SetBlock(move(block));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::SetLastExpectBlock(const std::vector<uint16_t>& block,
                                          const std::vector<uint16_t>& blockmsk)
{
  if (fList.empty())
    throw Rexception("RlinkCommandList::SetLastExpectBlock()",
                     "Bad state: list empty");
  RlinkCommand& cmd = *fList.back();
  cmd.EnsureExpect().SetBlock(block, blockmsk);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::SetLastExpectBlock(std::vector<uint16_t>&& block,
                                          std::vector<uint16_t>&& blockmsk)
{
  if (fList.empty())
    throw Rexception("RlinkCommandList::SetLastExpectBlock()",
                     "Bad state: list empty");
  RlinkCommand& cmd = *fList.back();
  cmd.EnsureExpect().SetBlock(move(block), move(blockmsk));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::SetLastExpect(exp_uptr_t&& upexp)
{
  if (fList.empty())
    throw Rexception("RlinkCommandList::SetLastExpect()",
                     "Bad state: list empty");
  fList.back()->SetExpect(move(upexp));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::Clear()
{
  fList.clear();
  fLaboIndex = -1;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::Print(std::ostream& os, 
                             const RlinkAddrMap* pamap, size_t abase, 
                             size_t dbase, size_t sbase) const
{
  for (auto& upcmd: fList) upcmd->Print(os, pamap, abase, dbase, sbase);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::Dump(std::ostream& os, int ind, const char* text,
                            int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkCommandList @ " << this << endl;

  os << bl << "  fLaboIndex:      " << fLaboIndex << endl;
  for (size_t i=0; i<Size(); i++) {
    if (detail >= 0) {                      // full dump
      string pref("fList[");
      pref << RosPrintf(i) << RosPrintf("]: ");
      fList[i]->Dump(os, ind+2, pref.c_str());
    } else {                                // compact dump
      os << bl << "  [" << RosPrintf(i,"d",2) << "]: " 
         << fList[i]->CommandInfo() << endl;
    }
  }
  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlinkCommandList& 
  Retro::RlinkCommandList::operator=( const RlinkCommandList& rhs)
{
  if (&rhs == this) return *this;

  fList.clear();
  for (auto& upcmd: rhs.fList) AddCommand(*upcmd);
  fLaboIndex = rhs.fLaboIndex;
  return *this;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Retro::RlinkCommand& Retro::RlinkCommandList::operator[](size_t ind)
{
  return *fList.at(ind);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

const Retro::RlinkCommand& Retro::RlinkCommandList::operator[](size_t ind) const
{
  return *fList.at(ind);
}

} // end namespace Retro
