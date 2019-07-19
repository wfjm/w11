// $Id: RtclRw11CntlTM11.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.1.1  use RtclStats::Exec()
// 2017-04-16   878   1.1    add class in ctor; derive from RtclRw11CntlTapeBase
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclRw11CntlTM11.
*/

#include "librtcltools/RtclNameSet.hpp"

#include "RtclRw11CntlTM11.hpp"
#include "RtclRw11UnitTM11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11CntlTM11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11CntlTM11::RtclRw11CntlTM11()
  : RtclRw11CntlTapeBase<Rw11CntlTM11>("Rw11CntlTM11","tape")
{}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11CntlTM11::~RtclRw11CntlTM11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlTM11::FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu)
{
  static RtclNameSet optset("-base|-lam");

  string cntlname(cpu.Obj().NextCntlName("tm"));
  string cntlcmd = cpu.CommandName() + cntlname;

  uint16_t base = Rw11CntlTM11::kIbaddr;
  int      lam  = Rw11CntlTM11::kLam;
  
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
    new RtclRw11UnitTM11(args.Interp(), unitcmd, Obj().UnitSPtr(i));
  }

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlTM11::M_stats(RtclArgs& args)
{
  RtclStats::Context cntx;
  if (!RtclStats::GetArgs(args, cntx)) return kERR;
  if (!RtclStats::Exec(args, cntx, Obj().Stats())) return kERR;
  if (!RtclStats::Exec(args, cntx, Obj().RdmaStats())) return kERR;
  return kOK;
}


} // end namespace Retro
