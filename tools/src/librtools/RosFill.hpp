// $Id: RosFill.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2000-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-02-25   364   1.1    Support << also to string
// 2011-01-30   359   1.0    Adopted from CTBosFill
// 2000-02-06     -   -      Last change on CTBosFill
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of class RosFill .
*/

#ifndef included_Retro_RosFill
#define included_Retro_RosFill 1

#include <ostream>
#include <string>

namespace Retro {
  
  class RosFill {
    public: 
		    RosFill(int count=0, char fill=' ');

      int           Count() const;
      char          Fill() const;

  private:
      int           fCount;		    //!< blank count
      char	    fFill;		    //!< fill character

  };

  std::ostream&	    operator<<(std::ostream& os, const RosFill& obj);
  std::string& 	    operator<<(std::string&  os, const RosFill& obj);

} // end namespace Retro

#include "RosFill.ipp"

#endif
