// $Id: Rw11VirtDiskFile.cpp 1167 2019-06-20 10:17:11Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-21  1167   1.2    use RfileFd; remove dtor
// 2018-09-22  1048   1.1.4  BUGFIX: coverity (resource leak)
// 2018-09-16  1047   1.1.3  coverity fixup (uninitialized scalar)
// 2017-04-15   875   1.1.2  Open(): add overload with scheme handling
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2017-03-11   859   1.1    use fWProt
// 2013-04-14   506   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of Rw11VirtDiskFile.
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "librtools/RosFill.hpp"

#include "Rw11VirtDiskFile.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtDiskFile
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtDiskFile::Rw11VirtDiskFile(Rw11Unit* punit)
  : Rw11VirtDisk(punit),
    fFd("Rw11VirtDiskFile::fFd."),
    fSize(0)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskFile::Open(const std::string& url, RerrMsg& emsg)
{
  return Open(url, "file", emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskFile::Open(const std::string& url, const std::string& scheme,
                            RerrMsg& emsg)
{
  if (!fUrl.Set(url, "|wpro|", scheme, emsg)) return false;
  
  fWProt = fUrl.FindOpt("wpro");

  if (!fFd.Open(fUrl.Path().c_str(),
                fWProt ? O_RDONLY : O_RDWR, emsg)) return false;

  struct stat sbuf;
  if (!fFd.Stat(&sbuf, emsg)) {
    fFd.Close();
    return false;
  }
  
  if ((sbuf.st_mode & S_IWUSR) == 0) fWProt = true;
  fSize = sbuf.st_size;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskFile::Read(size_t lba, size_t nblk, uint8_t* data, 
                            RerrMsg& emsg)
{
  fStats.Inc(kStatNVDRead);
  fStats.Inc(kStatNVDReadBlk, double(nblk));

  size_t seekpos = fBlkSize * lba;
  size_t nbyt    = fBlkSize * nblk;

  if (seekpos >= fSize) {
    uint8_t* p = data;
    for (size_t i=0; i<nbyt; i++) *p++ = 0;
    return true;
  }

  if (!fFd.Seek(seekpos, SEEK_SET, emsg)) return false;
  ssize_t irc = fFd.Read(data, nbyt, emsg);
  if (irc < 0) return false;

  if (irc < ssize_t(nbyt)) {
    uint8_t* p = data+irc;
    for (size_t i=irc; i<nbyt; i++) *p++ = 0;    
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskFile::Write(size_t lba, size_t nblk, const uint8_t* data, 
                             RerrMsg& emsg)
{
  fStats.Inc(kStatNVDWrite);
  fStats.Inc(kStatNVDWriteBlk, double(nblk));

  size_t seekpos = fBlkSize * lba;
  size_t nbyt    = fBlkSize * nblk;

  if (!fFd.Seek(seekpos, SEEK_SET, emsg)) return false;
  if (!fFd.WriteAll(data, nbyt, emsg)) return false;
  if (seekpos+nbyt > fSize) fSize = seekpos+nbyt;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtDiskFile::Dump(std::ostream& os, int ind, const char* text,
                            int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtDiskFile @ " << this << endl;

  os << bl << "  fFd:             " << fFd.Fd() << endl;
  os << bl << "  fSize:           " << fSize << endl;
  Rw11VirtDisk::Dump(os, ind, " ^", detail);
  return;
}

} // end namespace Retro
