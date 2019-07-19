// $Id: RiosState.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2006-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-01-30   357   1.0    Adopted from CTBioState
// 2006-04-16     -   -      Last change on CTBioState
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RiosState.
*/

#ifndef included_Retro_RiosState
#define included_Retro_RiosState 1

#include <ios>

namespace Retro {

  class RiosState {
    public:
                    RiosState(std::ios& stream);
                    RiosState(std::ios& stream, const char* form, int prec=-1);
                   ~RiosState();

      void          SetFormat(const char* form, int prec=-1);
      char          Ctype();

    protected:
      std::ios&	    fStream;
      std::ios_base::fmtflags  fOldFlags;
      int	    fOldPrecision;
      char	    fOldFill;
      char	    fCtype;

    // RiosState can't be default constructed, copied or assigned
    private:
                    RiosState();
                    RiosState(const RiosState& rhs);
      RiosState&    operator=(const RiosState& rhs);

  };
  
} // end namespace Retro

#include "RiosState.ipp"

#endif
