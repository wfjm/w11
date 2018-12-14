// $Id: RtclRw11CntlBase.ipp 1078 2018-12-08 14:19:03Z mueller $
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
// 2018-12-07  1078   1.2.1  use std::shared_ptr instead of boost
// 2017-04-16   877   1.2    add class in ctor
// 2017-02-04   848   1.1    add in fGets: found,pdataint,pdatarem
// 2013-03-06   495   1.0    Initial version
// 2013-02-08   484   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (all inline) of RtclRw11CntlBase.
*/

/*!
  \class Retro::RtclRw11CntlBase
  \brief FIXME_docs
*/

#include "librtcltools/Rtcl.hpp"
#include "librtcltools/RtclOPtr.hpp"

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

template <class TC>
inline RtclRw11CntlBase<TC>::RtclRw11CntlBase(const std::string& type,
                                              const std::string& cclass)
  : RtclRw11Cntl(type,cclass),
    fspObj(new TC())
{
  AddMeth("bootcode", boost::bind(&RtclRw11CntlBase<TC>::M_bootcode,this, _1));

  TC* pobj = fspObj.get();
  fGets.Add<const std::string&>("type",  boost::bind(&TC::Type, pobj));
  fGets.Add<const std::string&>("name",  boost::bind(&TC::Name, pobj));
  fGets.Add<uint16_t>    ("base",  boost::bind(&TC::Base, pobj));
  fGets.Add<int>         ("lam",   boost::bind(&TC::Lam,  pobj));  
  fGets.Add<bool>        ("found", boost::bind(&TC::ProbeFound, pobj));  
  fGets.Add<uint16_t>    ("pdataint", boost::bind(&TC::ProbeDataInt, pobj));  
  fGets.Add<uint16_t>    ("pdatarem", boost::bind(&TC::ProbeDataRem, pobj));  
  fGets.Add<bool>        ("enable",boost::bind(&TC::Enable, pobj));  
  fGets.Add<bool>        ("started",boost::bind(&TC::IsStarted, pobj));  
  fGets.Add<uint32_t>    ("trace", boost::bind(&TC::TraceLevel,pobj));  

  fSets.Add<bool>        ("enable", boost::bind(&TC::SetEnable,pobj,_1));  
  fSets.Add<uint32_t>    ("trace", boost::bind(&TC::SetTraceLevel,pobj,_1));  
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline RtclRw11CntlBase<TC>::~RtclRw11CntlBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline TC& RtclRw11CntlBase<TC>::Obj()
{
  return *fspObj;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline const std::shared_ptr<TC>& RtclRw11CntlBase<TC>::ObjSPtr()
{
  return fspObj;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
int RtclRw11CntlBase<TC>::M_bootcode(RtclArgs& args)
{
  int unit = 0;
  if (!args.GetArg("?unit", unit, 0, Obj().NUnit()-1)) return kERR;
  if (!args.AllDone()) return kERR;

  std::vector<uint16_t> code;
  uint16_t aload;
  uint16_t astart;
  if (Obj().BootCode(unit, code, aload, astart)) {
    RtclOPtr pres(Tcl_NewListObj(0, NULL));
    Tcl_ListObjAppendElement(NULL, pres, Tcl_NewIntObj((int)aload));
    Tcl_ListObjAppendElement(NULL, pres, Tcl_NewIntObj((int)astart));
    Tcl_ListObjAppendElement(NULL, pres, Rtcl::NewListIntObj(code));
    args.SetResult(pres);
  }

  return kOK;
}  

} // end namespace Retro
