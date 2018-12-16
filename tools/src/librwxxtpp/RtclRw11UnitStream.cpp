// $Id: RtclRw11UnitStream.cpp 1082 2018-12-15 13:56:20Z mueller $
//
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-15  1082   1.1.2  use lambda instead of bind
// 2018-10-06  1053   1.1.1  move using after includes (clang warning)
// 2017-04-08   870   1.1    use Rw11UnitStream& ObjUV(); inh from RtclRw11Unit
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11UnitStream.
*/

#include "RtclRw11UnitStream.hpp"

using namespace std;

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

  fGets.Add<int>           ("pos", [pobj](){ return pobj->Pos(); });

  fSets.Add<int>           ("pos", [pobj](int v){ pobj->SetPos(v); });
  return;
}
} // end namespace Retro
