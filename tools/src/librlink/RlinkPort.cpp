// $Id: RlinkPort.cpp 375 2011-04-02 07:56:47Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-03-27   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPort.cpp 375 2011-04-02 07:56:47Z mueller $
  \brief   Implemenation of RlinkPort.
*/

#include <errno.h>
#include <unistd.h>
#include <poll.h>

#include <stdexcept>
#include <iostream>

#include "RlinkPort.hpp"

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::RlinkPort
  \brief FIXME_docs
*/

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkPort::RlinkPort()
  : fIsOpen(false),
    fUrl(),
    fScheme(),
    fPath(),
    fOptMap(),
    fFdRead(-1),
    fFdWrite(-1),
    fpLogFile(0),
    fTraceLevel(0),
    fStats()
{
  fStats.Define(kStatNPortWrite, "NPortWrite", "Port::Write() calls");
  fStats.Define(kStatNPortRead,  "NPortRead",  "Port::Read() calls");
  fStats.Define(kStatNPortTxByt, "NPortTxByt", "Port Tx raw bytes send");
  fStats.Define(kStatNPortRxByt, "NPortRxByt", "Port Rx raw bytes rcvd");
}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkPort::~RlinkPort()
{
  if (IsOpen()) RlinkPort::Close();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPort::Close()
{
  if (! IsOpen())
    throw logic_error("RlinkPort::Close(): port not open");

  close(fFdRead);
  if (fFdWrite != fFdRead) close(fFdWrite);

  fFdRead  = -1;
  fFdWrite = -1;
  fIsOpen  = false;
  fUrl.clear();
  fScheme.clear();
  fPath.clear();
  fOptMap.clear();
    
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RlinkPort::Read(uint8_t* buf, size_t size, double timeout, RerrMsg& emsg)
{
  if (!IsOpen())
    throw logic_error("RlinkPort::Read(): port not open");
  if (buf == 0) 
    throw invalid_argument("RlinkPort::Read(): buf==NULL");
  if (size == 0) 
    throw invalid_argument("RlinkPort::Read(): size==0");

  fStats.Inc(kStatNPortRead);

  bool rdpoll = PollRead(timeout);
  if (!rdpoll) return kTout;

  int irc = -1;
  while (irc < 0) {
    irc = read(fFdRead, (void*) buf, size);
    if (irc < 0 && errno != EINTR) {
      emsg.InitErrno("RlinkPort::Read()", "read() failed : ", errno);
      if (fpLogFile && fTraceLevel>0) (*fpLogFile)('E') << emsg << endl;
      return kErr;
    }
  }

  if (fpLogFile && fTraceLevel>0) {
    ostream& os = (*fpLogFile)();
    (*fpLogFile)('I') << "port  read nchar=" << RosPrintf(irc,"d",4);
    if (fTraceLevel>1) {
      size_t ncol = (80-5-6)/(2+1);
      for (int i=0; i<irc; i++) {
        if ((i%ncol)==0) os << "\n     " << RosPrintf(i,"d",4) << ": ";
        os << RosPrintBvi(buf[i],16) << " ";
      }
    }
    os << endl;
  } 

  fStats.Inc(kStatNPortRxByt, double(irc));

  return irc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RlinkPort::Write(const uint8_t* buf, size_t size, RerrMsg& emsg)
{
  if (!IsOpen()) 
    throw logic_error("RlinkPort::Write(): port not open");
  if (buf == 0) 
    throw invalid_argument("RlinkPort::Write(): buf==NULL");
  if (size == 0) 
    throw invalid_argument("RlinkPort::Write(): size==0");

  fStats.Inc(kStatNPortWrite);

  if (fpLogFile && fTraceLevel>0) {
    ostream& os = (*fpLogFile)();
    (*fpLogFile)('I') << "port write nchar=" << RosPrintf(size,"d",4);
    if (fTraceLevel>1) {
      size_t ncol = (80-5-6)/(2+1);
      for (size_t i=0; i<size; i++) {
        if ((i%ncol)==0) os << "\n     " << RosPrintf(i,"d",4) << ": ";
        os << RosPrintBvi(buf[i],16) << " ";
      }
    }
    os << endl;
  }

  size_t ndone = 0;
  while (ndone < size) {
    int irc = -1;
    while (irc < 0) {
      irc = write(fFdWrite, (void*) (buf+ndone), size-ndone);
      if (irc < 0 && errno != EINTR) {
        emsg.InitErrno("RlinkPort::Write()", "write() failed : ", errno);
        if (fpLogFile && fTraceLevel>0) (*fpLogFile)('E') << emsg << endl;
        return kErr;
      }
    }
    // FIXME_code: handle eof ??
    ndone += irc;
  }

  fStats.Inc(kStatNPortTxByt, double(ndone));

  return ndone;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPort::PollRead(double timeout)
{
  if (! IsOpen())
    throw logic_error("RlinkPort::PollRead(): port not open");
  if (timeout < 0.)
    throw invalid_argument("RlinkPort::PollRead(): timeout < 0");

  int ito = 1000.*timeout + 0.1;

  struct pollfd fds[1] = {{fFdRead,         // fd
                           POLLIN,          // events
                           0}};             // revents


  int irc = -1;
  while (irc < 0) {
    irc = poll(fds, 1, ito);
    if (irc < 0 && errno != EINTR)
      throw logic_error("RlinkPort::PollRead(): poll failed: rc<0");
  }

  if (irc == 0) return false;

  if (fds[0].revents == POLLERR)
    throw logic_error("RlinkPort::PollRead(): poll failed: POLLERR");

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPort::UrlFindOpt(const std::string& name) const
{
  omap_cit_t it = fOptMap.find(name);
  if (it == fOptMap.end()) return false;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPort::UrlFindOpt(const std::string& name, std::string& value) const
{
  omap_cit_t it = fOptMap.find(name);
  if (it == fOptMap.end()) return false;

  value = it->second;
  
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPort::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkPort @ " << this << endl;

  os << bl << "  fIsOpen:         " << (int)fIsOpen << endl;
  os << bl << "  fUrl:            " << fUrl << endl;
  os << bl << "  fScheme:         " << fScheme << endl;
  os << bl << "  fPath:           " << fPath << endl;
  os << bl << "  fOptMap:         " << endl;
  for (omap_cit_t it=fOptMap.begin(); it!=fOptMap.end(); it++) {
    os << bl << "    " << RosPrintf((it->first).c_str(), "-s",8)
       << " : " << it->second << endl;
  }
  os << bl << "  fFdRead:         " << fFdRead << endl;
  os << bl << "  fFdWrite:        " << fFdWrite << endl;
  fStats.Dump(os, ind+2, "fStats: ");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPort::ParseUrl(const std::string& url, const std::string& optlist, 
                         RerrMsg& emsg)
{
  fUrl.clear();
  fScheme.clear();
  fPath.clear();
  fOptMap.clear();
  
  size_t pdel = url.find_first_of(':');
  if (pdel == string::npos) {
    emsg.Init("RlinkPort::ParseUrl()",
              string("no scheme specified in url \"") + url + string("\""));
    return false;
  }

  fUrl = url;
  fScheme = url.substr(0, pdel);

  size_t odel = url.find_first_of('?', pdel);
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
              emsg.Init("RlinkPort::ParseUrl()",
                        string("invalid trailing \\ in url \"") + url + 
                        string("\""));
              return false;
            }
            i += 1;
            switch (url[i]) {
              case '\\' : c = '\\'; break;
              case ';'  : c = ';';  break;
              default   : emsg.Init("RlinkPort::ParseUrl()",
                                    string("invalid \\ escape in url \"") + 
                                    url + string("\""));
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

bool RlinkPort::AddOpt(const std::string& key, const std::string& val, 
                       bool hasval, const std::string& optlist, RerrMsg& emsg)
{
  string lkey = "|";
  lkey += key;
  if (hasval) lkey += "=";
  lkey += "|";
  if (optlist.find(lkey) == string::npos) {
    emsg.Init("RlinkPort::AddOpt()", 
              string("invalid field name \"") + lkey + string("\""));
  }

  fOptMap.insert(omap_val_t(key, hasval ? val : "1"));
  return true;
}

//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_RlinkPort_NoInline))
#define inline
#include "RlinkPort.ipp"
#undef  inline
#endif
