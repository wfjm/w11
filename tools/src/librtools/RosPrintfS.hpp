// $Id: RosPrintfS.hpp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2000-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-01-30   357   1.0    Adopted from CTBprintfS
// 2000-10-29     -   -      Last change on CTBprintfS
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Declaration of class RosPrintfS .
*/

#ifndef included_Retro_RosPrintfS
#define included_Retro_RosPrintfS 1

#include "RosPrintfBase.hpp"

namespace Retro {

  template <class T>
  class RosPrintfS : public RosPrintfBase {
    public:
		    RosPrintfS(T value, const char* form, int width, int prec);

      virtual void  ToStream(std::ostream& os) const;

    protected:
      T             fValue;		    //!< value to be printed
  };

  template <>
  void RosPrintfS<char>::ToStream(std::ostream& os) const;
  template <>
  void RosPrintfS<int>::ToStream(std::ostream& os) const;
  template <>
  void RosPrintfS<const char*>::ToStream(std::ostream& os) const;  
  template <>
  void RosPrintfS<const void*>::ToStream(std::ostream& os) const;  

} // end namespace Retro

#endif
