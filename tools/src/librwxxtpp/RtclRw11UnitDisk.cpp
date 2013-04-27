// $Id: RtclRw11UnitDisk.cpp 509 2013-04-21 20:46:20Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-04-19   507   1.0    Initial version
// 2013-02-22   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11UnitDisk.cpp 509 2013-04-21 20:46:20Z mueller $
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

RtclRw11UnitDisk::RtclRw11UnitDisk(RtclRw11Unit* ptcl, Rw11UnitDisk* pobj)
  : fpTcl(ptcl),
    fpObj(pobj)
{
  RtclGetList& gets = ptcl->GetList();
  RtclSetList& sets = ptcl->SetList();
  gets.Add<const string&> ("type",  
                            boost::bind(&Rw11UnitDisk::Type,  pobj));
  gets.Add<size_t>        ("ncylinder",  
                            boost::bind(&Rw11UnitDisk::NCylinder,  pobj));
  gets.Add<size_t>        ("nhead",  
                            boost::bind(&Rw11UnitDisk::NHead,  pobj));
  gets.Add<size_t>        ("nsector",  
                            boost::bind(&Rw11UnitDisk::NSector,  pobj));
  gets.Add<size_t>        ("blocksize",  
                            boost::bind(&Rw11UnitDisk::BlockSize,  pobj));
  gets.Add<size_t>        ("nblock",  
                            boost::bind(&Rw11UnitDisk::NBlock,  pobj));
  gets.Add<bool>          ("wprot",  
                            boost::bind(&Rw11UnitDisk::WProt, pobj));

  sets.Add<const string&> ("type",  
                            boost::bind(&Rw11UnitDisk::SetType,pobj, _1));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclRw11UnitDisk::~RtclRw11UnitDisk()
{}


} // end namespace Retro
