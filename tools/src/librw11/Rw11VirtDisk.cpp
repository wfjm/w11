// $Id: Rw11VirtDisk.cpp 868 2017-04-07 20:09:33Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-07   868   1.2.1  Dump(): add detail arg
// 2017-04-02   866   1.2    add default scheme handling
// 2017-04-02   864   1.1    add Rw11VirtDiskOver
// 2013-03-03   494   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtDisk.cpp 868 2017-04-07 20:09:33Z mueller $
  \brief   Implemenation of Rw11VirtDisk.
*/
#include <memory>

#include "librtools/RosFill.hpp"
#include "librtools/RparseUrl.hpp"
#include "librtools/Rexception.hpp"
#include "Rw11VirtDiskFile.hpp"
#include "Rw11VirtDiskOver.hpp"

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
    fNBlock(0)
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
  Rw11Virt::Dump(os, ind, " ^", detail);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rw11VirtDisk* Rw11VirtDisk::New(const std::string& url, Rw11Unit* punit,
                                RerrMsg& emsg)
{
  string scheme = RparseUrl::FindScheme(url, sDefaultScheme);
  unique_ptr<Rw11VirtDisk> p;
  
  if (scheme == "file") {                   // scheme -> file:
    p.reset(new Rw11VirtDiskFile(punit));
    if (p->Open(url, emsg)) return p.release();

  } else if (scheme == "over") {            // scheme -> over:
    p.reset(new Rw11VirtDiskOver(punit));
    if (p->Open(url, emsg)) return p.release();

  } else {                                  // scheme -> no match
    emsg.Init("Rw11VirtDisk::New", string("Scheme '") + scheme +
              "' is not supported");
  }

  return 0;
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
