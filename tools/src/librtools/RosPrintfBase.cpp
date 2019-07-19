// $Id: RosPrintfBase.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-22  1091   1.0.1  virtual dtor now outlined to streamline vtable
// 2011-02-25   364   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
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
