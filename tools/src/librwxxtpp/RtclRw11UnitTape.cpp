// $Id: RtclRw11UnitTape.cpp 870 2017-04-08 18:24:34Z mueller $
//
// Copyright 2015-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-08   870   1.1    use Rw11UnitTape& ObjUV(); inherit from RtclRw11Unit
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11UnitTape.cpp 870 2017-04-08 18:24:34Z mueller $
  \brief   Implemenation of RtclRw11UnitTape.
*/

using namespace std;

#include "RtclRw11UnitTape.hpp"

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

  fGets.Add<const string&> ("type",  
                            boost::bind(&Rw11UnitTape::Type,  pobj));
  fGets.Add<bool>          ("wprot",  
                            boost::bind(&Rw11UnitTape::WProt, pobj));
  fGets.Add<size_t>        ("capacity",  
                            boost::bind(&Rw11UnitTape::Capacity, pobj));
  fGets.Add<bool>          ("bot",  
                            boost::bind(&Rw11UnitTape::Bot, pobj));
  fGets.Add<bool>          ("eot",  
                            boost::bind(&Rw11UnitTape::Eot, pobj));
  fGets.Add<bool>          ("eom",  
                            boost::bind(&Rw11UnitTape::Eom, pobj));
  fGets.Add<int>           ("posfile",  
                            boost::bind(&Rw11UnitTape::PosFile, pobj));
  fGets.Add<int>           ("posrecord",  
                            boost::bind(&Rw11UnitTape::PosRecord, pobj));

  fSets.Add<const string&> ("type",  
                            boost::bind(&Rw11UnitTape::SetType,pobj, _1));
  fSets.Add<bool>          ("wprot",  
                            boost::bind(&Rw11UnitTape::SetWProt,pobj, _1));
  fSets.Add<size_t>        ("capacity",  
                            boost::bind(&Rw11UnitTape::SetCapacity,pobj, _1));
  fSets.Add<int>           ("posfile",  
                            boost::bind(&Rw11UnitTape::SetPosFile,pobj, _1));
  fSets.Add<int>           ("posrecord",  
                            boost::bind(&Rw11UnitTape::SetPosRecord,pobj, _1));
  return;
}

} // end namespace Retro
