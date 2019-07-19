// $Id: RtclProxyOwned.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.1.1  use std::shared_ptr instead of boost
// 2013-02-05   482   1.1    use shared_ptr to TO*; add ObjPtr();
// 2011-02-13   361   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of class RtclProxyOwned.
*/

#ifndef included_Retro_RtclProxyOwned 
#define included_Retro_RtclProxyOwned 1

#include <memory>

#include "RtclProxyBase.hpp"

namespace Retro {

  template <class TO>
  class RtclProxyOwned : public RtclProxyBase {
    public:
                    RtclProxyOwned();
                    RtclProxyOwned(const std::string& type);
                    RtclProxyOwned(const std::string& type, Tcl_Interp* interp,
                                   const char* name, TO* pobj=nullptr);
                   ~RtclProxyOwned();

      TO&           Obj();
      const std::shared_ptr<TO>& ObjSPtr();

    protected:
      std::shared_ptr<TO>  fspObj;         //!< sptr to managed object

  };
  
} // end namespace Retro

// implementation is all inline
#include "RtclProxyOwned.ipp"

#endif
