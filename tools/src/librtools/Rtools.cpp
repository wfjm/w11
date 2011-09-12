// $Id: Rtools.cpp 403 2011-08-06 17:36:22Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-04-10   376   1.0.1  add ThrowLogic(), ThrowRuntime()
// 2011-03-12   368   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rtools.cpp 403 2011-08-06 17:36:22Z mueller $
  \brief   Implemenation of Rtools .
*/

#include <stdexcept>

#include "Rtools.hpp"
#include "RerrMsg.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::Rtools
  \brief FIXME_docs
*/

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string Rtools::Flags2String(uint32_t flags, const RflagName* fnam,
                                 char delim)
{
  if (fnam == 0)
    throw invalid_argument("Rtools::Flags2String: fnam==NULL");

  string rval;
  while (fnam->mask) {
    if (flags & fnam->mask) {
      if (!rval.empty()) rval += delim;
      rval += fnam->name;
    }
    fnam++;
  }
  return rval;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rtools::ThrowLogic(const std::string& meth, 
                        const std::string& text, int errnum)
{
  RerrMsg emsg;
  emsg.Init(meth, text);
  if (errnum != 0) emsg.AppendErrno(errnum);
  throw logic_error(emsg.Message());
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rtools::ThrowRuntime(const std::string& meth, 
                          const std::string& text, int errnum)
{
  RerrMsg emsg;
  emsg.Init(meth, text);
  if (errnum != 0) emsg.AppendErrno(errnum);
  throw runtime_error(emsg.Message());
}

//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_Rtools_NoInline))
#define inline
//#include "Rtools.ipp"
#undef  inline
#endif
