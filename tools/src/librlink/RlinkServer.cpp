// $Id: RlinkServer.cpp 1185 2019-07-12 17:29:12Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-15  1164   2.2.11 adapt to new ReventFd API
// 2019-04-07  1127   2.2.10 trace now with timestamp and selective
// 2019-02-23  1114   2.2.9  use std::bind instead of lambda
// 2018-12-17  1088   2.2.8  use std::lock_guard, std::thread instead of boost
// 2018-12-15  1083   2.2.7  for std::function setups: use rval ref and move
// 2018-12-14  1081   2.2.6  use std::bind instead of boost
// 2018-12-07  1078   2.2.5  use std::shared_ptr instead of boost
// 2018-10-27  1059   2.2.4  coverity fixup (uncaught exception in dtor)
// 2017-04-07   868   2.2.3  Dump(): add detail arg
// 2015-06-05   686   2.2.2  BUGFIX: CallAttnHandler(): fix race in hnext
// 2015-04-04   662   2.2.1  BUGFIX: fix race in Stop(), use UnStop()
// 2015-01-10   632   2.2    Exec() without emsg now void, will throw
// 2014-12-30   625   2.1    adopt to Rlink V4 attn logic
// 2014-12-21   617   2.0.1  use kStat_M_RbTout for rbus timeout
// 2014-12-11   611   2.0    re-organize for rlink v4
// 2013-05-01   513   1.0.2  fTraceLevel now uint32_t
// 2013-04-21   509   1.0.1  add Resume(), reorganize server start handling
// 2013-03-06   495   1.0    Initial version
// 2013-01-12   474   0.5    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of RlinkServer.
*/

#include <unistd.h>

#include <functional>

#include "librtools/Rexception.hpp"
#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"
#include "librtools/Rtools.hpp"

#include "RlinkServer.hpp"

using namespace std;
using namespace std::placeholders;

