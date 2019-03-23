// $Id: RtclRw11CntlLP11.cpp 1123 2019-03-17 17:55:12Z mueller $
//
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-03-17  1123   1.2    add getters& setters for lp11_buf readout
// 2017-04-16   878   1.1    add class in ctor;derive from RtclRw11CntlStreamBase
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclRw11CntlLP11.
*/

#include "librtcltools/RtclNameSet.hpp"

#include "RtclRw11CntlLP11.hpp"
#include "RtclRw11UnitLP11.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::RtclRw11CntlLP11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11CntlLP11::RtclRw11CntlLP11()
  : RtclRw11CntlStreamBase<Rw11CntlLP11>("Rw11CntlLP11","stream")
{
  Rw11CntlLP11* pobj = &Obj();
  fGets.Add<uint16_t>     ("rlim",     bind(&Rw11CntlLP11::Rlim,     pobj));
  fGets.Add<uint16_t>     ("itype",    bind(&Rw11CntlLP11::Itype,    pobj));
  fGets.Add<bool>         ("buffered", bind(&Rw11CntlLP11::Buffered, pobj));
  fGets.Add<uint16_t>     ("fifosize", bind(&Rw11CntlLP11::FifoSize, pobj));
  
  fSets.Add<uint16_t>     ("rlim",     bind(&Rw11CntlLP11::SetRlim,pobj, _1));
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11CntlLP11::~RtclRw11CntlLP11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlLP11::FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu)
{
  static RtclNameSet optset("-base|-lam");

  string cntlname(cpu.Obj().NextCntlName("lp"));
  string cntlcmd = cpu.CommandName() + cntlname;

  uint16_t base = Rw11CntlLP11::kIbaddr;
  int      lam  = Rw11CntlLP11::kLam;
  
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
    new RtclRw11UnitLP11(args.Interp(), unitcmd, Obj().UnitSPtr(i));
  }

  return kOK;
}

} // end namespace Retro
