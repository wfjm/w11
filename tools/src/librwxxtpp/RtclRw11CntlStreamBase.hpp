// $Id: RtclRw11CntlStreamBase.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-16   878   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11CntlStreamBase.
*/

#ifndef included_Retro_RtclRw11CntlStreamBase
#define included_Retro_RtclRw11CntlStreamBase 1

#include "RtclRw11CntlBase.hpp"

namespace Retro {

  template <class TC>
  class RtclRw11CntlStreamBase : public RtclRw11CntlBase<TC> {
    public:
      explicit      RtclRw11CntlStreamBase(const std::string& type,
                                         const std::string& cclass);
                   ~RtclRw11CntlStreamBase();

    protected:
      virtual int   M_default(RtclArgs& args);
  };
  
} // end namespace Retro

// implementation is all inline
#include "RtclRw11CntlStreamBase.ipp"

#endif
