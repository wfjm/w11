// $Id: RlogMsg.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-02-22   490   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of RlogMsg.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlogMsg::SetTag(char tag)
{
  fTag = tag;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlogMsg::SetString(const std::string& str)
{
  fStream.str(str);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline char RlogMsg::Tag() const
{
  return fTag;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline std::string RlogMsg::String() const
{
  return fStream.str();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline std::ostream& RlogMsg::operator()()
{
  return fStream;
}

//------------------------------------------+-----------------------------------
/*! 
  \relates RlogMsg
  \brief FIXME_docs
*/

template <class T>
inline std::ostream& operator<<(RlogMsg& lmsg, const T& val)
{
  lmsg() << val;
  return lmsg();
}

} // end namespace Retro
