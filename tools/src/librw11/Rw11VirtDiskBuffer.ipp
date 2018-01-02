// $Id: Rw11VirtDiskBuffer.ipp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-03-10   859   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (inline) of Rw11VirtDiskBuffer.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11VirtDiskBuffer::BlockSize() const
{
  return fBuf.size();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint8_t* Rw11VirtDiskBuffer::Data()
{
  return fBuf.data();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const uint8_t* Rw11VirtDiskBuffer::Data() const
{
  return fBuf.data();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t Rw11VirtDiskBuffer::NWrite() const
{
  return fNWrite;
}

} // end namespace Retro
