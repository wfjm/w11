// $Id: RtclOPtr.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-02-20   363   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of RtclOPtr.
*/

/*!
  \class Retro::RtclOPtr
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

inline RtclOPtr::RtclOPtr()
  : fpObj(nullptr)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RtclOPtr::RtclOPtr(Tcl_Obj* pobj)
  : fpObj(pobj)
{
  if (fpObj) Tcl_IncrRefCount(fpObj);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RtclOPtr::RtclOPtr(const RtclOPtr& rhs)
  : fpObj(rhs.fpObj)
{
  if (fpObj) Tcl_IncrRefCount(fpObj);
}

//------------------------------------------+-----------------------------------
//! Destructor

inline RtclOPtr::~RtclOPtr()
{
  if (fpObj) Tcl_DecrRefCount(fpObj);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RtclOPtr::operator Tcl_Obj*() const
{
  return fpObj;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RtclOPtr::operator !() const
{
  return fpObj==nullptr;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RtclOPtr& RtclOPtr::operator=(const RtclOPtr& rhs)
{
  if (&rhs == this) return *this;
  return operator=(rhs.fpObj);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RtclOPtr& RtclOPtr::operator=(Tcl_Obj* pobj)
{
  if (fpObj) Tcl_DecrRefCount(fpObj);
  fpObj = pobj;
  if (fpObj) Tcl_IncrRefCount(fpObj);
  return *this;
}

} // end namespace Retro
