// $Id: Rw11VirtTape.ipp 887 2017-04-28 19:32:52Z mueller $
//
// Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-02   864   1.1    move fWProt,WProt() to Rw11Virt base
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (inline) of Rw11VirtTape.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11VirtTape::SetCapacity(size_t nbyte)
{
  fCapacity = nbyte;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11VirtTape::Capacity() const
{
  return fCapacity;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11VirtTape::Bot() const
{
  return fBot;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11VirtTape::Eot() const
{
  return fEot;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11VirtTape::Eom() const
{
  return fEom;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int Rw11VirtTape::PosFile() const
{
  return fPosFile;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int Rw11VirtTape::PosRecord() const
{
  return fPosRecord;
}

} // end namespace Retro
