// $Id: RtclRw11UnitTM11.cpp 1078 2018-12-08 14:19:03Z mueller $
//
// Copyright 2015-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-07  1078   1.2    use std::shared_ptr instead of boost
// 2017-04-08   870   1.1    inherit from RtclRw11UnitBase
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
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
