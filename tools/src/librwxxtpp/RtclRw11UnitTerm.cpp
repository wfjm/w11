// $Id: RtclRw11UnitTerm.cpp 1082 2018-12-15 13:56:20Z mueller $
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
// 2017-04-08   870   1.1    use Rw11UnitTerm& ObjUV(); inherit from RtclRw11Unit
// 2013-04-26   511   1.0.1  add M_type
// 2013-03-03   494   1.0    Initial version
// 2013-03-01   493   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RtclRw11UnitTerm.
*/

#include "RtclRw11UnitTerm.hpp"

using namespace std;

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
  AddMeth("type",  [this](RtclArgs& args){ return M_type(args); });
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

  fGets.Add<const string&> ("channelid", [pobj](){ return pobj->ChannelId(); });
  fGets.Add<bool>          ("to7bit",    [pobj](){ return pobj->To7bit(); });
  fGets.Add<bool>          ("toenpc",    [pobj](){ return pobj->ToEnpc(); });
  fGets.Add<bool>          ("ti7bit",    [pobj](){ return pobj->Ti7bit(); });
  fGets.Add<const string&> ("log",       [pobj](){ return pobj->Log(); });

  fSets.Add<bool>          ("to7bit", [pobj](bool v){ pobj->SetTo7bit(v); });
  fSets.Add<bool>          ("toenpc", [pobj](bool v){ pobj->SetToEnpc(v); });
  fSets.Add<bool>          ("ti7bit", [pobj](bool v){ pobj->SetTi7bit(v); });
  fSets.Add<const string&> ("log",
                            [pobj](const string& v){ pobj->SetLog(v); });
  return;
}

  
} // end namespace Retro
