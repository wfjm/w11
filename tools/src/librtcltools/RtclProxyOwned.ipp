// $Id: RtclProxyOwned.ipp 365 2011-02-28 07:28:26Z mueller $
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
// 2011-02-13   361   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id:  
  \brief   Implemenation (inline) of class RtclProxyOwned.
*/

// all method definitions in namespace Retro (avoid using in includes...)
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

template <class TO>
inline RtclProxyOwned<TO>::RtclProxyOwned()
  : RtclProxyBase(),
    fpObj(0)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline RtclProxyOwned<TO>::RtclProxyOwned(const std::string& type)
  : RtclProxyBase(type),
    fpObj(0)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline RtclProxyOwned<TO>::RtclProxyOwned(const std::string& type,
                                          Tcl_Interp* interp, const char* name, 
                                          TO* pobj)
  : RtclProxyBase(type),
    fpObj(pobj)
{
  CreateObjectCmd(interp, name);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline RtclProxyOwned<TO>::~RtclProxyOwned()
{
  delete fpObj;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline TO& RtclProxyOwned<TO>::Obj()
{
  return *fpObj;
}

} // end namespace Retro
