// $Id: RtclGet.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-15  1083   1.0.2  ctor: use rval ref and move semantics
// 2018-12-14  1081   1.0.1  use std::function instead of boost
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of class \c RtclGet.
*/

#ifndef included_Retro_RtclGet
#define included_Retro_RtclGet 1

#include "tcl.h"

#include <cstdint>
#include <string>
#include <functional>

#include "RtclGetBase.hpp"

namespace Retro {

  template <class TP>
  class RtclGet : public RtclGetBase {
    public:
      explicit      RtclGet(std::function<TP()>&& get);
                   ~RtclGet();

      virtual Tcl_Obj*  operator()() const;

    protected: 
      std::function<TP()> fGet;
  };
  
  
} // end namespace Retro

#include "RtclGet.ipp"

#endif
