// $Id: RtclRw11UnitStream.cpp 887 2017-04-28 19:32:52Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-08   870   1.1    use Rw11UnitStream& ObjUV(); inh from RtclRw11Unit
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11UnitStream.
*/

using namespace std;

#include "RtclRw11UnitStream.hpp"

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

  fGets.Add<int>           ("pos",  
                             boost::bind(&Rw11UnitStream::Pos,  pobj));

  fSets.Add<int>           ("pos",  
                             boost::bind(&Rw11UnitStream::SetPos,pobj, _1));
  return;
}
} // end namespace Retro
