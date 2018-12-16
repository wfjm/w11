// $Id: RtclRw11CntlRdmaBase.ipp 1082 2018-12-15 13:56:20Z mueller $
//
// Copyright 2017-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-15  1082   1.2.1  use lambda instead of bind
// 2017-04-16   877   1.2    add class in ctor
// 2017-02-04   848   1.1    add in fGets: found,pdataint,pdatarem
// 2013-03-06   495   1.0    Initial version
// 2013-02-08   484   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (all inline) of RtclRw11CntlRdmaBase.
*/

/*!
  \class Retro::RtclRw11CntlRdmaBase
  \brief FIXME_docs
*/

#include "librtcltools/Rtcl.hpp"
#include "librtcltools/RtclOPtr.hpp"

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

template <class TC>
inline RtclRw11CntlRdmaBase<TC>::RtclRw11CntlRdmaBase(const std::string& type,
                                                      const std::string& cclass)
  : RtclRw11CntlBase<TC>(type,cclass)
{
  TC* pobj = &this->Obj();
  RtclGetList& gets = this->fGets;
  RtclSetList& sets = this->fSets;
  gets.Add<size_t>  ("chunksize", [pobj](){ return pobj->ChunkSize(); });
  sets.Add<size_t>  ("chunksize", [pobj](size_t v){ pobj->SetChunkSize(v); });
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TC>
inline RtclRw11CntlRdmaBase<TC>::~RtclRw11CntlRdmaBase()
{}


} // end namespace Retro
