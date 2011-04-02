// $Id: RtclNameSet.hpp 365 2011-02-28 07:28:26Z mueller $
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
// 2011-02-20   363   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclNameSet.hpp 365 2011-02-28 07:28:26Z mueller $
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

    protected:  
      nset_t            fSet;
  };

} // end namespace Retro

#if !(defined(Retro_NoInline) || defined(Retro_RtclNameSet_NoInline))
#include "RtclNameSet.ipp"
#endif

#endif
