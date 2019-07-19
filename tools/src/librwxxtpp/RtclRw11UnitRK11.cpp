// $Id: RtclRw11UnitRK11.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.2    use std::shared_ptr instead of boost
// 2017-04-08   870   1.1    inherit from RtclRw11UnitBase
// 2013-02-22   490   1.0    Initial version
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclRw11UnitRK11.
*/

#include "RtclRw11UnitRK11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11UnitRK11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitRK11::RtclRw11UnitRK11(
                    Tcl_Interp* interp, const std::string& unitcmd,
                    const std::shared_ptr<Rw11UnitRK11>& spunit)
  : RtclRw11UnitBase<Rw11UnitRK11,Rw11UnitDisk,
                     RtclRw11UnitDisk>("Rw11UnitRK11", spunit)
{
  SetupGetSet();
  CreateObjectCmd(interp, unitcmd.c_str()); 
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11UnitRK11::~RtclRw11UnitRK11()
{}

} // end namespace Retro
