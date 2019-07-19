// $Id: RtclGet.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-02-16  1112   1.2.5  use const& for oper() of string& and Rtime&
// 2018-12-22  1091   1.2.4  <float> add float cast (-Wdouble-promotion fix)
// 2018-12-18  1089   1.2.3  use c++ style casts
// 2018-12-15  1083   1.2.2  ctor: use rval ref and move semantics
// 2018-12-14  1081   1.2.1  use std::function instead of boost
// 2017-04-16   876   1.2    add Tcl_Obj*
// 2017-02-20   854   1.1    add Rtime
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of class RtclGet.
*/

/*!
  \class Retro::RtclGet
  \brief FIXME_docs
*/

#include "librtools/Rtime.hpp"
#include <iostream>

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TP>
inline RtclGet<TP>::RtclGet(std::function<TP()>&& get)
  : fGet(move(get))
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TP>
inline RtclGet<TP>::~RtclGet()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<bool>::operator()() const 
{
  bool val = fGet();
  return Tcl_NewBooleanObj(int(val));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<char>::operator()() const 
{
  char val = fGet();
  return Tcl_NewIntObj(int(val));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<signed char>::operator()() const 
{
  signed char val = fGet();
  return Tcl_NewIntObj(int(val));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<unsigned char>::operator()() const 
{
  unsigned char val = fGet();
  return Tcl_NewIntObj(int(val));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<short>::operator()() const 
{
  short val = fGet();
  return Tcl_NewIntObj(int(val));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<unsigned short>::operator()() const 
{
  unsigned short val = fGet();
  return Tcl_NewIntObj(int(val));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<int>::operator()() const 
{
  int val = fGet();
  return Tcl_NewIntObj(val);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<unsigned int>::operator()() const 
{
  unsigned int val = fGet();
  return Tcl_NewIntObj(int(val));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<long>::operator()() const 
{
  long val = fGet();
  return Tcl_NewLongObj(val);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<unsigned long>::operator()() const 
{
  unsigned long val = fGet();
  return Tcl_NewLongObj(long(val));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<float>::operator()() const 
{
  float val = fGet();
  return Tcl_NewDoubleObj(double(val));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<double>::operator()() const 
{
  double val = fGet();
  return Tcl_NewDoubleObj(val);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<std::string>::operator()() const 
{
  std::string val = fGet();
  return Tcl_NewStringObj(val.data(), val.length());
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<const std::string&>::operator()() const 
{
  const std::string& val = fGet();
  return Tcl_NewStringObj(val.data(), val.length());
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<Rtime>::operator()() const 
{
  Rtime val = fGet();
  return Tcl_NewDoubleObj(double(val));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<const Rtime&>::operator()() const 
{
  const Rtime& val = fGet();
  return Tcl_NewDoubleObj(double(val));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline Tcl_Obj* RtclGet<Tcl_Obj*>::operator()() const 
{
  return fGet();
}


} // end namespace Retro

