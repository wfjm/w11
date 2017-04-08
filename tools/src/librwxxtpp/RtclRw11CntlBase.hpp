// $Id: RtclRw11CntlBase.hpp 870 2017-04-08 18:24:34Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-03-06   495   1.0    Initial version
// 2013-02-08   484   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11CntlBase.hpp 870 2017-04-08 18:24:34Z mueller $
  \brief   Declaration of class RtclRw11CntlBase.
*/

#ifndef included_Retro_RtclRw11CntlBase
#define included_Retro_RtclRw11CntlBase 1

#include "boost/shared_ptr.hpp"

#include "RtclRw11Cntl.hpp"

namespace Retro {

  template <class TC>
  class RtclRw11CntlBase : public RtclRw11Cntl {
    public:
      explicit      RtclRw11CntlBase(const std::string& type);
                   ~RtclRw11CntlBase();

      virtual TC&   Obj();
      const boost::shared_ptr<TC>&  ObjSPtr();

    protected:
      int           M_bootcode(RtclArgs& args);

    protected:
      boost::shared_ptr<TC>  fspObj; //!< sptr to managed object
  };
  
} // end namespace Retro

// implementation is all inline
#include "RtclRw11CntlBase.ipp"

#endif
