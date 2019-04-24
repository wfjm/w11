// $Id: Rw11CntlPC11.ipp 1132 2019-04-14 20:23:40Z mueller $
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
// 2019-04-14  1132   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rw11CntlPC11.
*/


// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11CntlPC11::PrQlim() const
{
  return fPrQlim;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11CntlPC11::PrRlim() const
{
  return fPrRlim;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11CntlPC11::PpRlim() const
{
  return fPpRlim;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11CntlPC11::Itype() const
{
  return fItype;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11CntlPC11::Buffered() const
{
  return fFsize > 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rw11CntlPC11::FifoSize() const
{
  return fFsize;
}

} // end namespace Retro
