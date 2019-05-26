// $Id: RtclRw11CntlDZ11.cpp 1148 2019-05-12 10:10:44Z mueller $
//
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-05-11  1148   1.0    Initial version
// 2019-05-04  1146   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11CntlDZ11.
*/

#include <functional>

#include "librtcltools/RtclNameSet.hpp"

#include "RtclRw11CntlDZ11.hpp"
#include "RtclRw11UnitDZ11.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::RtclRw11CntlDZ11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11CntlDZ11::RtclRw11CntlDZ11()
  : RtclRw11CntlTermBase<Rw11CntlDZ11>("Rw11CntlDZ11","term")
{
  Rw11CntlDZ11* pobj = &Obj();
  fGets.Add<uint16_t>  ("rxqlim",   bind(&Rw11CntlDZ11::RxQlim,   pobj));
  fGets.Add<uint16_t>  ("rxrlim",   bind(&Rw11CntlDZ11::RxRlim,   pobj));
  fGets.Add<uint16_t>  ("txrlim",   bind(&Rw11CntlDZ11::TxRlim,   pobj));
  fGets.Add<bool>      ("modcntl",  bind(&Rw11CntlDZ11::ModCntl,  pobj));
  fGets.Add<uint16_t>  ("itype",    bind(&Rw11CntlDZ11::Itype,    pobj));
  fGets.Add<bool>      ("buffered", bind(&Rw11CntlDZ11::Buffered, pobj));
  fGets.Add<uint16_t>  ("fifosize", bind(&Rw11CntlDZ11::FifoSize, pobj));
  
  fSets.Add<uint16_t>  ("rxqlim",   bind(&Rw11CntlDZ11::SetRxQlim, pobj, _1));
  fSets.Add<uint16_t>  ("rxrlim",   bind(&Rw11CntlDZ11::SetRxRlim, pobj, _1));
  fSets.Add<uint16_t>  ("txrlim",   bind(&Rw11CntlDZ11::SetTxRlim, pobj, _1));
  fSets.Add<bool>      ("modcntl",  bind(&Rw11CntlDZ11::SetModCntl,pobj, _1));
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11CntlDZ11::~RtclRw11CntlDZ11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlDZ11::FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu)
{
  static RtclNameSet optset("-base|-lam");

  string cntlname(cpu.Obj().NextCntlName("dz"));
  string cntlcmd = cpu.CommandName() + cntlname;

  uint16_t base = Rw11CntlDZ11::kIbaddr;
  int      lam  = Rw11CntlDZ11::kLam;
  
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
    new RtclRw11UnitDZ11(args.Interp(), unitcmd, Obj().UnitSPtr(i));
  }

  return kOK;
}

} // end namespace Retro
