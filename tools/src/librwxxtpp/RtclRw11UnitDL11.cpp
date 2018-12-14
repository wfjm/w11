// $Id: RtclRw11UnitDL11.cpp 1078 2018-12-08 14:19:03Z mueller $
//
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-03-01   493   1.0    Initial version
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11UnitDL11.
*/

#include "RtclRw11UnitDL11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11UnitDL11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitDL11::RtclRw11UnitDL11(Tcl_Interp* interp,
                              const std::string& unitcmd,
                              const std::shared_ptr<Rw11UnitDL11>& spunit)
  : RtclRw11UnitBase<Rw11UnitDL11,Rw11UnitTerm,
                     RtclRw11UnitTerm>("Rw11UnitDL11", spunit)
{
  SetupGetSet();
  CreateObjectCmd(interp, unitcmd.c_str()); 
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11UnitDL11::~RtclRw11UnitDL11()
{}

} // end namespace Retro
