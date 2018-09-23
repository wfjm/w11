// $Id: Rw11VirtDiskFile.cpp 1048 2018-09-22 07:41:46Z mueller $
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
    fFd(0),
    fSize(0)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtDiskFile::~Rw11VirtDiskFile()
{
  if (fFd > 2) ::close(fFd);
}

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
  
  int fd = ::open(fUrl.Path().c_str(), fWProt ? O_RDONLY : O_RDWR);
  if (fd < 0) {
    emsg.InitErrno("Rw11VirtDiskFile::Open()", 
                   string("open() for '") + fUrl.Path() + "' failed: ", errno);
    return false;
  }

  struct stat sbuf;
  if (::fstat(fd, &sbuf) < 0) {
    emsg.InitErrno("Rw11VirtDiskFile::Open()", 
                   string("stat() for '") + fUrl.Path() + "' failed: ", errno);
    ::close(fd);
    return false;
  }

  if ((sbuf.st_mode & S_IWUSR) == 0) fWProt = true;

  fFd = fd;
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

  if (!Seek(seekpos, emsg)) return false;
  
  ssize_t irc = ::read(fFd, data, nbyt);
  if (irc < 0) {
    emsg.InitErrno("Rw11VirtDiskFile::Read()", "read() failed: ", errno);
    return false;
  }

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

  if (!Seek(seekpos, emsg)) return false;

  ssize_t irc = ::write(fFd, data, nbyt);
  if (irc < ssize_t(nbyt)) {
    emsg.InitErrno("Rw11VirtDiskFile::Write()", "write() failed: ", errno);
    return false;
  }

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

  os << bl << "  fFd:             " << fFd << endl;
  os << bl << "  fSize:           " << fSize << endl;
  Rw11VirtDisk::Dump(os, ind, " ^", detail);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskFile::Seek(size_t seekpos, RerrMsg& emsg)
{
  if (::lseek(fFd, seekpos, SEEK_SET) < 0) {
    emsg.InitErrno("Rw11VirtDiskFile::Seek()", "seek() failed: ", errno);
    return false;
  }

  return true;
}

} // end namespace Retro
