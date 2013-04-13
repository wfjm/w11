// $Id: ReventLoop.hpp 494 2013-03-03 21:50:07Z mueller $
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
// 2013-02-22   491   1.1    use new RlogFile/RlogMsg interfaces
// 2013-01-11   473   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: ReventLoop.hpp 494 2013-03-03 21:50:07Z mueller $
  \brief   Declaration of class \c ReventLoop.
*/

#ifndef included_Retro_ReventLoop
#define included_Retro_ReventLoop 1

#include <poll.h>

#include <cstdint>
#include <vector>

#include "boost/utility.hpp"
#include "boost/function.hpp"
#include "boost/thread/mutex.hpp"
#include "boost/shared_ptr.hpp"

#include "librtools/RlogFile.hpp"

namespace Retro {

  class ReventLoop : private boost::noncopyable {
    public:
      typedef boost::function<int(const pollfd&)> pollhdl_t;

                    ReventLoop();
      virtual      ~ReventLoop();

      void          AddPollHandler(const pollhdl_t& pollhdl,
                               int fd, short events=POLLIN);
      bool          TestPollHandler(int fd, short events=POLLIN);
      void          RemovePollHandler(int fd, short events, bool nothrow=false);
      void          RemovePollHandler(int fd);

      void          SetLogFile(const boost::shared_ptr<RlogFile>& splog);
      void          SetTraceLevel(size_t level);
      size_t        TraceLevel() const;

      void          Stop();
      virtual void  EventLoop();

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected: 

      int           DoPoll(int timeout=-1);
      void          DoCall(void);

    protected: 

      struct PollDsc {
        pollhdl_t   fHandler;
        int         fFd;
        short       fEvents;
        PollDsc(pollhdl_t hdl,int fd,short evts) :
          fHandler(hdl),fFd(fd),fEvents(evts)  {}
      };

      bool          fLoopActive;
      bool          fUpdatePoll;
      boost::mutex  fPollDscMutex;
      std::vector<PollDsc>   fPollDsc;
      std::vector<pollfd>    fPollFd;
      std::vector<pollhdl_t> fPollHdl;
      size_t        fTraceLevel;            //!< trace level
      boost::shared_ptr<RlogFile>  fspLog;  //!< log file ptr
};
  
} // end namespace Retro

#include "ReventLoop.ipp"

#endif
