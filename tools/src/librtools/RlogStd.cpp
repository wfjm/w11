// $Id: RlogStd.cpp 359 2011-02-06 22:37:43Z mueller $
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
// 2011-02-04   358   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlogStd.cpp 359 2011-02-06 22:37:43Z mueller $
  \brief   Implemenation of RlogStd.
*/

#include <iostream>

#include "RlogStd.hpp"

//------------------------------------------+-----------------------------------
// define global RlogFile objects

Retro::RlogFile Retro::gRcout(&std::cout);  //!< foo
Retro::RlogFile Retro::gRcerr(&std::cerr);  //!< bar

