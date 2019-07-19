// $Id: RtclRw11CntlTermBase.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-16   878   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (all inline) of RtclRw11CntlTermBase.
*/

/*!
  \class Retro::RtclRw11CntlTermBase
  \brief FIXME_docs
*/

#include <sstream>

#include "librtools/RosPrintf.hpp"

#include "librw11/Rw11UnitTerm.hpp"

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

template <class TC>
inline RtclRw11CntlTermBase<TC>::RtclRw11CntlTermBase(const std::string& type,
                                                      const std::string& cclass)
  : RtclRw11CntlBase<TC>(type,cclass)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline RtclRw11CntlTermBase<TC>::~RtclRw11CntlTermBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline int RtclRw11CntlTermBase<TC>::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return RtclRw11Cntl::kERR;
  std::ostringstream sos;
  TC& cntl = this->Obj();
  sos << "unit i7 o7 oe at attachurl\n";
  for (size_t i=0; i<cntl.NUnit(); i++) {
    Rw11UnitTerm& unit = cntl.Unit(i);
    sos << RosPrintf(unit.Name().c_str(),"-s",4)
        << " " << (unit.Ti7bit() ?   " y" : " n")
        << " " << (unit.To7bit() ?   " y" : " n")
        << " " << (unit.ToEnpc() ?   " y" : " n")
        << " " << (unit.IsAttached() ?   " y" : " n")
        << " " << unit.AttachUrl()
        << "\n";
  }
  args.AppendResultLines(sos);
  return RtclRw11Cntl::kOK;
}


} // end namespace Retro
