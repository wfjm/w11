// $Id: RosPrintfBase.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2006-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-02-25   364   1.1    Support << also to string
// 2011-01-30   357   1.0    Adopted from CTBprintfBase
// 2006-04-16     -   -      Last change on CTBprintfBase
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of RosPrintfBase class .
*/

#ifndef included_Retro_RosPrintfBase
#define included_Retro_RosPrintfBase 1

#include <ostream>
#include <string>

namespace Retro {

  class RosPrintfBase {
    public:
                    RosPrintfBase(const char* form, int width, int prec);
      virtual      ~RosPrintfBase();

      virtual void  ToStream(std::ostream& os) const = 0;

    protected:
      const char*   fForm;		    //!< format string
      int	    fWidth;		    //!< field width
      int	    fPrec;                  //!< field precision
  };

  std::ostream& operator<<(std::ostream& os, const RosPrintfBase& obj);
  std::string&  operator<<(std::string& os,  const RosPrintfBase& obj);

} // end namespace Retro

#include "RosPrintfBase.ipp"

#endif
