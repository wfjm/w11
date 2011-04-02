// $Id: RmethDsc.ipp 360 2011-02-11 20:35:11Z mueller $
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
// 2011-02-11   360   1.1    templetize object type TO and arglist type TA
// 2011-02-06   359   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RmethDsc.ipp 360 2011-02-11 20:35:11Z mueller $
  \brief   Implemenation (inline) of RmethDsc
*/

// all method definitions in namespace Retro (avoid using in includes...)
namespace Retro {

/*!
  \class RmethDsc 
  \brief FIXME_text
*/

//------------------------------------------+-----------------------------------
/*!
  \brief Default constructor.
*/

template <class TO, class TA>
inline RmethDsc<TO,TA>::RmethDsc()
  : fpObj(),
    fpMeth()
{}

//------------------------------------------+-----------------------------------
/*!
  \brief FIXME_text
*/

template <class TO, class TA>
inline RmethDsc<TO,TA>::RmethDsc(TO* pobj, pmeth_t pmeth)
  : fpObj(pobj),
    fpMeth(pmeth)  
{}

//------------------------------------------+-----------------------------------
/*!
  \brief Copy constructor.
*/

template <class TO, class TA>
inline RmethDsc<TO,TA>::RmethDsc(const RmethDsc& rhs)
  : fpObj(rhs.fpObj),
    fpMeth(rhs.fpMeth)  
{}

//------------------------------------------+-----------------------------------
/*!
  \brief Destructor.
*/

template <class TO, class TA>
inline RmethDsc<TO,TA>::~RmethDsc()
{}

//------------------------------------------+-----------------------------------
/*!
  \brief FIXME_text
*/

template <class TO, class TA>
inline int RmethDsc<TO,TA>::operator()(TA& alist)
{
  return (fpObj->*fpMeth)(alist);
}


} // end namespace Retro
