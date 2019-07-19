// $Id: RosPrintf.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2000-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-17  1088   1.1    add bool specialization (use c++11 std::boolalpha)
// 2011-01-30   357   1.0    Adopted from CTBprintf
// 2000-12-18     -   -      Last change on CTBprintf
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of RosPrintf.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
/*!
  \defgroup RosPrintf RosPrintf -- print format object creators
*/
//------------------------------------------+-----------------------------------
//! Creates a print object for the formatted output of a \c bool value.
/*!
  \ingroup RosPrintf

  For a full description of the of the \c RosPrintf system look into 
  \ref using_rosprintf. 

  \param value  variable or expression to be printed
  \param form   format descriptor string
  \param width  field width
  \param prec   precision
*/

inline RosPrintfS<bool> 
  RosPrintf(bool value, const char* form, int width, int prec)
{
  return RosPrintfS<bool>(value, form, width, prec);
}

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

inline RosPrintfS<char> 
  RosPrintf(char value, const char* form, int width, int prec)
{
  return RosPrintfS<char>(value, form, width, prec);
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

inline RosPrintfS<int> 
  RosPrintf(signed char value, const char* form, int width, int prec)
{
  return RosPrintfS<int>(value, form, width, prec);
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

inline RosPrintfS<unsigned int> 
  RosPrintf(unsigned char value, const char* form, int width, int prec)
{
  return RosPrintfS<unsigned int>(value, form, width, prec);
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

inline RosPrintfS<int> 
  RosPrintf(short value, const char* form, int width, int prec)
{
  return RosPrintfS<int>(value, form, width, prec);
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

inline RosPrintfS<unsigned int> 
  RosPrintf(unsigned short value, const char* form, int width, int prec)
{
  return RosPrintfS<unsigned int>(value, form, width, prec);
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

inline RosPrintfS<int> 
  RosPrintf(int value, const char* form, int width, int prec)
{
  return RosPrintfS<int>(value, form, width, prec);
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

inline RosPrintfS<unsigned int> 
  RosPrintf(unsigned int value, const char* form, int width, int prec)
{
  return RosPrintfS<unsigned int>(value, form, width, prec);
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

inline RosPrintfS<long> 
  RosPrintf(long value, const char* form, int width, int prec)
{
  return RosPrintfS<long>(value, form, width, prec);
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

inline RosPrintfS<unsigned long> 
  RosPrintf(unsigned long value, const char* form, int width, int prec)
{
  return RosPrintfS<unsigned long>(value, form, width, prec);
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

inline RosPrintfS<double> 
  RosPrintf(double value, const char* form, int width, int prec)
{
  return RosPrintfS<double>(value, form, width, prec);
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

inline RosPrintfS<const char*> 
  RosPrintf(const char* value, const char* form, int width, int prec)
{
  return RosPrintfS<const char*>(value, form, width, prec);
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

inline RosPrintfS<const void*> 
  RosPrintf(const void* value, const char* form, int width, int prec)
{
  return RosPrintfS<const void*>(value, form, width, prec);
}

} // end namespace Retro
