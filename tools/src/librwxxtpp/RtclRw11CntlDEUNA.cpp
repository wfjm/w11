// $Id: RtclRw11CntlDEUNA.cpp 1082 2018-12-15 13:56:20Z mueller $
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
// 2018-12-15  1082   1.0.1  use lambda instead of bind
// 2017-04-16   878   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11CntlDEUNA.
*/

#include <sstream>

#include "librtcltools/RtclNameSet.hpp"

#include "RtclRw11CntlDEUNA.hpp"
#include "RtclRw11UnitDEUNA.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11CntlDEUNA
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11CntlDEUNA::RtclRw11CntlDEUNA()
  : RtclRw11CntlBase<Rw11CntlDEUNA>("Rw11CntlDEUNA","ether")
{
  Rw11CntlDEUNA* pobj = &Obj();
  fGets.Add<string>        ("dpa",    [pobj](){ return pobj->MacDefault(); });
  fGets.Add<const Rtime&>  ("rxpoll", [pobj](){ return pobj->RxPollTime(); });
  fGets.Add<size_t>        ("rxqlim", [pobj](){ return pobj->RxQueLimit(); });
  fGets.Add<bool>          ("run",    [pobj](){ return pobj->Running(); });

  fSets.Add<const string&> ("type",  
                            [pobj](const string& v){ pobj->SetType(v); });
  fSets.Add<const string&> ("dpa",  
                            [pobj](const string& v){ pobj->SetMacDefault(v); });
  fSets.Add<const Rtime&>  ("rxpoll",  
                            [pobj](const Rtime& v){ pobj->SetRxPollTime(v); });
  fSets.Add<size_t>        ("rxqlim",  
                            [pobj](size_t v){ pobj->SetRxQueLimit(v); });
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11CntlDEUNA::~RtclRw11CntlDEUNA()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlDEUNA::FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu)
{
  static RtclNameSet optset("-base|-lam");

  string cntlname(cpu.Obj().NextCntlName("xu"));
  string cntlcmd = cpu.CommandName() + cntlname;

  uint16_t base = Rw11CntlDEUNA::kIbaddr;
  int      lam  = Rw11CntlDEUNA::kLam;
  
  string opt;
  while (args.NextOpt(opt, optset)) {
    if        (opt == "-base") {
      if (!args.GetArg("base", base, 0177776, 0160000)) return kERR;
    } else if (opt == "-lam") {
      if (!args.GetArg("lam",  lam,  0, 15)) return kERR;
    }
  }
  if (!args.AllDone()) return kERR;

  // configure controller
  Obj().Config(cntlname, base, lam);

  // install in CPU
  cpu.Obj().AddCntl(dynamic_pointer_cast<Rw11Cntl>(ObjSPtr()));

  // finally create tcl command
  CreateObjectCmd(args.Interp(), cntlcmd.c_str()); 

  // and create unit commands
  for (size_t i=0; i<Obj().NUnit(); i++) {
    string unitcmd = cpu.CommandName() + Obj().UnitName(i);
    new RtclRw11UnitDEUNA(args.Interp(), unitcmd, Obj().UnitSPtr(i));
  }

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlDEUNA::M_default(RtclArgs& args)
{
  ostringstream sos;
  sos << "to come\n";
  args.AppendResultLines(sos);
  return kOK;
}
  
} // end namespace Retro
