// $Id: Rw11VirtDiskOver.cpp 875 2017-04-15 21:58:50Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-15   875   1.0.2  Open(): use overload with scheme handling
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2017-03-10   859   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtDiskOver.cpp 875 2017-04-15 21:58:50Z mueller $
  \brief   Implemenation of Rw11VirtDiskOver.
*/

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"

#include "Rw11VirtDiskOver.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtDiskOver
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtDiskOver::Rw11VirtDiskOver(Rw11Unit* punit)
  : Rw11VirtDiskFile(punit),
    fBlkMap()
{
  fStats.Define(kStatNVDReadOver,    "NVDReadOver",    "Read() calls over");
  fStats.Define(kStatNVDReadBlkOver, "NVDReadBlkOver", "blocks read from over");
  fStats.Define(kStatNVDWriteOver,   "NVDWriteOver",   "Write() calls over");
  fStats.Define(kStatNVDWriteBlkOver,"NVDWriteBlkOver","blocks written to over");
  fStats.Define(kStatNVDFlushOver,   "NVDFlushOver",   "Flush() calls");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtDiskOver::~Rw11VirtDiskOver()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskOver::WProt() const
{
  return false;                             // from unit always writable !!
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskOver::Open(const std::string& url, RerrMsg& emsg)
{
  // FIXME_code: do we need to handle wpro ?
  return Rw11VirtDiskFile::Open(url, "over", emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskOver::Read(size_t lba, size_t nblk, uint8_t* data, 
                            RerrMsg& emsg)
{
  fStats.Inc(kStatNVDReadOver);
  auto it = fBlkMap.lower_bound(lba);
  if (it == fBlkMap.end() || it->first >= lba+nblk) { // no match
    return Rw11VirtDiskFile::Read(lba, nblk, data, emsg); // one swoop from disk
  } else {                                            // match
    for (size_t i=0; i<nblk; i++) {                     // get it blockwise
      auto it = fBlkMap.find(lba+i);
      if (it == fBlkMap.end()) {
        bool rc = Rw11VirtDiskFile::Read(lba+1, 1, data+i*fBlkSize, emsg);
        if (!rc) return rc;
      } else {
        (it->second).Read(data+i*fBlkSize);
        fStats.Inc(kStatNVDReadBlkOver);
      }
    }
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskOver::Write(size_t lba, size_t nblk, const uint8_t* data, 
                             RerrMsg& emsg)
{
  fStats.Inc(kStatNVDWriteOver);
  fStats.Inc(kStatNVDWriteBlkOver, double(nblk));
  for (size_t i=0; i<nblk; i++) {
    auto it = fBlkMap.find(lba+i);
    if (it == fBlkMap.end()) {
      auto rc = fBlkMap.emplace(lba+i, Rw11VirtDiskBuffer(fBlkSize));
      it = rc.first;
    }
    (it->second).Write(data+i*fBlkSize);
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskOver::Flush(RerrMsg& emsg)
{
  if (fWProt) {
    emsg.Init("Rw11VirtDiskOver::Flush()", "file write protected");
    return false;
  }
  
  fStats.Inc(kStatNVDFlushOver);
  for (auto& kv: fBlkMap) {
    bool rc = Rw11VirtDiskFile::Write(kv.first, 1, kv.second.Data(), emsg);
    if (!rc) return rc;
  }
  fBlkMap.clear();
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtDiskOver::List(std::ostream& os) const
{
  if (fBlkMap.empty()) return;

  uint32_t lbabeg = fBlkMap.begin()->first; // first lba
  uint32_t nwrite = 0;
  for (auto it=fBlkMap.begin(); it!=fBlkMap.end(); ) {
    auto itnext = next(it);
    if (itnext == fBlkMap.end() || itnext->first != (it->first)+1) {
      os << RosPrintf(lbabeg,"d",8) 
         << " .. " << RosPrintf(it->first,"d",8)
         << " : nb=" << RosPrintf(it->first-lbabeg+1,"d",8)
         << " nw=" << RosPrintf(nwrite,"d",8) << endl;
      if (itnext != fBlkMap.end()) lbabeg = itnext->first;
      nwrite = 0;
    } else {
      nwrite += (it->second).NWrite();
    }
    it = itnext;
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtDiskOver::Dump(std::ostream& os, int ind, const char* text,
                            int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtDiskOver @ " << this << endl;

  os << bl << "  fBlkMap.size     " << fBlkMap.size() << endl;
  Rw11VirtDiskFile::Dump(os, ind, " ^", detail);
  return;
}

} // end namespace Retro
