// $Id: RtclRw11UnitPC11.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.2    use std::shared_ptr instead of boost
// 2017-04-08   870   1.1    inherit from RtclRw11UnitBase
// 2014-08-22   584   1.0.1  use nullptr
// 2013-05-03   515   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclRw11UnitPC11.
*/

#include "RtclRw11UnitPC11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11UnitPC11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitPC11::RtclRw11UnitPC11(Tcl_Interp* interp,
                              const std::string& unitcmd,
                              const std::shared_ptr<Rw11UnitPC11>& spunit)
  : RtclRw11UnitBase<Rw11UnitPC11,Rw11UnitStream,
                     RtclRw11UnitStream>("Rw11UnitPC11", spunit)
{
  // create default unit command
  SetupGetSet();
  CreateObjectCmd(interp, unitcmd.c_str());

  // for 1st PC11, create also alias
  //   cpuxpca0 -> cpuxpr
  //   cpuxpca1 -> cpuxpp
  if (unitcmd.length() == 8) {
    size_t ind = spunit->Index();
    if (unitcmd.length() == 8 && unitcmd.substr(4,3) == "pca") {
      string alias = unitcmd.substr(0,4);
      alias += (ind==Rw11CntlPC11::kUnit_PR) ? "pr" : "pp";
      Tcl_CreateAlias(interp, alias.c_str(), interp, unitcmd.c_str(), 
                      0, nullptr);
    }
  }
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11UnitPC11::~RtclRw11UnitPC11()
{}

} // end namespace Retro
