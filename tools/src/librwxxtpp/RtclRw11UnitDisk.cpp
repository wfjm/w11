// $Id: RtclRw11UnitDisk.cpp 870 2017-04-08 18:24:34Z mueller $
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
// 2017-04-08   870   1.1    use Rw11UnitDisk& ObjUV(); inherit from RtclRw11Unit
// 2015-05-14   680   1.1.1  fGets: remove enabled, now in RtclRw11UnitBase
// 2015-03-21   659   1.1    fGets: add enabled
// 2013-04-19   507   1.0    Initial version
// 2013-02-22   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11UnitDisk.cpp 870 2017-04-08 18:24:34Z mueller $
  \brief   Implemenation of RtclRw11UnitDisk.
*/

using namespace std;

#include "RtclRw11UnitDisk.hpp"

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
  
  fGets.Add<const string&> ("type",  
                            boost::bind(&Rw11UnitDisk::Type,  pobj));
  fGets.Add<size_t>        ("ncylinder",  
                            boost::bind(&Rw11UnitDisk::NCylinder,  pobj));
  fGets.Add<size_t>        ("nhead",  
                            boost::bind(&Rw11UnitDisk::NHead,  pobj));
  fGets.Add<size_t>        ("nsector",  
                            boost::bind(&Rw11UnitDisk::NSector,  pobj));
  fGets.Add<size_t>        ("blocksize",  
                            boost::bind(&Rw11UnitDisk::BlockSize,  pobj));
  fGets.Add<size_t>        ("nblock",  
                            boost::bind(&Rw11UnitDisk::NBlock,  pobj));
  fGets.Add<bool>          ("wprot",  
                            boost::bind(&Rw11UnitDisk::WProt, pobj));

  fSets.Add<const string&> ("type",  
                            boost::bind(&Rw11UnitDisk::SetType,pobj, _1));
  return;
}

} // end namespace Retro
