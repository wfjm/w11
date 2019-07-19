// $Id: RtclRw11UnitLP11.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.2    use std::shared_ptr instead of boost
// 2017-04-08   870   1.1    inherit from RtclRw11UnitBase
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclRw11UnitLP11.
*/

#include "RtclRw11UnitLP11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11UnitLP11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitLP11::RtclRw11UnitLP11(Tcl_Interp* interp,
                              const std::string& unitcmd,
                              const std::shared_ptr<Rw11UnitLP11>& spunit)
  : RtclRw11UnitBase<Rw11UnitLP11,Rw11UnitStream,
                     RtclRw11UnitStream>("Rw11UnitLP11", spunit)
{
  SetupGetSet();
  CreateObjectCmd(interp, unitcmd.c_str()); 
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11UnitLP11::~RtclRw11UnitLP11()
{}

} // end namespace Retro
