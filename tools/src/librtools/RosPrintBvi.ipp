// $Id: RosPrintBvi.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-03-05   366   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of RosPrintBvi.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
/*! 
  \relates RosPrintBvi
  \brief ostream insertion operator.
*/

inline std::ostream& operator<<(std::ostream& os, const RosPrintBvi& obj)
{
  obj.Print(os);
  return os;
}

//------------------------------------------+-----------------------------------
/*! 
  \relates RosPrintBvi
  \brief string insertion operator.
*/

inline std::string& operator<<(std::string& os, const RosPrintBvi& obj)
{
  obj.Print(os);
  return os;
}


} // end namespace Retro
