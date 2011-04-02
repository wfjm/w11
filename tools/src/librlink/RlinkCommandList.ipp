// $Id: RlinkCommandList.ipp 375 2011-04-02 07:56:47Z mueller $
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
// 2011-03-05   366   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkCommandList.ipp 375 2011-04-02 07:56:47Z mueller $
  \brief   Implemenation (inline) of class RlinkCommandList.
*/


// all method definitions in namespace Retro (avoid using in includes...)
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_text

inline size_t RlinkCommandList::Size() const
{
  return fList.size();
}

//------------------------------------------+-----------------------------------
/*! 
  \relates RlinkCommandList
  \brief ostream insertion operator.
*/

inline std::ostream& operator<<(std::ostream& os, const RlinkCommandList& obj)
{
  obj.Print(os);
  return os;
}

} // end namespace Retro
