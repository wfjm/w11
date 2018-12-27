// $Id: RosPrintfBase.cpp 1091 2018-12-23 12:38:29Z mueller $
//
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-22  1091   1.0.1  virtual dtor now outlined to streamline vtable
// 2011-02-25   364   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RosPrintfBase .
*/

#include <sstream>

#include "RosPrintfBase.hpp"

using namespace std;

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
/*!
  \brief Destructor.
*/

RosPrintfBase::~RosPrintfBase()
{}

//------------------------------------------+-----------------------------------
/*!
  \relates RosPrintfBase
  \brief string insertion
*/

std::string& operator<<(std::string& os, const RosPrintfBase& obj)
{
  std::ostringstream sos;
  obj.ToStream(sos);
  os += sos.str();
  return os;
}

} // end namespace Retro
