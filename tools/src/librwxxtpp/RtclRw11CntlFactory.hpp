// $Id: RtclRw11CntlFactory.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-03-06   495   1.0    Initial version
// 2013-02-09   485   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of global function RtclRw11CntlFactory.
*/

#ifndef included_Retro_RtclRw11CntlFactory
#define included_Retro_RtclRw11CntlFactory 1

#include "librtcltools/RtclArgs.hpp"
#include "RtclRw11Cpu.hpp"

namespace Retro {

  int RtclRw11CntlFactory(RtclArgs& args, RtclRw11Cpu& cpu);
  
} // end namespace Retro

#endif
