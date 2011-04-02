// $Id:  $
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
// 2011-03-12   368   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id:  $
  \brief   Implemenation of Rtools .
*/

#include <stdexcept>

#include "Rtools.hpp"

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
#if (defined(Retro_NoInline) || defined(Retro_Rtools_NoInline))
#define inline
//#include "Rtools.ipp"
#undef  inline
#endif
