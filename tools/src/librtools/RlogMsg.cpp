// $Id: RlogMsg.cpp 1085 2018-12-16 14:11:16Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-02-22   490   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RlogMsg.
*/

#include "RlogFile.hpp"

#include "RlogMsg.hpp"

using namespace std;

/*!
  \class Retro::RlogMsg
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RlogMsg::RlogMsg(char tag)
  : fStream(),
    fLfile(0),
    fTag(tag)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlogMsg::RlogMsg(RlogFile& lfile, char tag)
  : fStream(),
    fLfile(&lfile),
    fTag(tag)
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlogMsg::~RlogMsg()
{
  if (fLfile) *fLfile << *this;
}

} // end namespace Retro
