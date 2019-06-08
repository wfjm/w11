// $Id: RtclRw11CntlRL11.cpp 1160 2019-06-07 17:30:17Z mueller $
//
// Copyright 2014-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-06-07  1160   1.1.1  use RtclStats::Exec()
// 2017-04-16   878   1.1    add class in ctor; derive from RtclRw11CntlDiskBase
// 2015-01-10   632   1.0    Initial version
// 2014-06-08   561   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11CntlRL11.
*/

#include "librtcltools/RtclNameSet.hpp"

#include "RtclRw11CntlRL11.hpp"
#include "RtclRw11UnitRL11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11CntlRL11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11CntlRL11::RtclRw11CntlRL11()
  : RtclRw11CntlDiskBase<Rw11CntlRL11>("Rw11CntlRL11","disk")
{}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11CntlRL11::~RtclRw11CntlRL11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlRL11::FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu)
{
  static RtclNameSet optset("-base|-lam");

  string cntlname(cpu.Obj().NextCntlName("rl"));
  string cntlcmd = cpu.CommandName() + cntlname;

  uint16_t base = Rw11CntlRL11::kIbaddr;
  int      lam  = Rw11CntlRL11::kLam;
  
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
    new RtclRw11UnitRL11(args.Interp(), unitcmd, Obj().UnitSPtr(i));
  }

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlRL11::M_stats(RtclArgs& args)
{
  RtclStats::Context cntx;
  if (!RtclStats::GetArgs(args, cntx)) return kERR;
  if (!RtclStats::Exec(args, cntx, Obj().Stats())) return kERR;
  if (!RtclStats::Exec(args, cntx, Obj().RdmaStats())) return kERR;
  return kOK;
}

} // end namespace Retro
