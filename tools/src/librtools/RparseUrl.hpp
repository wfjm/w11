// $Id: RparseUrl.hpp 1161 2019-06-08 11:52:01Z mueller $
//
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-06-07  1161   1.2    add DirName,FileName,FileStem,FileType
// 2017-04-15   875   1.1    add Set() with default scheme handling
// 2013-02-23   492   1.0.1  add static FindScheme(); allow no or empty scheme
// 2013-02-03   481   1.0    Initial version, extracted from RlinkPort
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Declaration of class RparseUrl.
*/

#ifndef included_Retro_RparseUrl
#define included_Retro_RparseUrl 1

#include <string>
#include <map>

#include "RerrMsg.hpp"

namespace Retro {

  class RparseUrl {
    public:
      typedef std::map<std::string, std::string> omap_t;

                    RparseUrl();
      virtual      ~RparseUrl();

      bool          Set(const std::string& url, const std::string& optlist,
                        RerrMsg& emsg);
      bool          Set(const std::string& url, const std::string& optlist,
                        const std::string& scheme, RerrMsg& emsg);
      void          SetPath(const std::string& path);

      void          Clear();

      const std::string&  Url() const;
      const std::string&  Scheme() const;
      const std::string&  Path() const;
      std::string   DirName() const;
      std::string   FileName() const;
      std::string   FileStem() const;
      std::string   FileType() const;
      const omap_t& Opts() const;
      bool          FindOpt(const std::string& name) const;
      bool          FindOpt(const std::string& name, 
                            std::string& value) const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

      static std::string  FindScheme(const std::string& url, 
                                     const std::string& def = "");

    protected:
      bool          AddOpt(const std::string& key, const std::string& val, 
                           bool hasval, const std::string& optlist, 
                           RerrMsg& emsg);

    protected:
      std::string   fUrl;                   //!< full url given with open
      std::string   fScheme;                //!< url scheme part
      std::string   fPath;                  //!< url path part
      omap_t        fOptMap;                //!< option map
  };
  
} // end namespace Retro

#include "RparseUrl.ipp"

#endif
