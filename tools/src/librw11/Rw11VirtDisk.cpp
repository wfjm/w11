// $Id: Rw11VirtDisk.cpp 1076 2018-12-02 12:45:49Z mueller $
//
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-02  1076   1.4    use unique_ptr for New()
// 2018-10-27  1061   1.3    add fNCyl,fNHead,fNSect; add Rw11VirtDiskRam
// 2017-04-07   868   1.2.1  Dump(): add detail arg
// 2017-04-02   866   1.2    add default scheme handling
// 2017-04-02   864   1.1    add Rw11VirtDiskOver
// 2013-03-03   494   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of Rw11VirtDisk.
*/
#include <memory>

#include "librtools/RosFill.hpp"
#include "librtools/RparseUrl.hpp"
#include "librtools/Rexception.hpp"
#include "Rw11VirtDiskFile.hpp"
#include "Rw11VirtDiskOver.hpp"
#include "Rw11VirtDiskRam.hpp"

#include "Rw11VirtDisk.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtDisk
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// static definitions

std::string Rw11VirtDisk::sDefaultScheme("file");
  
//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtDisk::Rw11VirtDisk(Rw11Unit* punit)
  : Rw11Virt(punit),
    fBlkSize(0),
    fNBlock(0),
    fNCyl(0),
    fNHead(0),
    fNSect(0)
{
  fStats.Define(kStatNVDRead,    "NVDRead",     "Read() calls");
  fStats.Define(kStatNVDReadBlk, "NVDReadBlk",  "blocks read");
  fStats.Define(kStatNVDWrite,   "NVDWrite",    "Write() calls");
  fStats.Define(kStatNVDWriteBlk,"NVDWriteBlk", "blocks written");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtDisk::~Rw11VirtDisk()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtDisk::Dump(std::ostream& os, int ind, const char* text,
                        int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtDisk @ " << this << endl;

  os << bl << "  fBlkSize:        " << fBlkSize << endl;
  os << bl << "  fNBlock:         " << fNBlock << endl;
  os << bl << "  fNCyl:           " << fNCyl   << endl;
  os << bl << "  fNHead:          " << fNHead  << endl;
  os << bl << "  fNSect:          " << fNSect  << endl;
  Rw11Virt::Dump(os, ind, " ^", detail);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::unique_ptr<Rw11VirtDisk> Rw11VirtDisk::New(const std::string& url,
                                                Rw11Unit* punit,
                                                RerrMsg& emsg)
{
  string scheme = RparseUrl::FindScheme(url, sDefaultScheme);
  unique_ptr<Rw11VirtDisk> up;
  
  if (scheme == "file") {                   // scheme -> file:
    up.reset(new Rw11VirtDiskFile(punit));
    if (!up->Open(url, emsg)) up.reset();

  } else if (scheme == "over") {            // scheme -> over:
    up.reset(new Rw11VirtDiskOver(punit));
    if (!up->Open(url, emsg)) up.reset();

  } else if (scheme == "ram") {             // scheme -> ram:
    up.reset(new Rw11VirtDiskRam(punit));
    if (!up->Open(url, emsg)) up.reset();

  } else {                                  // scheme -> no match
    emsg.Init("Rw11VirtDisk::New", string("Scheme '") + scheme +
              "' is not supported");
  }

  return up;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

const std::string& Rw11VirtDisk::DefaultScheme()
{
  return sDefaultScheme;
} 
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtDisk::SetDefaultScheme(const std::string& scheme)
{
  if (scheme != "file" && scheme != "over")
    throw Rexception("Rw11VirtDisk::SetDefaultScheme",
                     "only 'file' or 'over' allowed");
    
  sDefaultScheme = scheme;
  return;
}
  
} // end namespace Retro
