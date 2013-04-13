// $Id: Rtools.cpp 493 2013-03-01 21:02:33Z mueller $
//
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-02-13   481   1.0.2  remove Throw(Logic|Runtime)(); use Rexception
// 2011-04-10   376   1.0.1  add ThrowLogic(), ThrowRuntime()
// 2011-03-12   368   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rtools.cpp 493 2013-03-01 21:02:33Z mueller $
  \brief   Implemenation of Rtools .
*/

#include <stdlib.h>

#include "RerrMsg.hpp"
#include "Rexception.hpp"

#include "Rtools.hpp"

using namespace std;

/*!
  \namespace Retro::Rtools
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string Rtools::Flags2String(uint32_t flags, const RflagName* fnam,
                                 char delim)
{
  if (fnam == 0)
    throw Rexception("Rtools::Flags2String()","Bad args: fnam==NULL");

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

} // end namespace Retro
