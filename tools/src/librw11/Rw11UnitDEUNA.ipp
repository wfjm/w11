// $Id: Rw11UnitDEUNA.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-01-29   847   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------

/*!
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
