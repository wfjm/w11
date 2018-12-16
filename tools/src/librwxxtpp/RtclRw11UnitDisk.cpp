// $Id: RtclRw11UnitDisk.cpp 1082 2018-12-15 13:56:20Z mueller $
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
// 2018-12-15  1082   1.2.2  use lambda instead of bind
// 2018-10-06  1053   1.2.1  move using after includes (clang warning)
// 2017-04-08   870   1.2    use Rw11UnitDisk& ObjUV(); inherit from RtclRw11Unit
// 2015-05-14   680   1.1.1  fGets: remove enabled, now in RtclRw11UnitBase
// 2015-03-21   659   1.1    fGets: add enabled
// 2013-04-19   507   1.0    Initial version
// 2013-02-22   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11UnitDisk.
*/

#include "RtclRw11UnitDisk.hpp"

using namespace std;

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
  
  fGets.Add<const string&> ("type",      [pobj](){ return pobj->Type(); });
  fGets.Add<size_t>        ("ncylinder", [pobj](){ return pobj->NCylinder(); });
  fGets.Add<size_t>        ("nhead",     [pobj](){ return pobj->NHead(); });
  fGets.Add<size_t>        ("nsector",   [pobj](){ return pobj->NSector(); });
  fGets.Add<size_t>        ("blocksize", [pobj](){ return pobj->BlockSize(); });
  fGets.Add<size_t>        ("nblock",    [pobj](){ return pobj->NBlock(); });
  fGets.Add<bool>          ("wprot",     [pobj](){ return pobj->WProt(); });

  fSets.Add<const string&> ("type",  
                            [pobj](const string& v){ pobj->SetType(v); });
  return;
}

} // end namespace Retro
