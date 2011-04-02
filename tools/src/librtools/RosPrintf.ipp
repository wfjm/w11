// $Id: RosPrintf.ipp 358 2011-02-05 09:45:14Z mueller $
//
// Copyright 2000-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-01-30   357   1.0    Adopted from CTBprintf
// 2000-12-18     -   -      Last change on CTBprintf
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RosPrintf.ipp 358 2011-02-05 09:45:14Z mueller $
  \brief   Implemenation (inline) of RosPrintf.
*/

//------------------------------------------+-----------------------------------
/*!
  \defgroup RosPrintf RosPrintf -- print format object creators
*/
//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a \c char value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline Retro::RosPrintfS<char> 
  Retro::RosPrintf(char value, const char* form, int width, int prec)
{
  return Retro::RosPrintfS<char>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a signed char value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline Retro::RosPrintfS<int> 
  Retro::RosPrintf(signed char value, const char* form, int width, int prec)
{
  return Retro::RosPrintfS<int>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a unsigned char value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline Retro::RosPrintfS<unsigned int> 
  Retro::RosPrintf(unsigned char value, const char* form, int width, int prec)
{
  return Retro::RosPrintfS<unsigned int>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a \c short value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline Retro::RosPrintfS<int> 
  Retro::RosPrintf(short value, const char* form, int width, int prec)
{
  return Retro::RosPrintfS<int>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a unsigned short value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline Retro::RosPrintfS<unsigned int> 
  Retro::RosPrintf(unsigned short value, const char* form, int width, int prec)
{
  return Retro::RosPrintfS<unsigned int>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a \c int value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline Retro::RosPrintfS<int> 
  Retro::RosPrintf(int value, const char* form, int width, int prec)
{
  return Retro::RosPrintfS<int>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a unsigned int value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline Retro::RosPrintfS<unsigned int> 
  Retro::RosPrintf(unsigned int value, const char* form, int width, int prec)
{
  return Retro::RosPrintfS<unsigned int>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a \c long value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline Retro::RosPrintfS<long> 
  Retro::RosPrintf(long value, const char* form, int width, int prec)
{
  return Retro::RosPrintfS<long>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of an unsigned long value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline Retro::RosPrintfS<unsigned long> 
  Retro::RosPrintf(unsigned long value, const char* form, int width, int prec)
{
  return Retro::RosPrintfS<unsigned long>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a \c double value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline Retro::RosPrintfS<double> 
  Retro::RosPrintf(double value, const char* form, int width, int prec)
{
  return Retro::RosPrintfS<double>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a const char* value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline Retro::RosPrintfS<const char*> 
  Retro::RosPrintf(const char* value, const char* form, int width, int prec)
{
  return Retro::RosPrintfS<const char*>(value, form, width, prec);
}

//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a \c const void* value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline Retro::RosPrintfS<const void*> 
  Retro::RosPrintf(const void* value, const char* form, int width, int prec)
{
  return Retro::RosPrintfS<const void*>(value, form, width, prec);
}

