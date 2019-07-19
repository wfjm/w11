// $Id: RtclRw11UnitBase.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-07  1078   1.3    use std::shared_ptr instead of boost
// 2017-04-08   870   1.2    add TUV,TB; add TUV* ObjUV(); inherit from TB
// 2017-04-02   863   1.1    add AttachDone()
// 2013-03-06   495   1.0    Initial version
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11UnitBase.
*/

#ifndef included_Retro_RtclRw11UnitBase
#define included_Retro_RtclRw11UnitBase 1

#include <memory>

#include "RtclRw11Unit.hpp"

namespace Retro {

  template <class TU, class TUV, class TB>
  class RtclRw11UnitBase : public TB {
    public:
                    RtclRw11UnitBase(const std::string& type, 
                                     const std::shared_ptr<TU>& spunit);
                   ~RtclRw11UnitBase();

      virtual TU&   Obj();
      virtual TUV&  ObjUV();
      virtual Rw11Cpu&   Cpu() const;
      const std::shared_ptr<TU>&  ObjSPtr();

    protected:
      virtual void  AttachDone();
      int           M_stats(RtclArgs& args);

    protected:
      std::shared_ptr<TU>  fspObj;         //!< sptr to managed object
  };
  
} // end namespace Retro

// implementation is all inline
#include "RtclRw11UnitBase.ipp"

#endif