/*!
  \class Retro::RlinkServer
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkServer::RlinkServer()
  : fspConn(),
    fContext(),
    fAttnDsc(),
    fActnList(),
    fWakeupEvent("RlinkServer::fWakeupEvent."),
    fELoop(this),
    fServerThread(),
    fAttnPatt(0),
    fAttnNotiPatt(0),
    fTraceLevel(0),
    fStats()
{
  fContext.SetStatus(0, RlinkCommand::kStat_M_RbTout |
                        RlinkCommand::kStat_M_RbNak  |
                        RlinkCommand::kStat_M_RbErr);

  fELoop.AddPollHandler(bind(&RlinkServer::WakeupHandler, this, _1), 
                        fWakeupEvent.Fd(), POLLIN);

  // Statistic setup
  fStats.Define(kStatNEloopWait,"NEloopWait","event loop turns (wait)");
  fStats.Define(kStatNEloopPoll,"NEloopPoll","event loop turns (poll)");
  fStats.Define(kStatNWakeupEvt,"NWakeupEvt","Wakeup events");
  fStats.Define(kStatNRlinkEvt, "NRlinkEvt", "Rlink data events");
  fStats.Define(kStatNAttnHdl  ,"NAttnHdl"  ,"Attn handler calls");
  fStats.Define(kStatNAttnNoti ,"NAttnNoti" ,"Attn notifies processed");
  fStats.Define(kStatNAttnHarv ,"NAttnHarv" ,"Attn handler restarts");
  fStats.Define(kStatNAttn00,   "NAttn00",   "Attn bit  0 set");
  fStats.Define(kStatNAttn01,   "NAttn01",   "Attn bit  1 set");
  fStats.Define(kStatNAttn02,   "NAttn02",   "Attn bit  2 set");
  fStats.Define(kStatNAttn03,   "NAttn03",   "Attn bit  3 set");
  fStats.Define(kStatNAttn04,   "NAttn04",   "Attn bit  4 set");
  fStats.Define(kStatNAttn05,   "NAttn05",   "Attn bit  5 set");
  fStats.Define(kStatNAttn06,   "NAttn06",   "Attn bit  6 set");
  fStats.Define(kStatNAttn07,   "NAttn07",   "Attn bit  7 set");
  fStats.Define(kStatNAttn08,   "NAttn08",   "Attn bit  8 set");
  fStats.Define(kStatNAttn09,   "NAttn09",   "Attn bit  9 set");
  fStats.Define(kStatNAttn10,   "NAttn10",   "Attn bit 10 set");
  fStats.Define(kStatNAttn11,   "NAttn11",   "Attn bit 11 set");
  fStats.Define(kStatNAttn12,   "NAttn12",   "Attn bit 12 set");
  fStats.Define(kStatNAttn13,   "NAttn13",   "Attn bit 13 set");
  fStats.Define(kStatNAttn14,   "NAttn14",   "Attn bit 14 set");
  fStats.Define(kStatNAttn15,   "NAttn15",   "Attn bit 15 set");
}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkServer::~RlinkServer()
{
  Rtools::Catch2Cerr(__func__, [this](){ Stop(); } );
  if (fspConn) fspConn->SetServer(0);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::SetConnect(const std::shared_ptr<RlinkConnect>& spconn)
{
  if (!fspConn && !spconn) return;          // allow 0 = 0 ...
  if (fspConn)
    throw Rexception("RlinkServer::SetConnect()",
                     "Bad state: fspConn already set");
  if (!spconn)
    throw Rexception("RlinkServer::SetConnect()", "Bad args: spconn==0");
  
  fspConn = spconn;
  fELoop.SetLogFile(fspConn->LogFileSPtr());
  fspConn->SetServer(this);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::AddAttnHandler(attnhdl_t&& attnhdl, uint16_t mask,
                                 void* cdata)
{
  if (mask == 0)
    throw Rexception("RlinkServer::AddAttnHandler()", "Bad args: mask == 0");

  lock_guard<RlinkConnect> lock(*fspConn);

  AttnId id(mask, cdata);
  for (size_t i=0; i<fAttnDsc.size(); i++) {
    if (fAttnDsc[i].fId == id) {
      throw Rexception("RlinkServer::AddAttnHandler()", 
                       "Bad args: duplicate handler");
    }
  }
  fAttnDsc.emplace_back(move(attnhdl), id);

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::GetAttnInfo(AttnArgs& args, RlinkCommandList& clist)
{
  RlinkCommand& cmd0 = clist[0];
  if (cmd0.Command() != RlinkCommand::kCmdAttn)
    throw Rexception("RlinkServer::GetAttnInfo", "clist did't start with attn");

  Exec(clist);

  args.fAttnHarvest = cmd0.Data();
  args.fHarvestDone = true;

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::GetAttnInfo(AttnArgs& args)
{
  RlinkCommandList clist;
  clist.AddAttn();
  GetAttnInfo(args, clist);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::RemoveAttnHandler(uint16_t mask, void* cdata)
{
  lock_guard<RlinkConnect> lock(*fspConn);

  AttnId id(mask, cdata);
  for (size_t i=0; i<fAttnDsc.size(); i++) {
    if (fAttnDsc[i].fId == id) {
      fAttnDsc.erase(fAttnDsc.begin()+i);
      return;
    }
  }

  throw Rexception("RlinkServer::RemoveAttnHandler()", 
                   "Bad args: unknown handler");
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::QueueAction(actnhdl_t&& actnhdl)
{
  lock_guard<RlinkConnect> lock(*fspConn);
  fActnList.push_back(move(actnhdl));
  if (IsActiveOutside()) Wakeup();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
 
void RlinkServer::AddPollHandler(pollhdl_t&& pollhdl, int fd, short events)
{
  lock_guard<RlinkConnect> lock(*fspConn);
  fELoop.AddPollHandler(move(pollhdl), fd, events);
  if (IsActiveOutside()) Wakeup();
  return;
}
 
//------------------------------------------+-----------------------------------
//! FIXME_docs
 
bool RlinkServer::TestPollHandler(int fd, short events)
{
  lock_guard<RlinkConnect> lock(*fspConn);
  return fELoop.TestPollHandler(fd, events);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::RemovePollHandler(int fd, short events, bool nothrow)
{
  lock_guard<RlinkConnect> lock(*fspConn);
  fELoop.RemovePollHandler(fd, events,nothrow);
  if (IsActiveOutside()) Wakeup();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::RemovePollHandler(int fd)
{
  lock_guard<RlinkConnect> lock(*fspConn);
  fELoop.RemovePollHandler(fd);
  if (IsActiveOutside()) Wakeup();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::Start()
{
  StartOrResume(false);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::Stop()
{
  if (!IsActive()) return;
  fELoop.Stop();
  Wakeup();
  fServerThread.join();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::Resume()
{
  StartOrResume(true);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::Wakeup()
{
  fWakeupEvent.Signal();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::SignalAttnNotify(uint16_t apat)
{
  // only called under lock !!
  if (apat & fAttnNotiPatt) {
    RlogMsg lmsg(LogFile(), 'W');
    lmsg << "SignalAttnNotify: redundant notify:"
         << " have=" << RosPrintBvi(fAttnNotiPatt,16)
         << " apat=" << RosPrintBvi(apat,16);
  }
  fAttnNotiPatt |= apat;
  Wakeup();
  return;
}

//------------------------------------------+-----------------------------------
//! Indicates whether server is active.
/*!
  \returns \c true if server active.
 */

