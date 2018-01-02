// $Id: Rtools.ipp 983 2018-01-02 20:35:59Z mueller $
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
// 2017-02-11   850   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (inline) of Rtools.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rtools::Word2Bytes(uint16_t word, uint16_t& byte0, uint16_t& byte1)
{
  byte1 = (word>>8) & 0xff;
  byte0 =  word     & 0xff;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t Rtools::Bytes2Word(uint16_t byte0, uint16_t byte1)
{
  return (byte1<<8) | byte0;
}


} // end namespace Retro
