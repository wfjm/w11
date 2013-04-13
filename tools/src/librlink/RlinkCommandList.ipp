// $Id: RlinkCommandList.ipp 495 2013-03-06 17:13:48Z mueller $
//
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-05-06   495   1.0.1  add RlinkContext to Print() args; drop oper<<()
// 2011-03-05   366   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkCommandList.ipp 495 2013-03-06 17:13:48Z mueller $
  \brief   Implemenation (inline) of class RlinkCommandList.
*/


// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkCommandList::Size() const
{
  return fList.size();
}

} // end namespace Retro
