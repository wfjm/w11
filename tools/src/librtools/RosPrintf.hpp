// $Id: RosPrintf.hpp 1186 2019-07-12 17:49:59Z mueller $
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
  \brief   Declaration of RosPrintf functions.

  For a detailed description of the usage of the \c RosPrintf system
  look into \ref using_rosprintf.
*/

#ifndef included_Retro_RosPrintf
#define included_Retro_RosPrintf 1

#include "RosPrintfS.hpp"

namespace Retro {
  
  RosPrintfS<bool>   RosPrintf(bool value, const char* form=0, 
                               int width=0, int prec=0);

  RosPrintfS<char>   RosPrintf(char value, const char* form=0, 
                               int width=0, int prec=0);

  RosPrintfS<int>    RosPrintf(signed char value, const char* form=0, 
                               int width=0, int prec=0);
  RosPrintfS<unsigned int> RosPrintf(unsigned char value, const char* form=0, 
                                     int width=0, int prec=0);

  RosPrintfS<int>    RosPrintf(short value, const char* form=0,
                               int width=0, int prec=0);
  RosPrintfS<unsigned int> RosPrintf(unsigned short value, const char* form=0,
                                     int width=0, int prec=0);

  RosPrintfS<int>    RosPrintf(int value, const char* form=0, 
                               int width=0, int prec=0);
  RosPrintfS<unsigned int> RosPrintf(unsigned int value, const char* form=0,
                                     int width=0, int prec=0);

  RosPrintfS<long>    RosPrintf(long value, const char* form=0, 
                                int width=0, int prec=0);
  RosPrintfS<unsigned long> RosPrintf(unsigned long value, const char* form=0,
                                      int width=0, int prec=0);

  RosPrintfS<double>   RosPrintf(double value, const char* form=0, 
                                 int width=0, int prec=0);

  RosPrintfS<const char*> RosPrintf(const char* value, const char* form=0, 
                                    int width=0, int prec=0);

  RosPrintfS<const void*> RosPrintf(const void* value, const char* form=0, 
                                    int width=0, int prec=0);

} // end namespace Retro

// implementation is all inline
#include "RosPrintf.ipp"

#endif
