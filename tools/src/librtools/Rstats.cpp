// $Id: Rstats.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.0.6  add Reset(); drop operator-=() and operator*=()
// 2018-12-18  1089   1.0.5  use c++ style casts
// 2017-02-04   865   1.0.4  add NameMaxLength(); Print(): add counter name
// 2017-02-18   851   1.0.3  add IncLogHist; fix + and * operator definition
// 2013-02-03   481   1.0.2  use Rexception
// 2011-03-06   367   1.0.1  use max from algorithm
// 2011-02-06   359   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of Rstats .
*/

#include <algorithm>

#include "Rstats.hpp"

#include "RosFill.hpp"
#include "RosPrintf.hpp"
#include "Rexception.hpp"

using namespace std;

/*!
  \class Retro::Rstats
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rstats::Rstats()
  : fValue(),
    fName(),
    fText(),
    fHash(0),
    fFormat("f"),
    fWidth(12),
    fPrec(0)
{}

//------------------------------------------+-----------------------------------
//! Copy constructor

Rstats::Rstats(const Rstats& rhs)
  : fValue(rhs.fValue),
    fName(rhs.fName),
    fText(rhs.fText),
    fHash(rhs.fHash),
    fFormat(rhs.fFormat),
    fWidth(rhs.fWidth),
    fPrec(rhs.fPrec)
{}

//------------------------------------------+-----------------------------------
//! Destructor
Rstats::~Rstats()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rstats::Define(size_t ind, const std::string& name, 
                    const std::string& text)
{
  // update hash
  for (size_t i=0; i<name.length(); i++) 
    fHash = 69069*fHash + uint32_t(name[i]);
  for (size_t i=0; i<text.length(); i++) 
    fHash = 69069*fHash + uint32_t(text[i]);

  // in case it's the 'next' counter use push_back
  if (ind == Size()) {
    fValue.push_back(0.);
    fName.push_back(name);
    fText.push_back(text);

  // otherwise resize and set
  } else {
    if (ind >= Size()) {
      fValue.resize(ind+1);
      fName.resize(ind+1);
      fText.resize(ind+1);
    }
    fValue[ind] = 0.;
    fName[ind]  = name;
    fText[ind]  = text;
  }
  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rstats::Reset()
{
  for (auto& o: fValue) o = 0.;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rstats::IncLogHist(size_t ind, size_t maskfirst,
                        size_t masklast, size_t val)
{
  if (val == 0) return;
  size_t mask = maskfirst;
  while (ind < fValue.size()) {
    if (val <= mask || mask >= masklast) {  // val in bin or last bin
      Inc(ind);
      return;
    }
    mask = (mask<<1) | 0x1;
    ind += 1;
  }
  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rstats::SetFormat(const char* format, int width, int prec)
{
  fFormat = format;
  fWidth  = width;
  fPrec   = prec;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
size_t Rstats::NameMaxLength() const
{
  size_t maxlen = 0;
  for (size_t i=0; i<Size(); i++) {
    size_t len = fName[i].length();
    if (len > maxlen) maxlen = len;
  }
  return maxlen;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rstats::Print(std::ostream& os, const char* format,
                   int width, int prec) const
{
  if (format == nullptr || format[0]==0) {
    format = fFormat.c_str();
    width  = fWidth;
    prec   = fPrec;
  }

  size_t maxlen = NameMaxLength();
  for (size_t i=0; i<Size(); i++) {
    os << RosPrintf(fValue[i], format, width, prec)
       << " : " << RosPrintf(fName[i].c_str(),"-s",maxlen) 
       << " : " << fText[i] << endl;
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rstats::Dump(std::ostream& os, int ind, const char* text,
                  int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rstats @ " << this << endl;
  if (detail >= 0) {                      // full dump
    size_t maxlen=8;
    for (size_t i=0; i<Size(); i++) maxlen = max(maxlen, fName[i].length());
    
    for (size_t i=0; i<Size(); i++) {
      os << bl << "  " << fName[i] << ":" << RosFill(maxlen-fName[i].length()+1)
         << RosPrintf(fValue[i], "f", 12)
         << "  '" << fText[i] << "'" << endl;
    }
  }  else {
    os << bl << "  fValue.size:        "
       << RosPrintf(fValue.size(),"d",2) << endl;
  }

  os << bl << "  fHash:              " << RosPrintf(fHash,"x",8) << endl;
  os << bl << "  fFormat,Width,Prec: " << fFormat
     << ", " << RosPrintf(fWidth,"d",2)
     << ", " << RosPrintf(fPrec,"d",2)  << endl;

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rstats& Rstats::operator=(const Rstats& rhs)
{
  if (&rhs == this) return *this;

  // in case this is freshly constructed, copy full context
  if (Size() == 0) {
    fValue  = rhs.fValue;
    fName   = rhs.fName;
    fText   = rhs.fText;
    fHash   = rhs.fHash;
    fFormat = rhs.fFormat;
    fWidth  = rhs.fWidth;
    fPrec   = rhs.fPrec;

  // otherwise check hash and copy only values
  } else {
    if (Size() != rhs.Size() || fHash != rhs.fHash) {
      throw Rexception("Rstats::oper=()",
                       "Bad args: assign incompatible stats");
    }
    fValue = rhs.fValue;
  }

  return *this;
}

} // end namespace Retro
