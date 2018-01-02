// $Id: RtclRw11VirtBase.ipp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-03-11   859   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (all inline) of RtclRw11VirtBase.
*/

/*!
  \class Retro::RtclRw11VirtBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

template <class TO>
inline RtclRw11VirtBase<TO>::RtclRw11VirtBase(TO* pobj)
  : RtclRw11Virt(pobj),
    fpObj(pobj)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline RtclRw11VirtBase<TO>::~RtclRw11VirtBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline TO& RtclRw11VirtBase<TO>::Obj()
{
  return *fpObj;
}


} // end namespace Retro
