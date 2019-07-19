// $Id: RlogFile.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-02-23   492   2.1    add Name(), keep log file name
// 2013-02-22   491   2.0    add Write(),IsNew(), RlogMsg iface; use lockable
// 2011-01-30   357   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of RlogFile.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlogFile::IsNew() const
{
  return fNew;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& RlogFile::Name() const
{
  return fName;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline std::ostream& RlogFile::Stream()
{
  return fpExtStream ? *fpExtStream : fIntStream;
}

} // end namespace Retro
