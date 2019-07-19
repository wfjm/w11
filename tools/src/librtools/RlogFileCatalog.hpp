// $Id: RlogFileCatalog.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-16  1084   1.0.2  use =delete for noncopyable instead of boost
// 2018-12-07  1078   1.0.1  use std::shared_ptr instead of boost
// 2013-02-22   491   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of class RlogFileCatalog.
*/

#ifndef included_Retro_RlogFileCatalog
#define included_Retro_RlogFileCatalog 1

#include <map>
#include <memory>

#include "RlogFile.hpp"

namespace Retro {

  class RlogFileCatalog {
    public:

      static RlogFileCatalog&  Obj();    

      const std::shared_ptr<RlogFile>& FindOrCreate(const std::string& name);
      void          Delete(const std::string& name);

    private:
                    RlogFileCatalog();
                   ~RlogFileCatalog();

                    RlogFileCatalog(const RlogFileCatalog&) = delete; // noncopy 
      RlogFileCatalog& operator=(const RlogFileCatalog&) = delete;    // noncopy

  protected:
      typedef std::map<std::string, std::shared_ptr<RlogFile>> map_t;

      map_t         fMap;                   //!< name->rlogfile map
  };
  
} // end namespace Retro

//#include "RlogFileCatalog.ipp"

#endif
