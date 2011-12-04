// $Id: RlinkAddrMap.cpp 434 2011-12-02 19:17:38Z mueller $
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
// 2011-11-28   434   1.0.1  Print(): use proper cast for lp64 compatibility
// 2011-03-06   367   1.0    Initial version
// 2011-03-05   366   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkAddrMap.cpp 434 2011-12-02 19:17:38Z mueller $
  \brief   Implemenation of class RlinkAddrMap.
 */

#include <stdexcept>
#include <algorithm>

#include "RlinkAddrMap.hpp"

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::RlinkAddrMap
  \brief FIXME_text
*/

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

  fNameMap.insert(nmap_val_t(name, addr));
  fAddrMap.insert(amap_val_t(addr, name));
  fMaxLength = max(fMaxLength, name.length());

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkAddrMap::Erase(const std::string& name)
{
  nmap_cit_t it = fNameMap.find(name);
  if (it == fNameMap.end()) return false;

  fMaxLength = 0;                           // force recalculate
  if (fNameMap.erase(name) == 0)
    throw logic_error("RlinkAddrMap::Erase: fNameMap erase failed");
  if (fAddrMap.erase(it->second) == 0)
    throw logic_error("RlinkAddrMap::Erase: fAddrMap erase failed");
  
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkAddrMap::Erase(uint16_t addr)
{
  amap_cit_t it = fAddrMap.find(addr);
  if (it == fAddrMap.end()) return false;

  fMaxLength = 0;                           // force recalculate
  if (fAddrMap.erase(addr) == 0)
    throw logic_error("RlinkAddrMap::Erase: fAddrMap erase failed");
  if (fNameMap.erase(it->second) == 0)
    throw logic_error("RlinkAddrMap::Erase: fNameMap erase failed");
  
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkAddrMap::Find(const std::string& name, uint16_t& addr) const
{
  nmap_cit_t it = fNameMap.find(name);
  if (it == fNameMap.end()) return false;

  addr = it->second;
  
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkAddrMap::Find(uint16_t addr, std::string& name) const
{
  amap_cit_t it = fAddrMap.find(addr);
  if (it == fAddrMap.end()) return false;

  name = it->second;
  
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t RlinkAddrMap::MaxNameLength() const
{
  if (fMaxLength == 0) {
    for (amap_cit_t it=fAddrMap.begin(); it!=fAddrMap.end(); it++) {
      fMaxLength = max(fMaxLength, (it->second).length());
    }
  }
  return fMaxLength;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkAddrMap::Print(std::ostream& os, int ind) const
{
  size_t maxlen = max(((size_t) 6), MaxNameLength());
  
  RosFill bl(ind);
  for (amap_cit_t it=fAddrMap.begin(); it!=fAddrMap.end(); it++) {
    os << bl << RosPrintf((it->second).c_str(), "-s",maxlen)
       << " : " << RosPrintf(it->first, "$x0", 4)
       << "  " << RosPrintf(it->first, "o0", 6) << endl;
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkAddrMap::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkAddrMap @ " << this << endl;
  Print(os,ind+2);
  return;
}


//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_RlinkAddrMap_NoInline))
#define inline
#include "RlinkAddrMap.ipp"
#undef  inline
#endif
