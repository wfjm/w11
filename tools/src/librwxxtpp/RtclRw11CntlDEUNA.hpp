// $Id: RtclRw11CntlDEUNA.hpp 878 2017-04-16 12:28:15Z mueller $
//
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-16   878   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11CntlDEUNA.hpp 878 2017-04-16 12:28:15Z mueller $
  \brief   Declaration of class RtclRw11CntlDEUNA.
*/

#ifndef included_Retro_RtclRw11CntlDEUNA
#define included_Retro_RtclRw11CntlDEUNA 1

#include "RtclRw11CntlBase.hpp"
#include "librw11/Rw11CntlDEUNA.hpp"

namespace Retro {

  class RtclRw11CntlDEUNA : public RtclRw11CntlBase<Rw11CntlDEUNA> {
    public:
                    RtclRw11CntlDEUNA();
                   ~RtclRw11CntlDEUNA();

      virtual int   FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu);

    protected:
      virtual int   M_default(RtclArgs& args);
  };
  
} // end namespace Retro

//#include "RtclRw11CntlDEUNA.ipp"

#endif
