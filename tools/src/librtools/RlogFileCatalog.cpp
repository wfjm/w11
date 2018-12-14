// $Id: RlogFileCatalog.cpp 1078 2018-12-08 14:19:03Z mueller $
//
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-07  1078   1.0.2  use std::shared_ptr instead of boost
// 2018-11-09  1066   1.0.1  use auto; use make_pair,emplace
// 2013-02-22   491   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation of RlogFileCatalog.
*/

#include <iostream> 

#include "RlogFileCatalog.hpp"

using namespace std;

/*!
  \class Retro::RlogFileCatalog
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlogFileCatalog& RlogFileCatalog::Obj()
{
  static RlogFileCatalog obj;               // lazy creation singleton
  return obj;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

const std::shared_ptr<RlogFile>& 
  RlogFileCatalog::FindOrCreate(const std::string& name)
{
  auto it = fMap.find(name);
  if (it != fMap.end()) return it->second;

  std::shared_ptr<RlogFile> sptr(new RlogFile());
  auto pitb = fMap.emplace(make_pair(name, sptr));

  return pitb.first->second;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlogFileCatalog::Delete(const std::string& name)
{
  fMap.erase(name);
  return;
}

//------------------------------------------+-----------------------------------
//! Default constructor

RlogFileCatalog::RlogFileCatalog()
{
  FindOrCreate("cout")->UseStream(&cout);
  FindOrCreate("cerr")->UseStream(&cerr);
}

//------------------------------------------+-----------------------------------
//! Destructor

RlogFileCatalog::~RlogFileCatalog()
{}

} // end namespace Retro
