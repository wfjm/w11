// $Id: RtclNameSet.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-05-19   521   1.1    add CheckMatch()
// 2011-02-20   363   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclNameSet.
*/

#ifndef included_Retro_RtclNameSet
#define included_Retro_RtclNameSet 1

#include "tcl.h"

#include <string>
#include <set>

#include "RtclNameSet.hpp"

namespace Retro {

  class RtclNameSet {
    public:
      typedef std::set<std::string>   nset_t;
      typedef nset_t::iterator        nset_it_t;
      typedef nset_t::const_iterator  nset_cit_t;

                        RtclNameSet();
                        RtclNameSet(const std::string& nset);
                       ~RtclNameSet();

    bool                Check(Tcl_Interp* interp, std::string& rval, 
                              const std::string& tval) const;
    int                 CheckMatch(Tcl_Interp* interp, std::string& rval, 
                                   const std::string& tval, bool misserr) const;

    protected:  
      nset_t            fSet;
  };

} // end namespace Retro

//#include "RtclNameSet.ipp"

#endif
