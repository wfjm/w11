// $Id: RtclRw11CntlFactory.cpp 515 2013-05-04 17:28:59Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-05-01   513   1.0.1  add LP11
// 2013-03-06   495   1.0    Initial version
// 2013-02-09   489   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11CntlFactory.cpp 515 2013-05-04 17:28:59Z mueller $
  \brief   Implemenation of global function RtclRw11CntlFactory.
*/

#include "tcl.h"

#include "RtclRw11CntlFactory.hpp"

#include "RtclRw11CntlDL11.hpp"
#include "RtclRw11CntlRK11.hpp"
#include "RtclRw11CntlLP11.hpp"
#include "RtclRw11CntlPC11.hpp"

using namespace std;

// all method definitions in namespace Retro (avoid using in includes...)
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlFactory(RtclArgs& args, RtclRw11Cpu& cpu)
{
  string type;
  if (!args.GetArg("type", type)) return TCL_ERROR;

  // 'factory section', create concrete Rw11Cntl objects
  if        (type == "dl11") {              // dl11 --------------------------
    unique_ptr<RtclRw11CntlDL11> pobj(new RtclRw11CntlDL11());
    if(pobj->FactoryCmdConfig(args, cpu) != TCL_OK) return TCL_ERROR;
    pobj.release();
    
  } else if (type == "rk11") {              // rk11 --------------------------
    unique_ptr<RtclRw11CntlRK11> pobj(new RtclRw11CntlRK11());
    if(pobj->FactoryCmdConfig(args, cpu) != TCL_OK) return TCL_ERROR;
    pobj.release();
    
  } else if (type == "lp11") {              // lp11 --------------------------
    unique_ptr<RtclRw11CntlLP11> pobj(new RtclRw11CntlLP11());
    if(pobj->FactoryCmdConfig(args, cpu) != TCL_OK) return TCL_ERROR;
    pobj.release();
    
  } else if (type == "pc11") {              // pc11 --------------------------
    unique_ptr<RtclRw11CntlPC11> pobj(new RtclRw11CntlPC11());
    if(pobj->FactoryCmdConfig(args, cpu) != TCL_OK) return TCL_ERROR;
    pobj.release();
    
  } else {                                  // unknown cntl type -------------
    return args.Quit(string("-E: unknown controller type '") + type + "'");
  }

  return TCL_OK;
}

} // end namespace Retro
