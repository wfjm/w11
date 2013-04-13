// $Id: RtclRw11UnitTerm.cpp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-03-03   494   1.0    Initial version
// 2013-03-01   493   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11UnitTerm.cpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Implemenation of RtclRw11UnitTerm.
*/

using namespace std;

#include "RtclRw11UnitTerm.hpp"

/*!
  \class Retro::RtclRw11UnitTerm
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitTerm::RtclRw11UnitTerm(RtclRw11Unit* ptcl, Rw11UnitTerm* pobj)
  : fpTcl(ptcl),
    fpObj(pobj)
{
  RtclGetList& gets = ptcl->GetList();
  RtclSetList& sets = ptcl->SetList();

  gets.Add<const string&> ("channelid",  
                            boost::bind(&Rw11UnitTerm::ChannelId,  pobj));
  gets.Add<bool>          ("rcv7bit",  
                            boost::bind(&Rw11UnitTerm::Rcv7bit,  pobj));

  sets.Add<bool>          ("rcv7bit",  
                            boost::bind(&Rw11UnitTerm::SetRcv7bit,pobj, _1));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclRw11UnitTerm::~RtclRw11UnitTerm()
{}


} // end namespace Retro
