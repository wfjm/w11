// $Id: Rexception.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-10-27  1060   1.3    drop throw() list; use noexcept
// 2017-04-29   888   1.2    BUGFIX: add fErrtxt for proper what() return
// 2014-12-30   625   1.1    add ctor(meth,text,emsg)
// 2013-01-12   474   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rexception.
*/

#include "Rexception.hpp"

using namespace std;

/*!
  \class Retro::Rexception
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rexception::Rexception()
  : fErrmsg(),
    fErrtxt()
{
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rexception::Rexception(const RerrMsg& errmsg)
  : fErrmsg(errmsg),
    fErrtxt(fErrmsg.Message())
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rexception::Rexception(const std::string& meth, const std::string& text)
  : fErrmsg(meth,text),
    fErrtxt(fErrmsg.Message())
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rexception::Rexception(const std::string& meth, const std::string& text, 
                       int errnum)
  : fErrmsg(meth,text,errnum),
    fErrtxt(fErrmsg.Message())
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rexception::Rexception(const std::string& meth, const std::string& text, 
                       const RerrMsg& errmsg)
  : fErrmsg(meth,text+errmsg.Message()),
    fErrtxt(fErrmsg.Message())
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rexception::~Rexception()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

const char* Rexception::what() const noexcept
{
  // what() must return a pointer to a string which stays valid at least as long
  // as the exception object lives. Use member variable fErrtxt for this.
  return fErrtxt.c_str();
}

} // end namespace Retro
