// $Id: RtclRw11CntlStreamBase.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-16   878   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (all inline) of RtclRw11CntlStreamBase.
*/

/*!
  \class Retro::RtclRw11CntlStreamBase
  \brief FIXME_docs
*/

#include <sstream>

#include "librtools/RosPrintf.hpp"

#include "librw11/Rw11UnitStream.hpp"

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

template <class TC>
inline RtclRw11CntlStreamBase<TC>::RtclRw11CntlStreamBase(const std::string& type,
                                                      const std::string& cclass)
  : RtclRw11CntlBase<TC>(type,cclass)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline RtclRw11CntlStreamBase<TC>::~RtclRw11CntlStreamBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline int RtclRw11CntlStreamBase<TC>::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return RtclRw11Cntl::kERR;
  std::ostringstream sos;
  TC& cntl = this->Obj();
  sos << "unit       pos at attachurl\n";
  for (size_t i=0; i<cntl.NUnit(); i++) {
    Rw11UnitStream& unit = cntl.Unit(i);
    sos << RosPrintf(unit.Name().c_str(),"-s",4)
        << " " << RosPrintf(unit.Pos(),"d",9)
        << " " << (unit.IsAttached() ?   " y" : " n")
        << " " << unit.AttachUrl()
        << "\n";
  }
  args.AppendResultLines(sos);
  return RtclRw11Cntl::kOK;
}


} // end namespace Retro
