// $Id: RosPrintfBase.ipp 1091 2018-12-23 12:38:29Z mueller $
//
// Copyright 2006-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-22  1091   1.0.1  virtual dtor now outlined to streamline vtable
// 2011-01-30   357   1.0    Adopted from RosPrintfBase
// 2006-04-16     -   -      Last change on RosPrintfBase
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (inline) of RosPrintfBase
*/

// all method definitions in namespace Retro
namespace Retro {

/*!
  \class RosPrintfBase 
  \brief Base class for print objects. **
*/
//------------------------------------------+-----------------------------------
/*!
  \fn Retro::RosPrintfBase::ToStream(ostream& os) const
  \brief Concrete implementation of the ostream insertion.
*/

//------------------------------------------+-----------------------------------
/*!
  \brief Constructor.

  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline RosPrintfBase::RosPrintfBase(const char* form, int width, int prec)
  : fForm(form),
    fWidth(width),
    fPrec(prec)
{}

//------------------------------------------+-----------------------------------
/*!
  \relates RosPrintfBase
  \brief ostream insertion
*/

inline std::ostream& operator<<(std::ostream& os, const RosPrintfBase& obj)
{
  obj.ToStream(os);
  return os;
}

} // end namespace Retro
