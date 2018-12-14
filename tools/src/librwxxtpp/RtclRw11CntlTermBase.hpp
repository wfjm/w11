// $Id: RtclRw11CntlTermBase.hpp 1078 2018-12-08 14:19:03Z mueller $
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
  \brief   Declaration of class RtclRw11CntlTermBase.
*/

#ifndef included_Retro_RtclRw11CntlTermBase
#define included_Retro_RtclRw11CntlTermBase 1

#include "RtclRw11CntlBase.hpp"

namespace Retro {

  template <class TC>
  class RtclRw11CntlTermBase : public RtclRw11CntlBase<TC> {
    public:
      explicit      RtclRw11CntlTermBase(const std::string& type,
                                         const std::string& cclass);
                   ~RtclRw11CntlTermBase();

    protected:
      virtual int   M_default(RtclArgs& args);
  };
  
} // end namespace Retro

// implementation is all inline
#include "RtclRw11CntlTermBase.ipp"

#endif
