// $Id: RtclRw11CntlTapeBase.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-16   878   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (all inline) of RtclRw11CntlTapeBase.
*/

/*!
  \class Retro::RtclRw11CntlTapeBase
  \brief FIXME_docs
*/

#include <sstream>

#include "librtools/RosPrintf.hpp"

#include "librw11/Rw11UnitTape.hpp"

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

template <class TC>
inline RtclRw11CntlTapeBase<TC>::RtclRw11CntlTapeBase(const std::string& type,
                                                      const std::string& cclass)
  : RtclRw11CntlRdmaBase<TC>(type,cclass)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline RtclRw11CntlTapeBase<TC>::~RtclRw11CntlTapeBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline int RtclRw11CntlTapeBase<TC>::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return RtclRw11Cntl::kERR;
  std::ostringstream sos;
  TC& cntl = this->Obj();
  sos << "unit type en wp  capacity bot eot eom pfi  prec at attachurl\n";
  for (size_t i=0; i<cntl.NUnit(); i++) {
    Rw11UnitTape& unit = cntl.Unit(i);
    sos << RosPrintf(unit.Name().c_str(),"-s",4)
        << " " << RosPrintf(unit.Type().c_str(),"-s",4)
        << " " << (unit.Enabled() ? " y" : " n")
        << " " << (unit.WProt() ?   " y" : " n")
        << " " << RosPrintf(unit.Capacity(),"d",9)
        << " " << (unit.Bot() ? "  y" : "  n")
        << " " << (unit.Eot() ? "  y" : "  n")
        << " " << (unit.Eom() ? "  y" : "  n")
        << " " << RosPrintf(unit.PosFile(),"d",3)
        << " " << RosPrintf(unit.PosRecord(),"d",5)
        << " " << (unit.IsAttached() ?   " y" : " n")
        << " " << unit.AttachUrl()
        << "\n";
  }
  args.AppendResultLines(sos);
  return RtclRw11Cntl::kOK;
}

} // end namespace Retro
