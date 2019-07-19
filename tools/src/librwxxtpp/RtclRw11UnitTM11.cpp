// $Id: RtclRw11UnitTM11.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.2    use std::shared_ptr instead of boost
// 2017-04-08   870   1.1    inherit from RtclRw11UnitBase
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclRw11UnitTM11.
*/

#include "RtclRw11UnitTM11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11UnitTM11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitTM11::RtclRw11UnitTM11(
                    Tcl_Interp* interp, const std::string& unitcmd,
                    const std::shared_ptr<Rw11UnitTM11>& spunit)
  : RtclRw11UnitBase<Rw11UnitTM11,Rw11UnitTape,
                     RtclRw11UnitTape>("Rw11UnitTM11", spunit)
{
  SetupGetSet();
  CreateObjectCmd(interp, unitcmd.c_str()); 
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11UnitTM11::~RtclRw11UnitTM11()
{}

} // end namespace Retro
