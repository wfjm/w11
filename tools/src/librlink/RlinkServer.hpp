// $Id: RlinkServer.hpp 513 2013-05-01 14:02:06Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-05-01   513   1.0.2  fTraceLevel now uint32_t
// 2013-04-21   509   1.0.1  add Resume(), reorganize server start handling
// 2013-03-06   495   1.0    Initial version
// 2013-01-12   474   0.5    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkServer.hpp 513 2013-05-01 14:02:06Z mueller $
  \brief   Declaration of class \c RlinkServer.
*/

#ifndef included_Retro_RlinkServer
#define included_Retro_RlinkServer 1

#include <poll.h>

#include <cstdint>
#include <vector>
#include <list>

#include "boost/utility.hpp"
#include "boost/thread/thread.hpp"
#include "boost/shared_ptr.hpp"

#include "librtools/Rstats.hpp"

#include "ReventFd.hpp"
#include "RlinkConnect.hpp"
#include "RlinkContext.hpp"
#include "RlinkServerEventLoop.hpp"

namespace Retro {

  class RlinkServer : private boost::noncopyable {
    public:

      struct AttnArgs {
        uint16_t    fAttnPatt;
        uint16_t    fAttnMask;
        RlinkCommandList* fpClist;
        size_t      fOffset;
                    AttnArgs();
                    AttnArgs(uint16_t apatt, uint16_t amask);
                    AttnArgs(uint16_t apatt, uint16_t amask, 
                             RlinkCommandList* pclist, size_t off);
      };

      typedef ReventLoop::pollhdl_t                  pollhdl_t;
      typedef boost::function<int(const AttnArgs&)>  attnhdl_t;
      typedef boost::function<int()>                 actnhdl_t;

      explicit      RlinkServer();
      virtual      ~RlinkServer();

      void          SetConnect(const boost::shared_ptr<RlinkConnect>& spconn);
      const boost::shared_ptr<RlinkConnect>& ConnectSPtr() const;
      RlinkConnect& Connect() const;
      RlogFile&     LogFile() const;
      RlinkContext& Context();  

      bool          Exec(RlinkCommandList& clist, RerrMsg& emsg);
      bool          Exec(RlinkCommandList& clist);

      void          AddAttnHandler(const attnhdl_t& attnhdl, uint16_t mask,
                                   void* cdata = 0);
      void          RemoveAttnHandler(uint16_t mask, void* cdata = 0);

      void          QueueAction(const actnhdl_t& actnhdl);


      void          AddPollHandler(const pollhdl_t& pollhdl,
                                   int fd, short events=POLLIN);
      bool          TestPollHandler(int fd, short events=POLLIN);
      void          RemovePollHandler(int fd, short events, bool nothrow=false);
      void          RemovePollHandler(int fd);

      void          Start();
      void          Stop();
      void          Resume();
      void          Wakeup();
      void          SignalAttn();

      bool          IsActive() const;
      bool          IsActiveInside() const;
      bool          IsActiveOutside() const;

      void          SetTraceLevel(uint32_t level);
      uint32_t      TraceLevel() const;

      const Rstats& Stats() const;

      void          Print(std::ostream& os) const;
      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // statistics counter indices
      enum stats {
        kStatNEloopWait = 0,
        kStatNEloopPoll,
        kStatNWakeupEvt,
        kStatNRlinkEvt,
        kStatNAttnRead, 
        kStatNAttn00,
        kStatNAttn01,
        kStatNAttn02,
        kStatNAttn03,
        kStatNAttn04,
        kStatNAttn05,
        kStatNAttn06,
        kStatNAttn07,
        kStatNAttn08,
        kStatNAttn09,
        kStatNAttn10,
        kStatNAttn11,
        kStatNAttn12,
        kStatNAttn13,
        kStatNAttn14,
        kStatNAttn15,
        kDimStat
      };

      friend class RlinkServerEventLoop;

    protected:
      void          StartOrResume(bool resume);
      bool          AttnPending() const;
      bool          ActnPending() const;
      void          CallAttnHandler();
      void          CallActnHandler();
      int           WakeupHandler(const pollfd& pfd);
      int           RlinkHandler(const pollfd& pfd);

    protected:
      struct AttnId {
        uint16_t    fMask;
        void*       fCdata;
                    AttnId();
                    AttnId(uint16_t mask, void* cdata);
        bool        operator==(const AttnId& rhs) const;
      };

      struct AttnDsc {
        attnhdl_t   fHandler;
        AttnId      fId;
                    AttnDsc();
                    AttnDsc(attnhdl_t hdl, const AttnId& id);
      };

      boost::shared_ptr<RlinkConnect>  fspConn;
      RlinkContext  fContext;               //!< default server context
      std::vector<AttnDsc>  fAttnDsc;
      std::list<actnhdl_t>  fActnList;
      ReventFd      fWakeupEvent;
      RlinkServerEventLoop fELoop;
      boost::thread fServerThread;
      bool          fAttnSeen;
      uint16_t      fAttnPatt;
      uint32_t      fTraceLevel;            //!< trace level
      Rstats        fStats;                 //!< statistics
};
  
} // end namespace Retro

#include "RlinkServer.ipp"

#endif
