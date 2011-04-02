// $Id: RtclStats.hpp 365 2011-02-28 07:28:26Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-02-26   364   1.0    Initial version
// 2011-02-20   363   0.1    fFirst draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclStats.hpp 365 2011-02-28 07:28:26Z mueller $
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
      static bool     Exec(RtclArgs& args, Context& cntx, const Rstats& stats);
  };

} // end namespace Retro

#if !(defined(Retro_NoInline) || defined(Retro_RtclStats_NoInline))
//#include "RtclStats.ipp"
#endif

#endif
