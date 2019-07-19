// $Id: RosPrintfS.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2000-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-18  1089   1.1.1  use c++ style casts
// 2018-12-17  1088   1.1    add bool specialization (use c++11 std::boolalpha)
// 2011-02-25   364   1.0.1  allow NULL ptr for const char*, output <NULL>
// 2011-01-30   357   1.0    Adopted from CTBprintfS
// 2000-10-29     -   -      Last change on CTBprintfS
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RosPrintfS .
*/

#include <iomanip>

#include "RiosState.hpp"
#include "RosPrintfS.hpp"

using namespace std;

/*!
  \class RosPrintfS
  \brief Print object for scalar values . **
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
/*!
  \brief Constructor.

  \param value  value to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

template <class T>
RosPrintfS<T>::RosPrintfS(T value, const char* form, int width, int prec)
  : RosPrintfBase(form, width, prec),
    fValue(value)
{}

//------------------------------------------+-----------------------------------
template <class T>
void RosPrintfS<T>::ToStream(std::ostream& os) const
{
  RiosState iostate(os, fForm, fPrec);
  os << setw(fWidth) << fValue;
}

//------------------------------------------+-----------------------------------
template <>
void RosPrintfS<bool>::ToStream(std::ostream& os) const
{
  RiosState  iostate(os, fForm, fPrec);
  os << std::boolalpha << fValue;
}

//------------------------------------------+-----------------------------------
template <>
void RosPrintfS<char>::ToStream(std::ostream& os) const
{
  RiosState  iostate(os, fForm, fPrec);
  char	     ctype = iostate.Ctype();
  
  os.width(fWidth);
  if (ctype == 0 || ctype == 'c') {
    os << fValue;
  } else {
    os << int(fValue);
  }
}

//------------------------------------------+-----------------------------------
template <>
void RosPrintfS<int>::ToStream(std::ostream& os) const
{
  RiosState  iostate(os, fForm, fPrec);
  char	     ctype = iostate.Ctype();
  
  os.width(fWidth);
  if (ctype == 'c') {
    os << char(fValue);
  } else {
    os << fValue;
  }
}

//------------------------------------------+-----------------------------------
template <>
void RosPrintfS<const char *>::ToStream(std::ostream& os) const
{
  RiosState  iostate(os, fForm, fPrec);
  char	     ctype = iostate.Ctype();
  
  os.width(fWidth);
  if (ctype == 'p') {
    os << reinterpret_cast<const void*>(fValue);
  } else {
    os << (fValue?fValue:"<NULL>");
  }
}

//------------------------------------------+-----------------------------------
template <>
void RosPrintfS<const void *>::ToStream(std::ostream& os) const
{
  RiosState  iostate(os, fForm, fPrec);
  char	     ctype = iostate.Ctype();
  
  os.width(fWidth);
  if (ctype == 0 || ctype == 'p') {
    os << fValue;
  } else {
    os << reinterpret_cast<unsigned long>(fValue);
  }
}

//!! Note:
//!!  1.  This specialization is printing signed and unsigned char types and
//!!	  implements the `c' conversion format,

// finally do an explicit instantiation of the required RosPrintfS

template class RosPrintfS<bool>;
template class RosPrintfS<char>;
template class RosPrintfS<int>;
template class RosPrintfS<unsigned int>;
template class RosPrintfS<long>;
template class RosPrintfS<unsigned long>;
template class RosPrintfS<double>;

template class RosPrintfS<const char *>;
template class RosPrintfS<const void *>;

} // end namespace Retro
