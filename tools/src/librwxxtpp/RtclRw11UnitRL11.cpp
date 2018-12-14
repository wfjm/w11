// $Id: RtclRw11UnitRL11.cpp 1078 2018-12-08 14:19:03Z mueller $
//
// Copyright 2014-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-06-08   561   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11UnitRL11.
*/

#include "RtclRw11UnitRL11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11UnitRL11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitRL11::RtclRw11UnitRL11(
                    Tcl_Interp* interp, const std::string& unitcmd,
                    const std::shared_ptr<Rw11UnitRL11>& spunit)
  : RtclRw11UnitBase<Rw11UnitRL11,Rw11UnitDisk,
                     RtclRw11UnitDisk>("Rw11UnitRL11", spunit)
{
  SetupGetSet();
  CreateObjectCmd(interp, unitcmd.c_str()); 
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11UnitRL11::~RtclRw11UnitRL11()
{}

} // end namespace Retro
