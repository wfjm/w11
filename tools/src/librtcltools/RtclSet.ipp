// $Id: RtclSet.ipp 1091 2018-12-23 12:38:29Z mueller $
//
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-22  1091   1.1.4  <float> add float cast (-Wdouble-promotion fix)
// 2018-12-18  1089   1.1.3  use c++ style casts
// 2018-12-15  1083   1.1.2  ctor: use rval ref and move semantics
// 2018-12-14  1081   1.1.1  use std::function instead of boost
// 2017-02-20   854   1.1    add Rtime
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (inline) of class RtclSet.
*/

/*!
  \class Retro::RtclSet
  \brief FIXME_docs
*/

#include <climits>
#include <cfloat>

#include "librtools/Rtime.hpp"

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TP>
inline RtclSet<TP>::RtclSet(std::function<void(TP)>&& set)
  : fSet(move(set))
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TP>
inline RtclSet<TP>::~RtclSet()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<bool>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetBooleanFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");

  fSet(bool(val));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<char>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetIntFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");
  if (val < CHAR_MIN || val > CHAR_MAX)
    throw Rexception("RtclSet<>::oper()", 
                     "out of range for type 'char'");

  fSet(char(val));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<signed char>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetIntFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");
  if (val < SCHAR_MIN || val > SCHAR_MAX)
    throw Rexception("RtclSet<>::oper()", 
                     "out of range for type 'signed char'");

  fSet(static_cast<signed char>(val));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<unsigned char>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetIntFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");
  if (static_cast<unsigned int>(val) > UCHAR_MAX)
    throw Rexception("RtclSet<>::oper()", 
                     "out of range for type 'unsigned char'");

  fSet(static_cast<unsigned char>(val));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<short>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetIntFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");
  if (val < SHRT_MIN || val > SHRT_MAX)
    throw Rexception("RtclSet<>::oper()", 
                     "out of range for type 'short'");

  fSet(short(val));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<unsigned short>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetIntFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");
  if (static_cast<unsigned int>(val) > USHRT_MAX)
    throw Rexception("RtclSet<>::oper()", 
                     "out of range for type 'unsigned short'");

  fSet(static_cast<unsigned short>(val));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<int>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetIntFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");

  fSet(val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<unsigned int>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetIntFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");

  fSet(static_cast<unsigned int>(val));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<long>::operator()(RtclArgs& args) const 
{
  long val;
  if(Tcl_GetLongFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");

  fSet(val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<unsigned long>::operator()(RtclArgs& args) const 
{
  long val;
  if(Tcl_GetLongFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");

  fSet(static_cast<unsigned long>(val));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<float>::operator()(RtclArgs& args) const 
{
  double val;
  if(Tcl_GetDoubleFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");
  if (val < -double(FLT_MAX) || val > double(FLT_MAX))
    throw Rexception("RtclSet<>::oper()", 
                     "out of range for type 'float'");

  fSet(float(val));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<double>::operator()(RtclArgs& args) const 
{
  double val;
  if(Tcl_GetDoubleFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");

  fSet(val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<const std::string&>::operator()(RtclArgs& args) const 
{
  char* val = Tcl_GetString(args.CurrentArg());
  fSet(std::string(val));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<const Rtime&>::operator()(RtclArgs& args) const 
{
  double val;
  if(Tcl_GetDoubleFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");

  fSet(Rtime(val));
  return;
}


} // end namespace Retro

