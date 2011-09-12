// $Id: RlinkCommandList.cpp 380 2011-04-25 18:14:52Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-04-25   380   1.0.1  use boost/foreach
// 2011-03-05   366   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkCommandList.cpp 380 2011-04-25 18:14:52Z mueller $
  \brief   Implemenation of class RlinkCommandList.
 */

#include <string>
#include <stdexcept>

#include "boost/foreach.hpp"
#define foreach BOOST_FOREACH

#include "RlinkCommandList.hpp"

#include "librtools/RosPrintf.hpp"
#include "librtools/RosFill.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::RlinkCommandList
  \brief FIXME_docs
*/

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkCommandList::RlinkCommandList()
  : fList() 
{
  fList.reserve(16);                        // should prevent most re-alloc's
}

//------------------------------------------+-----------------------------------
//! Copy constructor

RlinkCommandList::RlinkCommandList(const RlinkCommandList& rhs)
  : fList()
{
  operator=(rhs);
}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkCommandList::~RlinkCommandList()
{
  foreach (RlinkCommand* pcmd, fList) { delete pcmd; }
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddCommand(RlinkCommand* cmd)
{
  size_t ind = fList.size();
  fList.push_back(cmd);
  return ind;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddCommand(const RlinkCommand& cmd)
{
  return AddCommand(new RlinkCommand(cmd));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddCommand(const RlinkCommandList& clist)
{
  size_t ind = fList.size();
  for (size_t i=0; i<clist.Size(); i++) {
    AddCommand(new RlinkCommand(clist[i]));
  }
  return ind;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddRreg(uint16_t addr)
{
  RlinkCommand* pcmd = new RlinkCommand();
  pcmd->CmdRreg(addr);
  return AddCommand(pcmd);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddRblk(uint16_t addr, size_t size)
{
  RlinkCommand* pcmd = new RlinkCommand();
  pcmd->CmdRblk(addr, size);
  return AddCommand(pcmd);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddRblk(uint16_t addr, uint16_t* block, size_t size)
{
  RlinkCommand* pcmd = new RlinkCommand();
  pcmd->CmdRblk(addr, block, size);
  return AddCommand(pcmd);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddWreg(uint16_t addr, uint16_t data)
{
  RlinkCommand* pcmd = new RlinkCommand();
  pcmd->CmdWreg(addr, data);
  return AddCommand(pcmd);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddWblk(uint16_t addr, std::vector<uint16_t> block)
{
  RlinkCommand* pcmd = new RlinkCommand();
  pcmd->CmdWblk(addr, block);
  return AddCommand(pcmd);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddWblk(uint16_t addr, const uint16_t* block,
                                 size_t size)
{
  RlinkCommand* pcmd = new RlinkCommand();
  pcmd->CmdWblk(addr, block, size);
  return AddCommand(pcmd);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddStat()
{
  RlinkCommand* pcmd = new RlinkCommand();
  pcmd->CmdStat();
  return AddCommand(pcmd);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddAttn()
{
  RlinkCommand* pcmd = new RlinkCommand();
  pcmd->CmdAttn();
  return AddCommand(pcmd);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkCommandList::AddInit(uint16_t addr, uint16_t data)
{
  RlinkCommand* pcmd = new RlinkCommand();
  pcmd->CmdInit(addr, data);
  return AddCommand(pcmd);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::LastVolatile()
{
  if (fList.size() == 0)
    throw out_of_range("RlinkCommandList::LastExpect: list empty");
  fList[fList.size()-1]->SetFlagBit(RlinkCommand::kFlagVol);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::LastExpect(RlinkCommandExpect* exp)
{
  if (fList.size() == 0)
    throw out_of_range("RlinkCommandList::LastExpect: list empty");
  fList[fList.size()-1]->SetExpect(exp);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::Clear()
{
  
  fList.clear();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::Print(std::ostream& os, const RlinkAddrMap* pamap, 
                             size_t abase, size_t dbase, size_t sbase) const
{
  foreach (RlinkCommand* pcmd, fList) {
    pcmd->Print(os, pamap, abase, dbase, sbase);
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkCommandList::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkCommandList @ " << this << endl;

  for (size_t i=0; i<Size(); i++) {
    string pref("fList[");
    pref << RosPrintf(i) << RosPrintf("]: ");
    fList[i]->Dump(os, ind+2, pref.c_str());
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlinkCommandList& 
  Retro::RlinkCommandList::operator=( const RlinkCommandList& rhs)
{
  if (&rhs == this) return *this;
  
  foreach (RlinkCommand* pcmd, fList) { delete pcmd; }
  fList.clear();
  for (size_t i=0; i<rhs.Size(); i++) AddCommand(rhs[i]);
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

//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_RlinkCommandList_NoInline))
#define inline
#include "RlinkCommandList.ipp"
#undef  inline
#endif
