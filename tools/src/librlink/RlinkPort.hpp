// $Id: RlinkPort.hpp 465 2012-12-27 21:29:38Z mueller $
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
// 2012-12-26   465   1.0.2  add CloseFd() method
// 2011-04-24   380   1.0.1  use boost::noncopyable (instead of private dcl's)
// 2011-03-27   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkPort.hpp 465 2012-12-27 21:29:38Z mueller $
  \brief   Declaration of class RlinkPort.
*/

#ifndef included_Retro_RlinkPort
#define included_Retro_RlinkPort 1

#include <string>
#include <map>

#include "boost/utility.hpp"

#include "librtools/RerrMsg.hpp"
#include "librtools/RlogFile.hpp"
#include "librtools/Rstats.hpp"

namespace Retro {

  class RlinkPort : private boost::noncopyable {
    public:
      typedef std::map<std::string, std::string> omap_t;
      typedef omap_t::iterator         omap_it_t;
      typedef omap_t::const_iterator   omap_cit_t;
      typedef omap_t::value_type       omap_val_t;

                    RlinkPort();
      virtual       ~RlinkPort();

      virtual bool  Open(const std::string& url, RerrMsg& emsg) = 0;
      virtual void  Close();

      virtual int   Read(uint8_t* buf, size_t size, double timeout, 
                         RerrMsg& emsg);
      virtual int   Write(const uint8_t* buf, size_t size, RerrMsg& emsg);
      virtual bool  PollRead(double timeout);

      bool          IsOpen() const;
      const std::string&  Url() const;
      const std::string&  UrlScheme() const;
      const std::string&  UrlPath() const;
      const omap_t&       UrlOpts() const;
      bool                UrlFindOpt(const std::string& name) const;
      bool                UrlFindOpt(const std::string& name, 
                                     std::string& value) const;

      int           FdRead() const;
      int           FdWrite() const;

      void          SetLogFile(RlogFile* log);
      void          SetTraceLevel(size_t level);
      size_t        TraceLevel() const;

      const Rstats& Stats() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // some constants
      static const int  kEof  = 0;
      static const int  kTout = -1;
      static const int  kErr  = -2;      

    // statistics counter indices
      enum stats {
        kStatNPortWrite = 0,
        kStatNPortRead,
        kStatNPortTxByt,
        kStatNPortRxByt,
        kDimStat
      };    

    protected:
      bool          ParseUrl(const std::string& url, const std::string& optlist,
                             RerrMsg& emsg);
      bool          AddOpt(const std::string& key, const std::string& val, 
                           bool hasval, const std::string& optlist, 
                           RerrMsg& emsg);
      void          CloseFd(int& fd);

    protected:
      bool          fIsOpen;                //!< is open flag
      std::string   fUrl;                   //!< full url given with open
      std::string   fScheme;                //!< url scheme part
      std::string   fPath;                  //!< url path part
      omap_t        fOptMap;                //!< option map
      int           fFdRead;                //!< fd for read
      int           fFdWrite;               //!< fd for write
      RlogFile*     fpLogFile;              //!< ptr to log file dsc
      size_t        fTraceLevel;            //!< trace level
      Rstats        fStats;                 //!< statistics
  };
  
} // end namespace Retro

#if !(defined(Retro_NoInline) || defined(Retro_RlinkPort_NoInline))
#include "RlinkPort.ipp"
#endif

#endif
