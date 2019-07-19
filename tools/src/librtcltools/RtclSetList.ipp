// $Id: RtclSetList.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-15  1083   1.1.2  Add(): use rval ref and move semantics
// 2018-12-14  1081   1.1.1  use std::function instead of boost
// 2018-12-01  1076   1.1    use unique_ptr
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of class RtclSetList.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TP>
inline void RtclSetList::Add(const std::string& name,
                             std::function<void(TP)>&& set)
{
  Add(name, set_uptr_t(new RtclSet<TP>(move(set))));
  return;
}

} // end namespace Retro
