// $Id: Rw11UnitTerm.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-02-25   855   1.0.2  inline RcvQueueEmpty(),RcvQueueSize()
// 2013-04-20   508   1.0.1  add 7bit and non-printable masking; add log file
// 2013-04-13   504   1.0    Initial version
// 2013-03-02   493   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11UnitTerm.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitTerm::SetTo7bit(bool to7bit)
{
  fTo7bit = to7bit;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitTerm::SetToEnpc(bool toenpc)
{
  fToEnpc = toenpc;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitTerm::SetTi7bit(bool ti7bit)
{
  fTi7bit = ti7bit;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitTerm::To7bit() const
{
  return fTo7bit;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitTerm::ToEnpc() const
{
  return fToEnpc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitTerm::Ti7bit() const
{
  return fTi7bit;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rw11UnitTerm::Log() const
{
  return fLogFname;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitTerm::RcvQueueEmpty()
{
  return fRcvQueue.empty();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11UnitTerm::RcvQueueSize()
{
  return fRcvQueue.size();
}


} // end namespace Retro
