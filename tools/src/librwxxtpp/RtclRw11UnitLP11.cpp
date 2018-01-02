// $Id: RtclRw11UnitLP11.cpp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-08   870   1.1    inherit from RtclRw11UnitBase
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
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
                              const boost::shared_ptr<Rw11UnitLP11>& spunit)
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
