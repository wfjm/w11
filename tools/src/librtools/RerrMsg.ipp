// $Id: RerrMsg.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-02-06   359   1.1    use references in interface
// 2011-01-15   356   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of RerrMsg.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RerrMsg::SetMeth(const std::string& meth)
{
  fMeth = meth;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RerrMsg::SetText(const std::string& text)
{
  fText = text;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& RerrMsg::Meth() const
{
  return fMeth;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& RerrMsg::Text() const
{
  return fText;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RerrMsg::operator std::string() const
{
  return Message();
}

//------------------------------------------+-----------------------------------
/*! 
  \relates RerrMsg
  \brief ostream insertion operator.
*/

inline std::ostream& operator<<(std::ostream& os, const RerrMsg& obj)
{
  os << obj.Message();
  return os;
}

} // end namespace Retro
