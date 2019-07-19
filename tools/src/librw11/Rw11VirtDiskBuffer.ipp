// $Id: Rw11VirtDiskBuffer.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-03-10   859   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
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
