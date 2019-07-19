// $Id: Rfd.ipp 1185 2019-07-12 17:29:12Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1161   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of class Rfd.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int Rfd::Fd() const
{
  return fFd;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rfd::IsOpen() const
{
  return fFd >= 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rfd::IsOpenNonStd() const
{
  return fFd > 2;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rfd::operator bool() const
{
  return IsOpen();
}

} // end namespace Retro


