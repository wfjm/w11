// $Id: Rw11.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-16  1084   1.1.3  use =delete for noncopyable instead of boost
// 2018-12-07  1078   1.1.2  use std::shared_ptr instead of boost
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2014-12-29   624   1.1    adopt to Rlink V4 attn logic
// 2013-03-06   495   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11.
*/

#ifndef included_Retro_Rw11
#define included_Retro_Rw11 1

#include <memory>

#include "librlink/RlinkServer.hpp"

namespace Retro {

  class Rw11Cpu;                            // forw decl to avoid circular incl

  class Rw11 {
    public:

                    Rw11();
      virtual      ~Rw11();
 
                    Rw11(const Rw11&) = delete;       // noncopyable 
      Rw11&         operator=(const Rw11&) = delete;  // noncopyable

      void          SetServer(const std::shared_ptr<RlinkServer>& spserv);
      const std::shared_ptr<RlinkServer>& ServerSPtr() const;
      RlinkServer&  Server() const;
      RlinkConnect& Connect() const;
      RlogFile&     LogFile() const;

      void          AddCpu(const std::shared_ptr<Rw11Cpu>& spcpu);
      size_t        NCpu() const;
      Rw11Cpu&      Cpu(size_t ind) const;

      void          Start();
      bool          IsStarted() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // some constants (also defined in cpp)
      static const int      kLam    = 0;       //!< W11 CPU cluster lam 

    protected:
      int           AttnHandler(RlinkServer::AttnArgs& args);

    protected:
      std::shared_ptr<RlinkServer>  fspServ;
      size_t        fNCpu;
      std::shared_ptr<Rw11Cpu>  fspCpu[4];
      bool          fStarted;               //!< true if Start() called
  };
  
} // end namespace Retro

#include "Rw11.ipp"

#endif
