// $Id: RtclStats.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.1    Rename Collect->Exec, not longer const; add -reset
// 2014-08-22   584   1.0.2  use nullptr
// 2013-03-06   495   1.0.1  Rename Exec->Collect
// 2011-02-26   364   1.0    Initial version
// 2011-02-20   363   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclStats.
*/

#include <sstream>

#include "RtclStats.hpp"
#include "RtclNameSet.hpp"
#include "RtclOPtr.hpp"

using namespace std;

/*!
  \class Retro::RtclStats
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclStats::GetArgs(RtclArgs& args, Context& cntx)
{
  static RtclNameSet optset("-lname|-ltext|-lvalue|-lpair|-lall|"
                            "-atext|-avalue|-print|-reset");

  string opt;
  string varname;
  string format;
  int    width=0;
  int    prec=0;

  if (args.NextOpt(opt, optset)) {
    if (opt == "-atext" || opt == "-avalue") {
      if (!args.GetArg("varName", varname)) return false;      
    } else if (opt == "-print") {
      if (!args.GetArg("?format", format)) return false;
      if (!args.GetArg("?width", width, 0, 32)) return false;
      if (!args.GetArg("?prec",  prec,  0, 32)) return false;
    }

  } else {
    opt   = "-print";
    width = 12;
  }
  if (!args.AllDone()) return false;

  cntx.opt     = opt;
  cntx.varname = varname;
  cntx.format  = format;
  cntx.width   = width;
  cntx.prec    = prec;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclStats::Exec(RtclArgs& args, const Context& cntx, Rstats& stats)
{
  Tcl_Interp* interp = args.Interp();
  Tcl_Obj*    plist   = Tcl_GetObjResult(interp);
  
  if        (cntx.opt == "-lname") {        // -lname -------------------------
    for (size_t i=0; i<stats.Size(); i++) {
      const string& name(stats.Name(i));
      RtclOPtr pobj(Tcl_NewStringObj(name.data(), name.length()));
      if (Tcl_ListObjAppendElement(interp, plist, pobj) != TCL_OK) return false;
    }

  } else if (cntx.opt == "-ltext") {        // -ltext -------------------------
    for (size_t i=0; i<stats.Size(); i++) {
      const string& text(stats.Text(i));
      RtclOPtr pobj(Tcl_NewStringObj(text.data(), text.length()));
      if (Tcl_ListObjAppendElement(interp, plist, pobj) != TCL_OK) return false;
    }

  } else if (cntx.opt == "-lvalue") {       // -lvalue ------------------------
    for (size_t i=0; i<stats.Size(); i++) {
      RtclOPtr pobj(Tcl_NewDoubleObj(stats.Value(i)));
      if (Tcl_ListObjAppendElement(interp, plist, pobj) != TCL_OK) return false;
    }

  } else if (cntx.opt == "-lpair" || cntx.opt == "-lall") { // -lpair -lall ---
    for (size_t i=0; i<stats.Size(); i++) {
      const string& name(stats.Name(i));
      RtclOPtr ptup(Tcl_NewListObj(0,nullptr));
      Tcl_ListObjAppendElement(nullptr, ptup, 
                               Tcl_NewDoubleObj(stats.Value(i)));
      Tcl_ListObjAppendElement(nullptr, ptup, 
                               Tcl_NewStringObj(name.data(), name.length()));
      if (cntx.opt == "-lall") {
        const string& text(stats.Text(i));
        Tcl_ListObjAppendElement(nullptr, ptup, 
                                 Tcl_NewStringObj(text.data(), text.length()));
      }
      if (Tcl_ListObjAppendElement(interp, plist, ptup) != TCL_OK) return false;
    }

  } else if (cntx.opt == "-atext") {        // -atext -------------------------
    for (size_t i=0; i<stats.Size(); i++) {
      const string& text(stats.Text(i));
      RtclOPtr pobj(Tcl_NewStringObj(text.data(), text.length()));
      if (!Tcl_SetVar2Ex(interp, cntx.varname.c_str(), stats.Name(i).c_str(),
                         pobj, TCL_LEAVE_ERR_MSG)) return false;
    }

  } else if (cntx.opt == "-avalue") {       // -avalue ------------------------
    for (size_t i=0; i<stats.Size(); i++) {
      RtclOPtr pobj(Tcl_NewDoubleObj(stats.Value(i)));
      if (!Tcl_SetVar2Ex(interp, cntx.varname.c_str(), stats.Name(i).c_str(),
                         pobj, TCL_LEAVE_ERR_MSG)) return false;
    }

  } else if (cntx.opt == "-print") {        // -print -------------------------
    ostringstream sos;
    stats.Print(sos, cntx.format.c_str(), cntx.width, cntx.prec);
    args.AppendResultLines(sos);

  } else if (cntx.opt == "-reset") {        // -reset -------------------------
    stats.Reset();

  } else {
    args.AppendResult("-E: BUG! RtclStats::Collect: bad option '", 
                      cntx.opt.c_str(), "'", nullptr);
    return false;
  }
  
  return true;
}

} // end namespace Retro
