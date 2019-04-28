// $Id: Rw11CntlDL11.ipp 1139 2019-04-27 14:00:38Z mueller $
//
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
