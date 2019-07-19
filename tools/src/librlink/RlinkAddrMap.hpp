// $Id: RlinkAddrMap.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2011-03-05   366   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class \c RlinkAddrMap.
*/

#ifndef included_Retro_RlinkAddrMap
#define included_Retro_RlinkAddrMap 1

#include <cstdint>
#include <string>
#include <map>
#include <ostream>

namespace Retro {

  class RlinkAddrMap {
    public:
      typedef std::map<std::string, uint16_t> nmap_t;
      typedef std::map<uint16_t, std::string> amap_t;

                    RlinkAddrMap();
                   ~RlinkAddrMap();

      void          Clear();

      bool          Insert(const std::string& name, uint16_t addr);
      bool          Erase(const std::string& name);
      bool          Erase(uint16_t addr);

      bool          Find(const std::string& name, uint16_t& addr) const;
      bool          Find(uint16_t addr, std::string& name) const;

      const nmap_t& Nmap() const;
      const amap_t& Amap() const;

      size_t        MaxNameLength() const;

      void          Print(std::ostream& os, int ind=0) const;
      void          Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    protected:
      nmap_t        fNameMap;               //!< name->addr map
      amap_t        fAddrMap;               //!< addr->name map
      mutable size_t  fMaxLength;           //!< max name length
    
  };
  
} // end namespace Retro

#include "RlinkAddrMap.ipp"

#endif
