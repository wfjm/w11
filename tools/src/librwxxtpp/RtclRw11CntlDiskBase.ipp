// $Id: RtclRw11CntlDiskBase.ipp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-16   878   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (all inline) of RtclRw11CntlDiskBase.
*/

/*!
  \class Retro::RtclRw11CntlDiskBase
  \brief FIXME_docs
*/

#include <sstream>

#include "librtools/RosPrintf.hpp"

#include "librw11/Rw11UnitDisk.hpp"

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

template <class TC>
inline RtclRw11CntlDiskBase<TC>::RtclRw11CntlDiskBase(const std::string& type,
                                                      const std::string& cclass)
  : RtclRw11CntlRdmaBase<TC>(type,cclass)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline RtclRw11CntlDiskBase<TC>::~RtclRw11CntlDiskBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline int RtclRw11CntlDiskBase<TC>::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return RtclRw11Cntl::kERR;
  std::ostringstream sos;
  TC& cntl = this->Obj();
  sos << "unit type en wp  cyl hd sec  blocks bsz at attachurl\n";
  for (size_t i=0; i<cntl.NUnit(); i++) {
    Rw11UnitDisk& unit = cntl.Unit(i);
    sos << RosPrintf(unit.Name().c_str(),"-s",4)
        << " " << RosPrintf(unit.Type().c_str(),"-s",4)
        << " " << (unit.Enabled() ? " y" : " n")
        << " " << (unit.WProt() ?   " y" : " n")
        << " " << RosPrintf(unit.NCylinder(),"d",4)
        << " " << RosPrintf(unit.NHead(),"d",2)
        << " " << RosPrintf(unit.NSector(),"d",3)
        << " " << RosPrintf(unit.NBlock(),"d",7)
        << " " << RosPrintf(unit.BlockSize(),"d",3)
        << " " << (unit.IsAttached() ?   " y" : " n")
        << " " << unit.AttachUrl()
        << "\n";
  }
  args.AppendResultLines(sos);
  return RtclRw11Cntl::kOK;
}


} // end namespace Retro
