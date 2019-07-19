// $Id: RtclContext.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-18  1089   1.0.7  use c++ style casts
// 2018-12-02  1076   1.0.6  use nullptr
// 2018-11-16  1070   1.0.5  use auto; use emplace,make_pair; use range loop
// 2017-02-04   866   1.0.4  rename fMapContext -> fContextMap
// 2013-02-03   481   1.0.3  use Rexception
// 2013-01-12   474   1.0.2  add FindProxy() method
// 2011-03-12   368   1.0.1  drop fExitSeen, get exit handling right
// 2011-02-18   362   1.0    Initial version
// 2011-02-13   361   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RtclContext.
*/

#include <iostream>

#include "RtclContext.hpp"

#include "librtools/Rexception.hpp"

using namespace std;

/*!
  \class Retro::RtclContext
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

RtclContext::xmap_t RtclContext::fContextMap;

//------------------------------------------+-----------------------------------
//! Default constructor

RtclContext::RtclContext(Tcl_Interp* interp)
  : fInterp(interp),
    fSetClass(),
    fSetProxy()
{}

//------------------------------------------+-----------------------------------
//! Destructor

RtclContext::~RtclContext()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclContext::RegisterClass(RtclClassBase* pobj)
{
  auto ret = fSetClass.insert(pobj);
  if (ret.second == false)                  // or use !(ret.second)
    throw Rexception("RtclContext::RegisterClass()",
                     "Bad args: duplicate pointer");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclContext::UnRegisterClass(RtclClassBase* pobj)
{
  fSetClass.erase(pobj);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclContext::RegisterProxy(RtclProxyBase* pobj)
{
  auto ret = fSetProxy.insert(pobj);
  if (ret.second == false)                  // or use !(ret.second)
    throw Rexception("RtclContext::RegisterProxy()",
                     "Bad args: duplicate pointer");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclContext::UnRegisterProxy(RtclProxyBase* pobj)
{
  fSetProxy.erase(pobj);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclContext::CheckProxy(RtclProxyBase* pobj)
{
  auto it = fSetProxy.find(pobj);
  return it != fSetProxy.end();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclContext::CheckProxy(RtclProxyBase* pobj, const string& type)
{
  auto it = fSetProxy.find(pobj);
  if (it == fSetProxy.end()) return false;
  return (*it)->Type() == type;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclContext::ListProxy(std::vector<RtclProxyBase*>& list,
                            const std::string& type)
{
  list.clear();
  for (auto& po: fSetProxy) {
    if (type.length() == 0 || po->Type()==type) {
      list.push_back(po);
    }
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclProxyBase* RtclContext::FindProxy(const std::string& type, 
                                      const std::string& name)
{
  for (auto& po: fSetProxy) {
    if (type.length() == 0 || po->Type()==type) {
      const char* cmdname = Tcl_GetCommandName(fInterp, po->Token());
      if (name == cmdname) return po;
    }
  }
  return nullptr;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclContext& RtclContext::Find(Tcl_Interp* interp)
{
  RtclContext* pcntx = 0;
  auto it = fContextMap.find(interp);
  if (it != fContextMap.end()) {
    pcntx = it->second;
  } else {
    pcntx = new RtclContext(interp);
    fContextMap.emplace(make_pair(interp, pcntx));
    Tcl_CreateExitHandler(reinterpret_cast<Tcl_ExitProc*>(ThunkTclExitProc),
                          reinterpret_cast<ClientData>(pcntx));

  }
  return *pcntx;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

// Note: tcl exit handlers are executed in inverse order of creation.
//       If Find() is called before any Class or Proxy cleanup handlers
//       are created the exit handler created in Find() will be called
//       last, when all map entries have been erased.

void RtclContext::ThunkTclExitProc(ClientData cdata)
{
  RtclContext* pcntx = reinterpret_cast<RtclContext*>(cdata);
  if (pcntx->fSetClass.empty() && pcntx->fSetProxy.empty()) {
    delete pcntx;
  } else {
    cerr << "RtclContext::ThunkTclExitProc called when maps non-empty" << endl;
  }
  return;
}

} // end namespace Retro
