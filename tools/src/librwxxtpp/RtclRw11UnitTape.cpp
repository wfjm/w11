// $Id: RtclRw11UnitTape.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-02-23  1114   1.1.3  use std::bind instead of lambda
// 2018-12-15  1082   1.1.2  use lambda instead of boost::bind
// 2018-10-06  1053   1.1.1  move using after includes (clang warning)
// 2017-04-08   870   1.1    use Rw11UnitTape& ObjUV(); inherit from RtclRw11Unit
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclRw11UnitTape.
*/

#include <functional>

#include "RtclRw11UnitTape.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::RtclRw11UnitTape
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitTape::RtclRw11UnitTape(const std::string& type)
  : RtclRw11Unit(type)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclRw11UnitTape::~RtclRw11UnitTape()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclRw11UnitTape::SetupGetSet()
{
  // this can't be in ctor because pure virtual is called which is available
  // only when more derived class is being constructed. SetupGetSet() must be
  // called in ctor of a more derived class.

  Rw11UnitTape* pobj = &ObjUV();
  
  fGets.Add<const string&> ("type",     bind(&Rw11UnitTape::Type,  pobj));
  fGets.Add<bool>          ("wprot",    bind(&Rw11UnitTape::WProt, pobj));
  fGets.Add<size_t>        ("capacity", bind(&Rw11UnitTape::Capacity, pobj));
  fGets.Add<bool>          ("bot",      bind(&Rw11UnitTape::Bot, pobj));
  fGets.Add<bool>          ("eot",      bind(&Rw11UnitTape::Eot, pobj));
  fGets.Add<bool>          ("eom",      bind(&Rw11UnitTape::Eom, pobj));
  fGets.Add<int>           ("posfile",  bind(&Rw11UnitTape::PosFile, pobj));
  fGets.Add<int>           ("posrecord",bind(&Rw11UnitTape::PosRecord, pobj));

  fSets.Add<const string&> ("type", bind(&Rw11UnitTape::SetType,pobj, _1));
  fSets.Add<bool>     ("wprot",     bind(&Rw11UnitTape::SetWProt,pobj, _1));
  fSets.Add<size_t>   ("capacity",  bind(&Rw11UnitTape::SetCapacity,pobj, _1));
  fSets.Add<int>      ("posfile",   bind(&Rw11UnitTape::SetPosFile,pobj, _1));
  fSets.Add<int>      ("posrecord", bind(&Rw11UnitTape::SetPosRecord,pobj, _1));
  
  return;
}

} // end namespace Retro
