// $Id: Rw11UnitDEUNA.ipp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-01-29   847   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (inline) of Rw11UnitDEUNA.
*/

#include "Rw11UnitDEUNA.hpp"

/*!
  \class Retro::Rw11UnitDEUNA
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rw11CntlDEUNA& Rw11UnitDEUNA::Cntl() const
{
  return *fpCntl;
}

} // end namespace Retro
