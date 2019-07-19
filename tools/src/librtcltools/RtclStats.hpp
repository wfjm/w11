// $Id: RtclStats.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.1    Rename Collect->Exec, not longer const
// 2013-03-06   495   1.0.1  Rename Exec->Collect
// 2011-02-26   364   1.0    Initial version
// 2011-02-20   363   0.1    fFirst draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclStats.
*/

#ifndef included_Retro_RtclStats
#define included_Retro_RtclStats 1

#include <string>

#include "RtclArgs.hpp"
#include "librtools/Rstats.hpp"

namespace Retro {

  class RtclStats {
    public:
      struct Context {
        std::string   opt;
        std::string   varname;
        std::string   format;
        int           width;
        int           prec;

                      Context()
                        : opt(), varname(), format(), width(0), prec(0)
                      {}
      };
    
      static bool     GetArgs(RtclArgs& args, Context& cntx);
      static bool     Exec(RtclArgs& args, const Context& cntx, Rstats& stats);
  };

} // end namespace Retro

//#include "RtclStats.ipp"

#endif
