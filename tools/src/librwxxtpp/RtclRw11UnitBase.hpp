// $Id: RtclRw11UnitBase.hpp 863 2017-04-02 11:43:15Z mueller $
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
// 2017-04-02   863   1.1    add AttachDone()
// 2013-03-06   495   1.0    Initial version
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11UnitBase.hpp 863 2017-04-02 11:43:15Z mueller $
  \brief   Declaration of class RtclRw11UnitBase.
*/

#ifndef included_Retro_RtclRw11UnitBase
#define included_Retro_RtclRw11UnitBase 1

#include "boost/shared_ptr.hpp"

#include "RtclRw11Unit.hpp"

namespace Retro {

  template <class TO>
  class RtclRw11UnitBase : public RtclRw11Unit {
    public:
                    RtclRw11UnitBase(const std::string& type, 
                                     const boost::shared_ptr<TO>& spunit);
                   ~RtclRw11UnitBase();

      TO&           Obj();
      const boost::shared_ptr<TO>&  ObjSPtr();

    protected:
      virtual void  AttachDone();
      int           M_stats(RtclArgs& args);

    protected:
      boost::shared_ptr<TO>  fspObj; //!< sptr to managed object
  };
  
} // end namespace Retro

// implementation is all inline
#include "RtclRw11UnitBase.ipp"

#endif
