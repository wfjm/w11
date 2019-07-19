// $Id: RtclRw11CntlBase.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.2    use std::shared_ptr instead of boost
// 2017-04-16   877   1.1    add class in ctor
// 2013-03-06   495   1.0    Initial version
// 2013-02-08   484   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11CntlBase.
*/

#ifndef included_Retro_RtclRw11CntlBase
#define included_Retro_RtclRw11CntlBase 1

#include <memory>

#include "RtclRw11Cntl.hpp"

namespace Retro {

  template <class TC>
  class RtclRw11CntlBase : public RtclRw11Cntl {
    public:
      explicit      RtclRw11CntlBase(const std::string& type,
                                     const std::string& cclass);
                   ~RtclRw11CntlBase();

      virtual TC&   Obj();
      const std::shared_ptr<TC>&  ObjSPtr();

    protected:
      int           M_bootcode(RtclArgs& args);

    protected:
      std::shared_ptr<TC>  fspObj;         //!< sptr to managed object
  };
  
} // end namespace Retro

// implementation is all inline
#include "RtclRw11CntlBase.ipp"

#endif
