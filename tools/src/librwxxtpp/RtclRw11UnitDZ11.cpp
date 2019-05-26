// $Id: RtclRw11UnitDZ11.cpp 1146 2019-05-05 06:25:13Z mueller $
//
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-05-04  1146   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11UnitDZ11.
*/

#include "RtclRw11UnitDZ11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11UnitDZ11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitDZ11::RtclRw11UnitDZ11(Tcl_Interp* interp,
                              const std::string& unitcmd,
                              const std::shared_ptr<Rw11UnitDZ11>& spunit)
  : RtclRw11UnitBase<Rw11UnitDZ11,Rw11UnitTerm,
                     RtclRw11UnitTerm>("Rw11UnitDZ11", spunit)
{
  SetupGetSet();
  CreateObjectCmd(interp, unitcmd.c_str()); 
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11UnitDZ11::~RtclRw11UnitDZ11()
{}

} // end namespace Retro
