// $Id: RtclSet.hpp 1186 2019-07-12 17:49:59Z mueller $
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
  \brief   Declaration of class \c RtclSet.
*/

#ifndef included_Retro_RtclSet
#define included_Retro_RtclSet 1

#include "tcl.h"

#include <cstdint>
#include <string>
#include <functional>

#include "librtools/Rexception.hpp"
#include "RtclSetBase.hpp"

namespace Retro {

  template <class TP>
  class RtclSet : public RtclSetBase {
    public:
      explicit      RtclSet(std::function<void(TP)>&& set);
                   ~RtclSet();

      virtual void  operator()(RtclArgs& args) const;

    protected: 
      std::function<void(TP)> fSet;
  };
  
  
} // end namespace Retro

#include "RtclSet.ipp"

#endif
