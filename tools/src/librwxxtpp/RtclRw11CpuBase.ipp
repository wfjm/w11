// $Id: RtclRw11CpuBase.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.0.1  use std::shared_ptr instead of boost
// 2013-02-23   491   1.0    Initial version
// 2013-02-08   484   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (all inline) of RtclRw11CpuBase.
*/

/*!
  \class Retro::RtclRw11CpuBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

template <class TO>
inline RtclRw11CpuBase<TO>::RtclRw11CpuBase(Tcl_Interp* interp, 
                                            const char* name,
                                            const std::string& type)
  : RtclRw11Cpu(type),
    fspObj(new TO())
{
  CreateObjectCmd(interp, name);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline RtclRw11CpuBase<TO>::~RtclRw11CpuBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline TO& RtclRw11CpuBase<TO>::Obj()
{
  return *fspObj;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline const std::shared_ptr<TO>& RtclRw11CpuBase<TO>::ObjSPtr()
{
  return fspObj;
}


} // end namespace Retro
