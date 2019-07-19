// $Id: RlogMsg.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-02-22   490   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
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