bool RlinkServer::IsActive() const
{
  return fServerThread.joinable();
}

//------------------------------------------+-----------------------------------
//! Indicates whether server is active and caller is inside server thread.
/*!
  \returns \c true if server active and method is called from server thread.
 */

bool RlinkServer::IsActiveInside() const
{
  return IsActive() && this_thread::get_id() == fServerThread.get_id();
}

//------------------------------------------+-----------------------------------
//! Indicates whether server is active and caller is outside server thread.
/*!
  \returns \c true if server active and method is called from a thread
           other than the server thread.
 */

bool RlinkServer::IsActiveOutside() const
{
  return IsActive() && this_thread::get_id() != fServerThread.get_id();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::SetTraceLevel(uint32_t level)
{
  fTraceLevel = level;
  fELoop.SetTraceLevel(level);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::Print(std::ostream& os) const
{
  os << "RlinkServer::Print(std::ostream& os)" << endl;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::Dump(std::ostream& os, int ind, const char* text,
                       int detail) const
{
  // FIXME_code: is that thread safe ??? fActnList.size() ???
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkServer @ " << this << endl;
  os << bl << "  fspConn:         " <<  fspConn << endl;

  os << bl << "  fAttnDsc:        " << endl;
  for (size_t i=0; i<fAttnDsc.size(); i++) 
    os << bl << "    [" << RosPrintf(i,"d",3) << "]: "
       << RosPrintBvi(fAttnDsc[i].fId.fMask,16)
       << ", " << fAttnDsc[i].fId.fCdata << endl;
  os << bl << "  fActnList.size:  " << fActnList.size() << endl;
  os << bl << "  fWakeupEvent:    " << fWakeupEvent.Fd() << endl;
  fELoop.Dump(os, ind+2, "fELoop", detail);
  os << bl << "  fServerThread:   " << fServerThread.get_id() << endl;
  os << bl << "  fAttnPatt:       " << RosPrintBvi(fAttnPatt,16) << endl;
  os << bl << "  fAttnNotiPatt:   " << RosPrintBvi(fAttnNotiPatt,16) << endl;
  fStats.Dump(os, ind+2, "fStats: ", detail-1);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::StartOrResume(bool resume)
{
  if (IsActive())
    throw Rexception("RlinkServer::StartOrResume()", 
                     "Bad state: server thread already running");
  if (!fspConn->IsOpen())
    throw Rexception("RlinkServer::StartOrResume()", 
                     "Bad state: RlinkConnect not open");

  lock_guard<RlinkConnect> lock(Connect());
  // enable attn notify send
  RlinkCommandList clist;
  if (!resume) clist.AddAttn();
  clist.AddWreg(RlinkConnect::kRbaddr_RLCNTL, RlinkConnect::kRLCNTL_M_AnEna);
  Exec(clist);

  // setup poll handler for Rlink traffic
  int rlinkfd = fspConn->Port().FdRead();
  if (!fELoop.TestPollHandler(rlinkfd, POLLIN))
    fELoop.AddPollHandler(bind(&RlinkServer::RlinkHandler, this, _1), 
                          rlinkfd, POLLIN);
  
  // and start server thread
  fELoop.UnStop();
  fServerThread = thread([this](){ fELoop.EventLoop(); });

  if (resume) {
    RerrMsg emsg;
    if (!Connect().SndAttn(emsg)) {
      RlogMsg lmsg(LogFile(), 'E');
      lmsg << "attn send for server resume failed:" << emsg;
    }
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::CallAttnHandler()
{
  fStats.Inc(kStatNAttnHdl);
  if (fTraceLevel > 1) {
    RlogMsg lmsg(LogFile(),'I');
    lmsg << "attnhdl-beg: patt=" << RosPrintBvi(fAttnPatt,8);
  }

  // if notifier pending, transfer it to current attn pattern
  if (fAttnNotiPatt) {
    lock_guard<RlinkConnect> lock(*fspConn);
    fStats.Inc(kStatNAttnNoti);
    if (fTraceLevel > 1) {
      RlogMsg lmsg(LogFile(),'I');
      lmsg << "attnhdl-add: patt=" << RosPrintBvi(fAttnPatt,8)
           << " noti=" << RosPrintBvi(fAttnNotiPatt,8);
    }
    fAttnPatt |= fAttnNotiPatt;    
    fAttnNotiPatt = 0;
  }

  // do stats for pending attentions
  for (size_t i=0; i<16; i++) {
    if (fAttnPatt & (uint16_t(1)<<i)) fStats.Inc(kStatNAttn00+i);
  }

  // now call handlers, multiple handlers may be called for one attn bit
  uint16_t hnext = 0;
  uint16_t hdone = 0;
  for (size_t i=0; i<fAttnDsc.size(); i++) {
    uint16_t hmatch = fAttnPatt & fAttnDsc[i].fId.fMask;
    if (hmatch) {
      AttnArgs args(fAttnPatt, fAttnDsc[i].fId.fMask);
      lock_guard<RlinkConnect> lock(*fspConn);

      if (fTraceLevel > 0) {
        RlogMsg lmsg(LogFile(),'I');
        lmsg << "attnhdl-bef: patt=" << RosPrintBvi(fAttnPatt,8)
             << " hmat=" << RosPrintBvi(hmatch,8);
     }

      // FIXME_code: return code not used, yet
      fAttnDsc[i].fHandler(args);
      if (!args.fHarvestDone)
        Rexception("RlinkServer::CallAttnHandler()",
                   "Handler didn't set fHarvestDone");

      uint16_t hnew = args.fAttnHarvest & ~fAttnDsc[i].fId.fMask;
      hnext |=  hnew;
      hnext &= ~hmatch;      // FIXME_code: this is a patch
                             //   works for single lam handlers only
                             //   ok for now, but will not work in general !!
      hdone |=  hmatch;

      if (fTraceLevel > 1) {
        RlogMsg lmsg(LogFile(),'I');
        lmsg << "attnhdl-aft: patt=" << RosPrintBvi(fAttnPatt,8)
             << " done=" << RosPrintBvi(hdone,8)
             << " next=" << RosPrintBvi(hnext,8);
      }

    }
  }
  fAttnPatt &= ~hdone;                      // clear handled bits

  // if there are any unhandled attenions, do default handling which will
  // ensure that attention harvest is done
  if (fAttnPatt) {
    AttnArgs args(fAttnPatt, fAttnPatt);
    GetAttnInfo(args);
    hnext |= args.fAttnHarvest & ~fAttnPatt;
    if (fTraceLevel > 0) {
      RlogMsg lmsg(LogFile(), 'I');
      lmsg << "eloop: unhandled attn, mask="
           << RosPrintBvi(fAttnPatt,16) << endl;
    }
  }
  
  // finally replace current attn pattern by the attentions found during
  // harvest and not yet handled
  fAttnPatt = hnext;
  if (fAttnPatt) fStats.Inc(kStatNAttnHarv);

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServer::CallActnHandler()
{
  if (!ActnPending()) return;

  // call first action
  lock_guard<RlinkConnect> lock(*fspConn);

  int irc = fActnList.front()();

  // if irc>0 requeue to end, otherwise drop
  if (irc > 0) {
    fActnList.splice(fActnList.end(), fActnList, fActnList.begin());
  } else {
    fActnList.pop_front();
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RlinkServer::WakeupHandler(const pollfd& pfd)
{
  fStats.Inc(kStatNWakeupEvt);

  // bail-out and cancel handler if poll returns an error event
  if (pfd.revents & (~pfd.events)) return -1;

  fWakeupEvent.Wait();                      // read event
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RlinkServer::RlinkHandler(const pollfd& pfd)
{
  fStats.Inc(kStatNRlinkEvt);

  // bail-out and cancel handler if poll returns an error event
  if (pfd.revents & (~pfd.events)) return -1;

  fspConn->HandleUnsolicitedData();
  return 0;
}

} // end namespace Retro
