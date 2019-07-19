// $Id: RlogFileCatalog.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.0.2  use std::shared_ptr instead of boost
// 2018-11-09  1066   1.0.1  use auto; use make_pair,emplace
// 2013-02-22   491   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
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
