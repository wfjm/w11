// $Id: Rstats.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-02-06   359   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rstats.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rstats::Set(size_t ind, double val)
{
  fValue.at(ind) = val;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rstats::Inc(size_t ind, double val)
{
  fValue.at(ind) += val;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rstats::Size() const
{
  return fValue.size();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline double Rstats::Value(size_t ind) const
{
  return fValue.at(ind);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rstats::Name(size_t ind) const
{
  return fName.at(ind);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rstats::Text(size_t ind) const
{
  return fText.at(ind);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline double Rstats::operator[](size_t ind) const
{
  return fValue.at(ind);
}

//------------------------------------------+-----------------------------------
/*! 
  \relates Rstats
  \brief ostream insertion operator.
*/

inline std::ostream& operator<<(std::ostream& os, const Rstats& obj)
{
  obj.Print(os);
  return os;
}

} // end namespace Retro
