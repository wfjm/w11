// $Id: RtclRw11VirtBase.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-03-11   859   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
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
