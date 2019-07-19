// $Id: RtclRw11CntlDL11.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-04-26  1139   1.2    add getters& setters for dl11_buf readout
// 2019-02-23  1114   1.1.2  use std::bind instead of lambda
// 2018-12-15  1082   1.1.1  use lambda instead of boost::bind
// 2017-04-16   878   1.1    add class in ctor; derive from RtclRw11CntlTermBase
// 2013-05-04   516   1.0.1  add RxRlim support (receive interrupt rate limit)
// 2013-03-06   495   1.0    Initial version
// 2013-02-02   480   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclRw11CntlDL11.
*/

#include <functional>

#include "librtcltools/RtclNameSet.hpp"

#include "RtclRw11CntlDL11.hpp"
#include "RtclRw11UnitDL11.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::RtclRw11CntlDL11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11CntlDL11::RtclRw11CntlDL11()
  : RtclRw11CntlTermBase<Rw11CntlDL11>("Rw11CntlDL11","term")
{
  Rw11CntlDL11* pobj = &Obj();
  fGets.Add<uint16_t>  ("rxqlim",   bind(&Rw11CntlDL11::RxQlim,   pobj));
  fGets.Add<uint16_t>  ("rxrlim",   bind(&Rw11CntlDL11::RxRlim,   pobj));
  fGets.Add<uint16_t>  ("txrlim",   bind(&Rw11CntlDL11::TxRlim,   pobj));
  fGets.Add<uint16_t>  ("itype",    bind(&Rw11CntlDL11::Itype,    pobj));
  fGets.Add<bool>      ("buffered", bind(&Rw11CntlDL11::Buffered, pobj));
  fGets.Add<uint16_t>  ("fifosize", bind(&Rw11CntlDL11::FifoSize, pobj));
  
  fSets.Add<uint16_t>  ("rxqlim",   bind(&Rw11CntlDL11::SetRxQlim,pobj, _1));
  fSets.Add<uint16_t>  ("rxrlim",   bind(&Rw11CntlDL11::SetRxRlim,pobj, _1));
  fSets.Add<uint16_t>  ("txrlim",   bind(&Rw11CntlDL11::SetTxRlim,pobj, _1));
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11CntlDL11::~RtclRw11CntlDL11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlDL11::FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu)
{
  static RtclNameSet optset("-base|-lam");

  string cntlname(cpu.Obj().NextCntlName("tt"));
  string cntlcmd = cpu.CommandName() + cntlname;

  uint16_t base = Rw11CntlDL11::kIbaddr;
  int      lam  = Rw11CntlDL11::kLam;
  
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
    new RtclRw11UnitDL11(args.Interp(), unitcmd, Obj().UnitSPtr(i));
  }

  return kOK;
}

} // end namespace Retro
