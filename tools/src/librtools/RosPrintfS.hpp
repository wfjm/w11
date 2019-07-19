// $Id: RosPrintfS.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2000-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-17  1088   1.1    add bool specialization (use c++11 std::boolalpha)
// 2011-01-30   357   1.0    Adopted from CTBprintfS
// 2000-10-29     -   -      Last change on CTBprintfS
// ---------------------------------------------------------------------------

/*!
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
  void RosPrintfS<bool>::ToStream(std::ostream& os) const;
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
