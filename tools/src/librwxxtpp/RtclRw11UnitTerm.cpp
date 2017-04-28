// $Id: RtclRw11UnitTerm.cpp 887 2017-04-28 19:32:52Z mueller $
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
// 2017-04-08   870   1.1    use Rw11UnitTerm& ObjUV(); inherit from RtclRw11Unit
// 2013-04-26   511   1.0.1  add M_type
// 2013-03-03   494   1.0    Initial version
// 2013-03-01   493   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
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

RtclRw11UnitTerm::RtclRw11UnitTerm(const std::string& type)
  : RtclRw11Unit(type)
{
  AddMeth("type",  boost::bind(&RtclRw11UnitTerm::M_type,    this, _1));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclRw11UnitTerm::~RtclRw11UnitTerm()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11UnitTerm::M_type(RtclArgs& args)
{
  string text;
  if (!args.GetArg("text", text)) return TCL_ERROR;
  if (!args.AllDone()) return TCL_ERROR;

  ObjUV().RcvCallback((const uint8_t*)text.data(), text.size());

  return TCL_OK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclRw11UnitTerm::SetupGetSet()
{
  // this can't be in ctor because pure virtual is called which is available
  // only when more derived class is being constructed. SetupGetSet() must be
  // called in ctor of a more derived class.

  Rw11UnitTerm* pobj = &ObjUV();

  fGets.Add<const string&> ("channelid",  
                            boost::bind(&Rw11UnitTerm::ChannelId,  pobj));
  fGets.Add<bool>          ("to7bit",  
                            boost::bind(&Rw11UnitTerm::To7bit,  pobj));
  fGets.Add<bool>          ("toenpc",  
                            boost::bind(&Rw11UnitTerm::ToEnpc,  pobj));
  fGets.Add<bool>          ("ti7bit",  
                            boost::bind(&Rw11UnitTerm::Ti7bit,  pobj));
  fGets.Add<const string&> ("log",  
                            boost::bind(&Rw11UnitTerm::Log,  pobj));

  fSets.Add<bool>          ("to7bit",  
                            boost::bind(&Rw11UnitTerm::SetTo7bit,pobj, _1));
  fSets.Add<bool>          ("toenpc",  
                            boost::bind(&Rw11UnitTerm::SetToEnpc,pobj, _1));
  fSets.Add<bool>          ("ti7bit",  
                            boost::bind(&Rw11UnitTerm::SetTi7bit,pobj, _1));
  fSets.Add<const string&> ("log",  
                            boost::bind(&Rw11UnitTerm::SetLog,pobj, _1));
  return;
}

  
} // end namespace Retro
