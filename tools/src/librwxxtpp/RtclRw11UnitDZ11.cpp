// $Id: RtclRw11UnitDZ11.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-05-04  1146   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
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
