// $Id: RtclRw11UnitDEUNA.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2014-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.1    use std::shared_ptr instead of boost
// 2017-04-08   870   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------

/*!
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
                              const std::shared_ptr<Rw11UnitDEUNA>& spunit)
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
