// $Id: RlinkAddrMap.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-11-16  1070   1.0.4  use auto; use emplace,make_pair; use range loop
// 2017-04-07   868   1.0.3  Dump(): add detail arg
// 2013-02-03   481   1.0.2  use Rexception
// 2011-11-28   434   1.0.1  Print(): use proper cast for lp64 compatibility
// 2011-03-06   367   1.0    Initial version
// 2011-03-05   366   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of class RlinkAddrMap.
 */

#include <algorithm>

#include "RlinkAddrMap.hpp"

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"

using namespace std;

/*!
  \class Retro::RlinkAddrMap
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkAddrMap::RlinkAddrMap()
  : fNameMap(),
    fAddrMap(),
    fMaxLength(0)
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkAddrMap::~RlinkAddrMap()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkAddrMap::Clear()
{
  fNameMap.clear();
  fAddrMap.clear();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkAddrMap::Insert(const std::string& name, uint16_t addr)
{
  if (fNameMap.find(name) != fNameMap.end()) return false;
  if (fAddrMap.find(addr) != fAddrMap.end()) return false;

  fNameMap.emplace(make_pair(name, addr));
  fAddrMap.emplace(make_pair(addr, name));
  fMaxLength = max(fMaxLength, name.length());

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkAddrMap::Erase(const std::string& name)
{
  auto it = fNameMap.find(name);
  if (it == fNameMap.end()) return false;

  fMaxLength = 0;                           // force recalculate
  if (fNameMap.erase(name) == 0)
    throw Rexception("RlinkAddrMap::Erase()", 
                     "BugCheck: fNameMap erase failed");
  if (fAddrMap.erase(it->second) == 0)
    throw Rexception("RlinkAddrMap::Erase()", 
                     "BugCheck: fAddrMap erase failed");
  
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkAddrMap::Erase(uint16_t addr)
{
  auto it = fAddrMap.find(addr);
  if (it == fAddrMap.end()) return false;

  fMaxLength = 0;                           // force recalculate
  if (fAddrMap.erase(addr) == 0)
    throw Rexception("RlinkAddrMap::Erase()", 
                     "BugCheck: fAddrMap erase failed");
  if (fNameMap.erase(it->second) == 0)
    throw Rexception("RlinkAddrMap::Erase()", 
                     "BugCheck: fNameMap erase failed");
  
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkAddrMap::Find(const std::string& name, uint16_t& addr) const
{
  auto it = fNameMap.find(name);
  if (it == fNameMap.end()) return false;

  addr = it->second;
  
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkAddrMap::Find(uint16_t addr, std::string& name) const
{
  auto it = fAddrMap.find(addr);
  if (it == fAddrMap.end()) return false;

  name = it->second;
  
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkAddrMap::MaxNameLength() const
{
  if (fMaxLength == 0) {
    for (auto& o: fAddrMap) {
      fMaxLength = max(fMaxLength, o.second.length());
    }
  }
  return fMaxLength;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkAddrMap::Print(std::ostream& os, int ind) const
{
  size_t maxlen = max(size_t(6), MaxNameLength());
  
  RosFill bl(ind);
  for (auto& o: fAddrMap) {
    os << bl << RosPrintf(o.second.c_str(), "-s",maxlen)
       << " : " << RosPrintf(o.first, "$x0", 6)
       << "  " << RosPrintf(o.first, "o0", 6) << endl;
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkAddrMap::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkAddrMap @ " << this << endl;
  if (detail < 0) {
    os << bl << "  fAddrMap.size:   " << fAddrMap.size() << endl;
  } else {
    Print(os,ind+2);
  }
  return;
}

} // end namespace Retro
