// $Id: RtclRw11UnitDisk.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-02-23  1114   1.2.3  use std::bind instead of lambda
// 2018-12-15  1082   1.2.2  use lambda instead of boost::bind
// 2018-10-06  1053   1.2.1  move using after includes (clang warning)
// 2017-04-08   870   1.2    use Rw11UnitDisk& ObjUV(); inherit from RtclRw11Unit
// 2015-05-14   680   1.1.1  fGets: remove enabled, now in RtclRw11UnitBase
// 2015-03-21   659   1.1    fGets: add enabled
// 2013-04-19   507   1.0    Initial version
// 2013-02-22   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclRw11UnitDisk.
*/

#include <functional>

#include "RtclRw11UnitDisk.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::RtclRw11UnitDisk
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitDisk::RtclRw11UnitDisk(const std::string& type)
  : RtclRw11Unit(type)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclRw11UnitDisk::~RtclRw11UnitDisk()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclRw11UnitDisk::SetupGetSet()
{
  // this can't be in ctor because pure virtual is called which is available
  // only when more derived class is being constructed. SetupGetSet() must be
  // called in ctor of a more derived class.

  Rw11UnitDisk* pobj = &ObjUV();
  
  fGets.Add<const string&> ("type",      bind(&Rw11UnitDisk::Type,  pobj));
  fGets.Add<size_t>        ("ncylinder", bind(&Rw11UnitDisk::NCylinder,  pobj));
  fGets.Add<size_t>        ("nhead",     bind(&Rw11UnitDisk::NHead,  pobj));
  fGets.Add<size_t>        ("nsector",   bind(&Rw11UnitDisk::NSector,  pobj));
  fGets.Add<size_t>        ("blocksize", bind(&Rw11UnitDisk::BlockSize,  pobj));
  fGets.Add<size_t>        ("nblock",    bind(&Rw11UnitDisk::NBlock,  pobj));
  fGets.Add<bool>          ("wprot",     bind(&Rw11UnitDisk::WProt, pobj));

  fSets.Add<const string&> ("type", bind(&Rw11UnitDisk::SetType,pobj, _1));
  
  return;
}

} // end namespace Retro
