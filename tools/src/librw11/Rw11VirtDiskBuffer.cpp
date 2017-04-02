// $Id: Rw11VirtDiskBuffer.cpp 859 2017-03-11 22:36:45Z mueller $
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
// 2017-03-10   859   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtDiskBuffer.cpp 859 2017-03-11 22:36:45Z mueller $
  \brief   Implemenation of Rw11VirtDiskBuffer.
*/

#include <string.h>

#include "Rw11VirtDiskBuffer.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtDiskBuffer
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtDiskBuffer::Rw11VirtDiskBuffer(size_t blksize)
  : fBuf(blksize, 0),
    fNWrite(0)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtDiskBuffer::~Rw11VirtDiskBuffer()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtDiskBuffer::Read(uint8_t* data)
{
  ::memcpy(data, fBuf.data(), fBuf.size());
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtDiskBuffer::Write(const uint8_t* data)
{
  ::memcpy(fBuf.data(), data, fBuf.size());
  fNWrite += 1;
  if (fNWrite == 0) fNWrite -= 1;           // stop at max
  return;
}

} // end namespace Retro
