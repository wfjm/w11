// $Id: RtclRw11UnitDEUNA.cpp 983 2018-01-02 20:35:59Z mueller $
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
// 2017-04-08   870   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11UnitDEUNA.
*/

#include "RtclRw11UnitDEUNA.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11UnitDEUNA
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitDEUNA::RtclRw11UnitDEUNA(Tcl_Interp* interp,
                              const std::string& unitcmd,
                              const boost::shared_ptr<Rw11UnitDEUNA>& spunit)
  : RtclRw11UnitBase<Rw11UnitDEUNA,Rw11Unit,
                     RtclRw11Unit>("Rw11UnitDEUNA", spunit)
{
  CreateObjectCmd(interp, unitcmd.c_str());
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11UnitDEUNA::~RtclRw11UnitDEUNA()
{}

} // end namespace Retro
