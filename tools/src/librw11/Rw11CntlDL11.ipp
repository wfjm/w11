// $Id: Rw11CntlDL11.ipp 1185 2019-07-12 17:29:12Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-04-26  1139   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11CntlDL11.
*/


// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11CntlDL11::RxQlim() const
{
  return fRxQlim;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11CntlDL11::RxRlim() const
{
  return fRxRlim;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11CntlDL11::TxRlim() const
{
  return fTxRlim;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11CntlDL11::Itype() const
{
  return fItype;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11CntlDL11::Buffered() const
{
  return fFsize > 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11CntlDL11::FifoSize() const
{
  return fFsize;
}

} // end namespace Retro
