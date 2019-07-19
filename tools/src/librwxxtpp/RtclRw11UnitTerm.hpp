// $Id: RtclRw11UnitTerm.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-08   870   1.1    use Rw11UnitTerm& ObjUV(); inherit from RtclRw11Unit
// 2013-04-26   511   1.0.1  add M_type
// 2013-03-03   494   1.0    Initial version
// 2013-03-01   493   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RtclRw11UnitTerm.
*/

#ifndef included_Retro_RtclRw11UnitTerm
#define included_Retro_RtclRw11UnitTerm 1

#include "librw11/Rw11UnitTerm.hpp"

#include "RtclRw11Unit.hpp"

namespace Retro {

  class RtclRw11UnitTerm : public RtclRw11Unit {
    public:
                    RtclRw11UnitTerm(const std::string& type);
                   ~RtclRw11UnitTerm();

      virtual Rw11UnitTerm&  ObjUV() = 0;
    
    protected:
      int           M_type(RtclArgs& args);
      void          SetupGetSet();

  };
  
} // end namespace Retro

//#include "RtclRw11UnitTerm.ipp"

#endif
