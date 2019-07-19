// $Id: RerrMsg.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-21  1090   1.2.1  use constructor delegation
// 2013-01-12   474   1.2    add meth+text and meth+text+errnum ctors
// 2011-02-06   359   1.1    use references in interface, fix printf usage
// 2011-01-15   356   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RerrMsg.
*/

#include <string.h>
#include <stdio.h>
#include <stdarg.h>

#include "RerrMsg.hpp"

using namespace std;

/*!
  \class Retro::RerrMsg
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RerrMsg::RerrMsg()
  : fMeth(),
    fText()
{}

//------------------------------------------+-----------------------------------
//! Copy constructor

RerrMsg::RerrMsg(const RerrMsg& rhs)
  : RerrMsg(rhs.fMeth, rhs.fText)
{}

//------------------------------------------+-----------------------------------
//! Construct from method and message text

RerrMsg::RerrMsg(const std::string& meth, const std::string& text)
  : fMeth(meth),
    fText(text)
{}

//------------------------------------------+-----------------------------------
//! Construct from method and message text and errno

RerrMsg::RerrMsg(const std::string& meth, const std::string& text, int errnum)
  : RerrMsg(meth, text)
{
  AppendErrno(errnum);
}

//------------------------------------------+-----------------------------------
//! Destructor

RerrMsg::~RerrMsg()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RerrMsg::Init(const std::string& meth, const std::string& text)
{
  fMeth = meth;
  fText = text;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RerrMsg::InitErrno(const std::string& meth,
                        const std::string& text, int errnum)
{
  fMeth = meth;
  fText = text;
  AppendErrno(errnum);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RerrMsg::InitPrintf(const std::string& meth, const char* format, ...)
{
  fMeth = meth;

  char buf[1024];
  buf[0] = 0;
  
  va_list ap;
  va_start (ap, format);
  vsnprintf (buf, sizeof(buf), format, ap);
  va_end (ap);

  fText = buf;

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RerrMsg::Prepend(const std::string& meth)
{
  fMeth = meth + "->" + fMeth;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RerrMsg::Append(const std::string& text)
{
  fText += text;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RerrMsg::AppendErrno(int errnum)
{
  fText += strerror(errnum);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RerrMsg::AppendPrintf(const char* format, ...)
{
  char buf[1024];
  buf[0] = 0;
  
  va_list ap;
  va_start (ap, format);
  vsnprintf (buf, sizeof(buf), format, ap);
  va_end (ap);

  fText += buf;

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string RerrMsg::Message() const
{
  return fMeth + ": " + fText;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RerrMsg::Swap(RerrMsg& rhs)
{
  fMeth.swap(rhs.fMeth);
  fText.swap(rhs.fText);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RerrMsg& RerrMsg::operator=(const RerrMsg& rhs)
{
  if (&rhs == this) return *this;
  fMeth = rhs.fMeth;
  fText = rhs.fText;
  return *this;  
}

} // end namespace Retro
