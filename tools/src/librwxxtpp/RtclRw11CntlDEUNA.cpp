// $Id: RtclRw11CntlDEUNA.cpp 878 2017-04-16 12:28:15Z mueller $
//
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-16   878   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11CntlDEUNA.cpp 878 2017-04-16 12:28:15Z mueller $
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
  fGets.Add<string>        ("dpa", 
                            boost::bind(&Rw11CntlDEUNA::MacDefault,  pobj));
  fGets.Add<const Rtime&>  ("rxpoll", 
                            boost::bind(&Rw11CntlDEUNA::RxPollTime,  pobj));
  fGets.Add<size_t>       ("rxqlim", 
                            boost::bind(&Rw11CntlDEUNA::RxQueLimit,  pobj));
  fGets.Add<bool>         ("run", 
                            boost::bind(&Rw11CntlDEUNA::Running,     pobj));

  fSets.Add<const string&> ("type",  
                            boost::bind(&Rw11CntlDEUNA::SetType,pobj, _1));
  fSets.Add<const string&> ("dpa",  
                            boost::bind(&Rw11CntlDEUNA::SetMacDefault,pobj, _1));
  fSets.Add<const Rtime&>  ("rxpoll",  
                            boost::bind(&Rw11CntlDEUNA::SetRxPollTime,pobj, _1));
  fSets.Add<size_t>        ("rxqlim",  
                            boost::bind(&Rw11CntlDEUNA::SetRxQueLimit,pobj, _1));
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
