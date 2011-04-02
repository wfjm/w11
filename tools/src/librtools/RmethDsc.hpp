// $Id: RmethDsc.hpp 360 2011-02-11 20:35:11Z mueller $
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
// 2011-02-11   360   1.1    templetize object type TO and arglist type TA 
// 2011-02-06   359   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RmethDsc.hpp 360 2011-02-11 20:35:11Z mueller $
  \brief   Declaration of class RmethDsc .
*/

#include "RmethDscBase.hpp"

#ifndef included_Retro_RmethDsc
#define included_Retro_RmethDsc 1

namespace Retro {
  
  template <class TO, class TA>
  class RmethDsc : public RmethDscBase<TA> {
    public: 
      typedef int (TO::*pmeth_t) (TA& alist);

                    RmethDsc();
                    RmethDsc(TO* pobj, pmeth_t pmeth);
                    RmethDsc(const RmethDsc& rhs);
      virtual       ~RmethDsc();

      virtual int   operator()(TA& alist);

  private:
    TO*             fpObj;
    pmeth_t         fpMeth;
  };

} // end namespace Retro

// implementation is all inline
#include "RmethDsc.ipp"

#endif
