// $Id: RtclRw11Unit.cpp 863 2017-04-02 11:43:15Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-02   863   1.1    add fpVirt; add DetachCleanup()
// 2013-03-03   494   1.0    Initial version
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11Unit.cpp 863 2017-04-02 11:43:15Z mueller $
  \brief   Implemenation of RtclRw11Unit.
*/

#include "boost/thread/locks.hpp"
#include "boost/bind.hpp"

#include "librtools/Rexception.hpp"
#include "librtcltools/RtclStats.hpp"

#include "RtclRw11Unit.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11Unit
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RtclRw11Unit::RtclRw11Unit(const std::string& type, Rw11Cpu* pcpu)
  : RtclProxyBase(type),
    fpCpu(pcpu),
    fGets(),
    fSets(),
    fpVirt()
{
  AddMeth("get",      boost::bind(&RtclRw11Unit::M_get,     this, _1));
  AddMeth("set",      boost::bind(&RtclRw11Unit::M_set,     this, _1));
  AddMeth("attach",   boost::bind(&RtclRw11Unit::M_attach,  this, _1));
  AddMeth("detach",   boost::bind(&RtclRw11Unit::M_detach,  this, _1));
  AddMeth("dump",     boost::bind(&RtclRw11Unit::M_dump,    this, _1));
  AddMeth("$default", boost::bind(&RtclRw11Unit::M_default, this, _1));
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11Unit::~RtclRw11Unit()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclRw11Unit::DetachCleanup()
{
  if (!fpVirt) return;
  DelMeth("virt");
  fpVirt.reset();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_get(RtclArgs& args)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(fpCpu->Connect());
  return fGets.M_get(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_set(RtclArgs& args)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(fpCpu->Connect());
  return fSets.M_set(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_attach(RtclArgs& args)
{
  string url;
  if (!args.GetArg("url", url)) return kERR;

  if (!args.AllDone()) return kERR;

  RerrMsg emsg;
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(fpCpu->Connect());

  DetachCleanup();
  if (!Obj().Attach(url, emsg)) return args.Quit(emsg);
  AttachDone();
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_detach(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;

  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(fpCpu->Connect());
  Obj().Detach();
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_virt(RtclArgs& args)
{
  if (!fpVirt) throw Rexception("RtclRw11Unit::M_virt:",
                                "Bad state: fpVirt == nullptr");
  
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(fpCpu->Connect());
  return fpVirt->DispatchCmd(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_dump(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;

  ostringstream sos;
  Obj().Dump(sos, 0);
  args.SetResult(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  ostringstream sos;
  sos << "no default output defined yet...\n";
  args.AppendResultLines(sos);
  return kOK;
}

} // end namespace Retro
