// $Id: RtclRw11UnitStream.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-02-23  1114   1.1.3  use std::bind instead of lambda
// 2018-12-15  1082   1.1.2  use lambda instead of boost::bind
// 2018-10-06  1053   1.1.1  move using after includes (clang warning)
// 2017-04-08   870   1.1    use Rw11UnitStream& ObjUV(); inh from RtclRw11Unit
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclRw11UnitStream.
*/

#include <functional>

#include "RtclRw11UnitStream.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::RtclRw11UnitStream
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitStream::RtclRw11UnitStream(const std::string& type)
  : RtclRw11Unit(type)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclRw11UnitStream::~RtclRw11UnitStream()
{}


//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclRw11UnitStream::SetupGetSet()
{
  // this can't be in ctor because pure virtual is called which is available
  // only when more derived class is being constructed. SetupGetSet() must be
  // called in ctor of a more derived class.

  Rw11UnitStream* pobj = &ObjUV();

  fGets.Add<int>           ("pos", bind(&Rw11UnitStream::Pos,  pobj));

  fSets.Add<int>           ("pos", bind(&Rw11UnitStream::SetPos,pobj, _1));

  return;
}
} // end namespace Retro
