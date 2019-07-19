// $Id: RparseUrl.cpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1161   1.2    add DirName,FileName,FileStem,FileType
// 2018-11-16  1070   1.1.1  use auto; use emplace,make_pair; use range loop
// 2017-04-15   875   1.1    add Set() with default scheme handling
// 2015-06-04   686   1.0.2  Set(): add check that optlist is enclosed by '|'
// 2013-02-23   492   1.0.1  add static FindScheme(); allow no or empty scheme
// 2013-02-03   481   1.0    Initial version, extracted from RlinkPort
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RparseUrl.
*/

#include <iostream>

#include "RparseUrl.hpp"

#include "RosFill.hpp"
#include "RosPrintf.hpp"

using namespace std;

/*!
  \class Retro::RparseUrl
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RparseUrl::RparseUrl()
  : fUrl(),
    fScheme(),
    fPath(),
    fOptMap()
{}

//------------------------------------------+-----------------------------------
//! Destructor

RparseUrl::~RparseUrl()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RparseUrl::Set(const std::string& url, const std::string& optlist, 
                    RerrMsg& emsg)
{
  fUrl    = url;
  fScheme = FindScheme(url);
  fPath.clear();
  fOptMap.clear();

  // check that optlist is empty or starts and ends with '|'
  if (optlist.length() > 0 && 
        (optlist.length()<2 || 
         optlist[0]!='|' || optlist[optlist.length()-1]!='|') ) {
    emsg.Init("RparseUrl::Set()", string("optlist \"") + optlist + 
                                         "\" not enclosed in '|'"); 
    return false;
  }

  size_t pdel = fScheme.length();
  if (pdel == 0 && url.length()>0 && url[0] != ':') pdel = -1;
  size_t odel = url.find_first_of('?', fScheme.length());

  if (odel == string::npos) {               // no options
    if (url.length() > pdel+1) fPath = url.substr(pdel+1);

  } else {                                  // options to process
    fPath = url.substr(pdel+1,odel-(pdel+1));
    string key;
    string val;
    bool   hasval = false;

    for (size_t i=odel+1; i<url.length(); i++) {
      char c = url[i];
      if (c == ';') {
        if (!AddOpt(key, val, hasval, optlist, emsg)) return false;
        key.clear();
        val.clear();
        hasval = false;
      } else {
        if (!hasval) {
          if (c == '=') {
            hasval = true;
          } else 
            key.push_back(c);
        } else {
          if (c == '\\') {
            if (i+1 >= url.length()) {
              emsg.Init("RparseUrl::Set()",
                        string("invalid trailing \\ in url '") + url + "'");
              return false;
            }
            i += 1;
            switch (url[i]) {
              case '\\' : c = '\\'; break;
              case ';'  : c = ';';  break;
              default   : emsg.Init("RparseUrl::Set()",
                                    string("invalid \\ escape in url '") + 
                                    url + "'");
                          return false;
            }
          }
          val.push_back(c);
        }
      }
    }
    if (key.length() || hasval) {
      if (!AddOpt(key, val, hasval, optlist, emsg)) return false;
    }
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RparseUrl::Set(const std::string& url, const std::string& optlist, 
                    const std::string& scheme, RerrMsg& emsg)
{
  if (FindScheme(url).length() == 0 && scheme.length() > 0) {
    string url1 = scheme + string(":") + url;
    return Set(url1, optlist, emsg);
  }
  
  return Set(url, optlist, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RparseUrl::Clear()
{
  fUrl.clear();
  fScheme.clear();
  fPath.clear();
  fOptMap.clear();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string RparseUrl::DirName() const
{
  size_t ddel = fPath.find_last_of('/');
  return (ddel == string::npos) ? "." : fPath.substr(0,ddel);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string RparseUrl::FileName() const
{
  size_t ddel = fPath.find_last_of('/');
  return (ddel != string::npos && ddel+1 <= fPath.length()) ?
    fPath.substr(ddel+1) : fPath;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string RparseUrl::FileStem() const
{
  string fname = FileName();
  size_t ddel = fname.find_last_of('.');
  return (ddel == string::npos) ? "" : fname.substr(0,ddel);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string RparseUrl::FileType() const
{
  string fname = FileName();
  size_t ddel = fname.find_last_of('.');
  return (ddel != string::npos && ddel+1 <= fname.length()) ?
    fname.substr(ddel+1) : "";
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RparseUrl::FindOpt(const std::string& name) const
{
  auto it = fOptMap.find(name);
  if (it == fOptMap.end()) return false;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RparseUrl::FindOpt(const std::string& name, std::string& value) const
{
  auto it = fOptMap.find(name);
  if (it == fOptMap.end()) return false;

  value = it->second;
  
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RparseUrl::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RparseUrl @ " << this << endl;

  os << bl << "  fUrl:            " << fUrl << endl;
  os << bl << "  fScheme:         " << fScheme << endl;
  os << bl << "  fPath:           " << fPath << endl;
  os << bl << "  fOptMap:         " << endl;
  for (auto& o: fOptMap) {
    os << bl << "    " << RosPrintf(o.first.c_str(), "-s",8)
       << " : " << o.second << endl;
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string RparseUrl::FindScheme(const std::string& url, 
                                  const std::string& def)
{
  size_t pdel = url.find_first_of(':');
  if (pdel == string::npos) {               // no : found
    return def;
  }
  
  size_t odel = url.find_first_of('?');
  if (odel != string::npos && odel < pdel) { // : after ?
    return def;
  }
  
  return url.substr(0, pdel);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RparseUrl::AddOpt(const std::string& key, const std::string& val, 
                       bool hasval, const std::string& optlist, RerrMsg& emsg)
{
  string lkey = "|";
  lkey += key;
  if (hasval) lkey += "=";
  lkey += "|";
  if (optlist.find(lkey) == string::npos) {
    emsg.Init("RparseUrl::AddOpt()", 
              string("invalid field name '") + lkey + "'; allowed: '" +
              optlist + "'");
    return false;
  }

  fOptMap.emplace(make_pair(key, hasval ? val : "1"));
  return true;
}

} // end namespace Retro
