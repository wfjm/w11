// $Id: RtclRw11UnitBase.hpp 887 2017-04-28 19:32:52Z mueller $
//
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-08   870   1.2    add TUV,TB; add TUV* ObjUV(); inherit from TB
// 2017-04-02   863   1.1    add AttachDone()
// 2013-03-06   495   1.0    Initial version
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class RtclRw11UnitBase.
*/

#ifndef included_Retro_RtclRw11UnitBase
#define included_Retro_RtclRw11UnitBase 1

#include "boost/shared_ptr.hpp"

#include "RtclRw11Unit.hpp"

namespace Retro {

  template <class TU, class TUV, class TB>
  class RtclRw11UnitBase : public TB {
    public:
                    RtclRw11UnitBase(const std::string& type, 
                                     const boost::shared_ptr<TU>& spunit);
                   ~RtclRw11UnitBase();

      virtual TU&   Obj();
      virtual TUV&  ObjUV();
      virtual Rw11Cpu&   Cpu() const;
      const boost::shared_ptr<TU>&  ObjSPtr();

    protected:
      virtual void  AttachDone();
      int           M_stats(RtclArgs& args);

    protected:
      boost::shared_ptr<TU>  fspObj; //!< sptr to managed object
  };
  
} // end namespace Retro

// implementation is all inline
#include "RtclRw11UnitBase.ipp"

#endif
