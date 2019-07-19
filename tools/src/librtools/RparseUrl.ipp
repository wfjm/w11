// $Id: RparseUrl.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-02-03   481   1.0    Initial version, extracted from RlinkPort
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of RparseUrl.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RparseUrl::SetPath(const std::string& path)
{
  fPath = path;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& RparseUrl::Url() const
{
  return fUrl;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& RparseUrl::Scheme() const
{
  return fScheme;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& RparseUrl::Path() const
{
  return fPath;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const RparseUrl::omap_t& RparseUrl::Opts() const
{
  return fOptMap;
}


} // end namespace Retro
