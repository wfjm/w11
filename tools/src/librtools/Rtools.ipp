// $Id: Rtools.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-02-11   850   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
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
