// $Id: RtclRw11UnitTape.cpp 1082 2018-12-15 13:56:20Z mueller $
//
// Copyright 2015-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-08   870   1.1    use Rw11UnitTape& ObjUV(); inherit from RtclRw11Unit
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11UnitTape.
*/

#include "RtclRw11UnitTape.hpp"

using namespace std;

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

  fGets.Add<const string&> ("type",      [pobj](){ return pobj->Type(); });
  fGets.Add<bool>          ("wprot",     [pobj](){ return pobj->WProt(); });
  fGets.Add<size_t>        ("capacity",  [pobj](){ return pobj->Capacity(); });
  fGets.Add<bool>          ("bot",       [pobj](){ return pobj->Bot(); });
  fGets.Add<bool>          ("eot",       [pobj](){ return pobj->Eot(); });
  fGets.Add<bool>          ("eom",       [pobj](){ return pobj->Eom(); });
  fGets.Add<int>           ("posfile",   [pobj](){ return pobj->PosFile(); });
  fGets.Add<int>           ("posrecord", [pobj](){ return pobj->PosRecord(); });

  fSets.Add<const string&> ("type",  
                            [pobj](const string& v){ pobj->SetType(v); });
  fSets.Add<bool>          ("wprot",  
                            [pobj](bool v){ pobj->SetWProt(v); });
  fSets.Add<size_t>        ("capacity",  
                            [pobj](size_t v){ pobj->SetCapacity(v); });
  fSets.Add<int>           ("posfile",  
                            [pobj](int v){ pobj->SetPosFile(v); });
  fSets.Add<int>           ("posrecord",  
                            [pobj](int v){ pobj->SetPosRecord(v); });
  return;
}

} // end namespace Retro
