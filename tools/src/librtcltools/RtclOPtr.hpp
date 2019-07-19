// $Id: RtclOPtr.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-05-20   521   1.0.1  declare ctor(Tcl_Obj*) as explicit
// 2011-02-20   363   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclOPtr.
*/

#ifndef included_Retro_RtclOPtr
#define included_Retro_RtclOPtr 1

#include "tcl.h"

namespace Retro {

  class RtclOPtr {
    public:
                        RtclOPtr();
      explicit          RtclOPtr(Tcl_Obj* pobj);
                        RtclOPtr(const RtclOPtr& rhs);
                       ~RtclOPtr();

                        operator Tcl_Obj*() const;
      bool              operator !() const;
      RtclOPtr&         operator=(const RtclOPtr& rhs);
      RtclOPtr&         operator=(Tcl_Obj* pobj);

    protected:
      Tcl_Obj*          fpObj;              //!< pointer to tcl object
  };

} // end namespace Retro

// implementation all inline
#include "RtclOPtr.ipp"

#endif
