// $Id: Rw11VirtDiskBuffer.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-03-10   859   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
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
