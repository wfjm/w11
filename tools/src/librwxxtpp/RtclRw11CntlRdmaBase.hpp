// $Id: RtclRw11CntlRdmaBase.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-16   878   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11CntlRdmaBase.
*/

#ifndef included_Retro_RtclRw11CntlRdmaBase
#define included_Retro_RtclRw11CntlRdmaBase 1

#include "RtclRw11CntlBase.hpp"

namespace Retro {

  template <class TC>
  class RtclRw11CntlRdmaBase : public RtclRw11CntlBase<TC> {
    public:
      explicit      RtclRw11CntlRdmaBase(const std::string& type,
                                         const std::string& cclass);
                   ~RtclRw11CntlRdmaBase();

    protected:
  };
  
} // end namespace Retro

// implementation is all inline
#include "RtclRw11CntlRdmaBase.ipp"

#endif
