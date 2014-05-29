// $Id: RlinkConnect.cpp 521 2013-05-20 22:16:45Z mueller $
//
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-04-21   509   1.3.2  add SndAttn() method
// 2013-03-01   493   1.3.1  add Server(Active..|SignalAttn)() methods
// 2013-02-23   492   1.3    use scoped_ptr for Port; Close allways allowed
//                           use RlinkContext, add Context(), Exec(..., cntx)
// 2013-02-22   491   1.2    use new RlogFile/RlogMsg interfaces
// 2013-02-03   481   1.1.2  use Rexception
// 2013-01-13   474   1.1.1  add PollAttn() method
// 2011-04-25   380   1.1    use boost::(mutex&lock), implement Lockable IF
// 2011-04-22   379   1.0.1  add Lock(), Unlock(), lock connect in Exec()
// 2011-04-02   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkConnect.cpp 521 2013-05-20 22:16:45Z mueller $
  \brief   Implemenation of RlinkConnect.
*/

#include <iostream>

#include "boost/thread/locks.hpp"

#include "RlinkPortFactory.hpp"
#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/Rtools.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"
#include "RlinkServer.hpp"

#include "RlinkConnect.hpp"

using namespace std;

/*!
  \class Retro::RlinkConnect
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkConnect::RlinkConnect()
  : fpPort(),
    fpServ(0),
    fTxPkt(),
    fRxPkt(),
    fContext(),
    fAddrMap(),
    fStats(),
    fLogOpts(),
    fspLog(new RlogFile(&cout, "<cout>")),
    fConnectMutex()
{
  for (size_t i=0; i<8; i++) fSeqNumber[i] = 0;
 
  // Statistic setup
  fStats.Define(kStatNExec,     "NExec",     "Exec() calls");
  fStats.Define(kStatNSplitVol, "NSplitVol", "clist splits: Volatile");
  fStats.Define(kStatNExecPart, "NExecPart", "ExecPart() calls");
  fStats.Define(kStatNCmd,      "NCmd",      "commands executed");
  fStats.Define(kStatNRreg,     "NRreg",     "rreg commands");
  fStats.Define(kStatNRblk,     "NRblk",     "rblk commands");
  fStats.Define(kStatNWreg,     "NWreg",     "wreg commands");
  fStats.Define(kStatNWblk,     "NWblk",     "wblk commands");
  fStats.Define(kStatNStat,     "NStat",     "stat commands");
  fStats.Define(kStatNAttn,     "NAttn",     "attn commands");
  fStats.Define(kStatNInit,     "NInit",     "init commands");
  fStats.Define(kStatNRblkWord, "NRblkWord", "words rcvd with rblk");
  fStats.Define(kStatNWblkWord, "NWblkWord", "words send with wblk");
  fStats.Define(kStatNTxPktByt, "NTxPktByt", "Tx packet bytes send");
  fStats.Define(kStatNTxEsc,    "NTxEsc",    "Tx escapes");
  fStats.Define(kStatNRxPktByt, "NRxPktByt", "Rx packet bytes rcvd");
  fStats.Define(kStatNRxEsc,    "NRxEsc",    "Rx escapes");
  fStats.Define(kStatNRxAttn,   "NRxAttn",   "Rx ATTN commas seen");
  fStats.Define(kStatNRxIdle,   "NRxIdle",   "Rx IDLE commas seen");
  fStats.Define(kStatNRxDrop,   "NRxDrop",   "Rx bytes droped");
  fStats.Define(kStatNExpData,  "NExpData",  "Expect() for data defined");
  fStats.Define(kStatNExpStat,  "NExpStat",  "Expect() for stat defined");
  fStats.Define(kStatNChkData,  "NChkData",  "expect data failed");
  fStats.Define(kStatNChkStat,  "NChkStat",  "expect stat failed");
  fStats.Define(kStatNSndOob,   "NSndOob",   "SndOob() calls");
}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkConnect::~RlinkConnect()
{
  Close();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::Open(const std::string& name, RerrMsg& emsg)
{
  Close();

  fpPort.reset(RlinkPortFactory::Open(name, emsg));
  if (!fpPort) return false;

  fpPort->SetLogFile(fspLog);
  fpPort->SetTraceLevel(fLogOpts.tracelevel);
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkConnect::Close()
{
  if (!fpPort) return;

  if (fpServ) fpServ->Stop();               // stop server in case still running

  if (fpPort->Url().FindOpt("keep")) {
    RerrMsg emsg;
    fTxPkt.SndKeep(fpPort.get(), emsg);
  }

  fpPort.reset();
    
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::ServerActive() const
{
  return fpServ && fpServ->IsActive();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::ServerActiveInside() const
{
  return fpServ && fpServ->IsActiveInside();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::ServerActiveOutside() const
{
  return fpServ && fpServ->IsActiveOutside();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkConnect::ServerSignalAttn()
{
  if (fpServ) fpServ->SignalAttn();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkConnect::lock()
{
  fConnectMutex.lock();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::try_lock()
{
  return fConnectMutex.try_lock();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkConnect::unlock()
{
  fConnectMutex.unlock();
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::Exec(RlinkCommandList& clist, RlinkContext& cntx, 
                        RerrMsg& emsg)
{  
  if (clist.Size() == 0)
    throw Rexception("RlinkConnect::Exec()", "Bad state: clist empty");
  if (! IsOpen())
    throw Rexception("RlinkConnect::Exec()", "Bad state: port not open");

  boost::lock_guard<RlinkConnect> lock(*this);

  fStats.Inc(kStatNExec);

  size_t ibeg = 0;
  size_t size = clist.Size();

  for (size_t i=0; i<size; i++) {
    RlinkCommand& cmd = clist[i];
   if (!cmd.TestFlagAny(RlinkCommand::kFlagInit))
     throw Rexception("RlinkConnect::Exec()", 
                      "BugCheck: command not initialized");
    if (cmd.Command() > RlinkCommand::kCmdInit)
      throw Rexception("RlinkConnect::Exec()", 
                       "BugCheck: invalid command code");
    // trap attn command when server running and outside server thread
    if (cmd.Command() == RlinkCommand::kCmdAttn && ServerActiveOutside())
      throw Rexception("RlinkConnect::Exec()", 
                       "attn command not allowed outside avtice server");
    
    cmd.ClearFlagBit(RlinkCommand::kFlagSend   | RlinkCommand::kFlagDone |
                     RlinkCommand::kFlagPktBeg | RlinkCommand::kFlagPktEnd |
                     RlinkCommand::kFlagRecov  | RlinkCommand::kFlagResend |
                     RlinkCommand::kFlagErrNak | RlinkCommand::kFlagErrMiss |
                     RlinkCommand::kFlagErrCmd | RlinkCommand::kFlagErrCrc);
  }
  
  while (ibeg < size) {
    size_t iend = ibeg;
    for (size_t i=ibeg; i<size; i++) {
      iend = i;
      if (clist[i].TestFlagAll(RlinkCommand::kFlagVol)) {
        fStats.Inc(kStatNSplitVol);
        break;
      }
    }
    bool rc = ExecPart(clist, ibeg, iend, emsg, cntx);
    if (!rc) return rc;
    ibeg = iend+1;
  }

  bool checkseen = false;
  bool errorseen = false;

  for (size_t i=0; i<size; i++) {
    RlinkCommand& cmd = clist[i];
    
    bool checkfound = cmd.TestFlagAny(RlinkCommand::kFlagChkStat | 
                                      RlinkCommand::kFlagChkData);
    bool errorfound = cmd.TestFlagAny(RlinkCommand::kFlagErrNak | 
                                      RlinkCommand::kFlagErrMiss |
                                      RlinkCommand::kFlagErrCmd |
                                      RlinkCommand::kFlagErrCrc);
    checkseen |= checkfound;
    errorseen |= errorfound;
    if (checkfound | errorfound) cntx.IncErrorCount();
  }

  size_t loglevel = 3;
  if (checkseen) loglevel = 2;
  if (errorseen) loglevel = 1;
  if (loglevel <= fLogOpts.printlevel) {
    RlogMsg lmsg(*fspLog);
    clist.Print(lmsg(), cntx, &AddrMap(), fLogOpts.baseaddr, fLogOpts.basedata,
                fLogOpts.basestat);
  }
  if (loglevel <= fLogOpts.dumplevel) {
    RlogMsg lmsg(*fspLog);
    clist.Dump(lmsg(), 0);
  }
  
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::Exec(RlinkCommandList& clist, RlinkContext& cntx)
{
  RerrMsg emsg;
  bool rc = Exec(clist, cntx, emsg);
  if (!rc) {
    RlogMsg lmsg(*fspLog, 'E');
    lmsg << emsg << endl;
    lmsg << "Dump of failed clist:" << endl;
    clist.Dump(lmsg(), 0);    
  }
  return rc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::ExecPart(RlinkCommandList& clist, size_t ibeg, size_t iend,
                            RerrMsg& emsg, RlinkContext& cntx)
{
  if (ibeg<0 || ibeg>iend || iend>=clist.Size())
    throw Rexception("RlinkConnect::ExecPart()",
                     "Bad args: ibeg or iend invalid");
  if (!IsOpen())
    throw Rexception("RlinkConnect::ExecPart()","Bad state: port not open");

  fStats.Inc(kStatNExecPart);

  size_t nrcvtot = 0;
  fTxPkt.Init();

  for (size_t i=ibeg; i<=iend; i++) {
    RlinkCommand& cmd = clist[i];
    uint8_t   ccode = cmd.Command();
    size_t    ndata = cmd.BlockSize();
    uint16_t* pdata = cmd.BlockPointer();

    fStats.Inc(kStatNCmd);

    cmd.SetSeqNumber(fSeqNumber[ccode]++);
    cmd.ClearFlagBit(RlinkCommand::kFlagPktBeg | RlinkCommand::kFlagPktEnd);

    fTxPkt.PutWithCrc(cmd.Request());

    switch(ccode) {
      case RlinkCommand::kCmdRreg:
        fStats.Inc(kStatNRreg);
        cmd.SetRcvSize(1+2+1+1);            // rcv: cmd+data+stat+crc
        fTxPkt.PutWithCrc((uint8_t)cmd.Address());
        break;

      case RlinkCommand::kCmdRblk:
        fStats.Inc(kStatNRblk);
        fStats.Inc(kStatNRblkWord, (double) ndata);
        cmd.SetRcvSize(1+1+2*ndata+1+1);    // rcv: cmd+nblk+n*data+stat+crc
        fTxPkt.PutWithCrc((uint8_t)cmd.Address());
        fTxPkt.PutWithCrc((uint8_t)(ndata-1));
        break;

      case RlinkCommand::kCmdWreg:
        fStats.Inc(kStatNWreg);
        cmd.SetRcvSize(1+1+1);              // rcv: cmd+stat+crc
        fTxPkt.PutWithCrc((uint8_t)cmd.Address());
        fTxPkt.PutWithCrc(cmd.Data());
        break;

      case RlinkCommand::kCmdWblk:
        fStats.Inc(kStatNWblk);
        fStats.Inc(kStatNWblkWord, (double) ndata);
        cmd.SetRcvSize(1+1+1);              // rcv: cmd+stat+crc
        fTxPkt.PutWithCrc((uint8_t)cmd.Address());
        fTxPkt.PutWithCrc((uint8_t)(ndata-1));
        fTxPkt.PutCrc();
        for (size_t j=0; j<ndata; j++) fTxPkt.PutWithCrc(*pdata++);
        break;

      case RlinkCommand::kCmdStat:
        fStats.Inc(kStatNStat);
        cmd.SetRcvSize(1+1+2+1+1);          // rcv: cmd+ccmd+data+stat+crc
        break;
      case RlinkCommand::kCmdAttn:
        fStats.Inc(kStatNAttn);
        cmd.SetRcvSize(1+2+1+1);            // rcv: cmd+data+stat+crc
        break;

      case RlinkCommand::kCmdInit:
        fStats.Inc(kStatNInit);
        cmd.SetRcvSize(1+1+1);              // rcv: cmd+stat+crc
        fTxPkt.PutWithCrc((uint8_t)cmd.Address());
        fTxPkt.PutWithCrc(cmd.Data());
        break;

      default:
        throw Rexception("RlinkConnect::Exec()", "BugCheck: invalid command");
    }

    fTxPkt.PutCrc();
    cmd.SetFlagBit(RlinkCommand::kFlagSend);
    nrcvtot += cmd.RcvSize();
  }

  clist[ibeg].SetFlagBit(RlinkCommand::kFlagPktBeg);
  clist[iend].SetFlagBit(RlinkCommand::kFlagPktEnd);

  // FIXME_code: handle send fail properly;
  if (!fTxPkt.SndPacket(fpPort.get(), emsg)) return false;
  fStats.Inc(kStatNTxPktByt, double(fTxPkt.PktSize()));
  fStats.Inc(kStatNTxEsc   , double(fTxPkt.Nesc()));

  fRxPkt.Init();
  // FIXME_code: parametrize timeout
  if (!fRxPkt.RcvPacket(fpPort.get(), nrcvtot, 5.0, emsg)) return false;

  // FIXME_code: handle timeout properly
  if (fRxPkt.TestFlag(RlinkPacketBuf::kFlagTout)) {
    emsg.Init("RlinkConnect::ExecPart", "timeout from RlinkPacketBuf");
    return false;
  }

  // if attn seen, signal to server
  if (fRxPkt.Nattn()) ServerSignalAttn();

  fStats.Inc(kStatNRxPktByt, double(fRxPkt.PktSize()));
  fStats.Inc(kStatNRxEsc   , double(fRxPkt.Nesc()));
  fStats.Inc(kStatNRxAttn  , double(fRxPkt.Nattn()));
  fStats.Inc(kStatNRxIdle  , double(fRxPkt.Nidle()));
  fStats.Inc(kStatNRxDrop  , double(fRxPkt.Ndrop()));

  size_t ncmd = 0;
  const char* etxt = 0;

  for (size_t i=ibeg; i<=iend; i++) {
    RlinkCommand& cmd = clist[i];
    uint8_t   ccode = cmd.Command();
    size_t    ndata = cmd.BlockSize();
    uint16_t* pdata = cmd.BlockPointer();

    if (!fRxPkt.CheckSize(cmd.RcvSize())) {   // not enough data for cmd
      cmd.SetFlagBit(RlinkCommand::kFlagErrMiss);
      etxt = "FlagErrMiss: not enough data for cmd";
      break;
    }
    
    if (fRxPkt.Get8WithCrc() != cmd.Request()) { // command mismatch
      cmd.SetFlagBit(RlinkCommand::kFlagErrCmd);
      etxt = "FlagErrCmd: command mismatch";
      break;
    }

    // check length mismatch in rblk here (simpler than multi-level break)
    if (ccode == RlinkCommand::kCmdRblk) {
      if (fRxPkt.Get8WithCrc() != (uint8_t)(ndata-1)) {  // length mismatch
        cmd.SetFlagBit(RlinkCommand::kFlagErrCmd);
        etxt = "FlagErrCmd: length mismatch";
        break;
      }
    }

    switch(ccode) {
      case RlinkCommand::kCmdRreg:
        cmd.SetData(fRxPkt.Get16WithCrc());
        break;

      case RlinkCommand::kCmdRblk:
        // length was consumed and tested already before switch()..
        for (size_t j=0; j<ndata; j++) *pdata++ = fRxPkt.Get16WithCrc();
        break;

      case RlinkCommand::kCmdWreg:
      case RlinkCommand::kCmdWblk:
        break;

      case RlinkCommand::kCmdStat:
        cmd.SetStatRequest(fRxPkt.Get8WithCrc());
        cmd.SetData(fRxPkt.Get16WithCrc());
        break;

      case RlinkCommand::kCmdAttn:
        cmd.SetData(fRxPkt.Get16WithCrc());
        break;

      case RlinkCommand::kCmdInit:
        break;
    } // switch(ccode)

    cmd.SetStatus(fRxPkt.Get8WithCrc());
    if (!fRxPkt.CheckCrc()) {                 // crc mismatch
      cmd.SetFlagBit(RlinkCommand::kFlagErrCrc);
      //fStats.Inc(kStatNRxCcrc);
      etxt = "FlagErrCrc: crc mismatch";
      break;
    }

    // FIXME_code: proper wblk dcrc handling...
    if (ccode == RlinkCommand::kCmdWblk) {
      // FIXME_code: check for dcrc flag...
      if (false) {
        //fStats.Inc(kStatNRxDcrc);
        break;
      }
    }

    cmd.SetFlagBit(RlinkCommand::kFlagDone);
    ncmd += 1;

    if (cmd.Expect()) {                     // expect object attached ?
      RlinkCommandExpect& expect = *cmd.Expect();
      if (expect.DataIsChecked() || 
          expect.BlockValue().size()>0) fStats.Inc(kStatNExpData);
      if (expect.StatusIsChecked())     fStats.Inc(kStatNExpStat);

      if (ccode==RlinkCommand::kCmdRreg || ccode==RlinkCommand::kCmdStat ||
          ccode==RlinkCommand::kCmdAttn) {
        if (!expect.DataCheck(cmd.Data())) {
          fStats.Inc(kStatNChkData);
          cmd.SetFlagBit(RlinkCommand::kFlagChkData);
        }
      } else if (ccode==RlinkCommand::kCmdRblk) {
        size_t nerr = expect.BlockCheck(cmd.BlockPointer(), cmd.BlockSize());
        if (nerr != 0) {
          fStats.Inc(kStatNChkData);
          cmd.SetFlagBit(RlinkCommand::kFlagChkData);
        }
      }
      if (!expect.StatusCheck(cmd.Status())) {
        fStats.Inc(kStatNChkStat);
        cmd.SetFlagBit(RlinkCommand::kFlagChkStat);
      }

    } else {                                // no expect, use context
      if (!cntx.StatusCheck(cmd.Status())) {
        fStats.Inc(kStatNChkStat);
        cmd.SetFlagBit(RlinkCommand::kFlagChkStat);
      }
    }

  }

  // FIXME_code: add proper error handling...
  if (ncmd != iend-ibeg+1) {
    if (etxt == 0) etxt = "not all commands processed";
    emsg.Init("RlinkConnect::ExecPart", etxt);
    return false;
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

double RlinkConnect::WaitAttn(double timeout, RerrMsg& emsg)
{
  if (ServerActiveOutside())
    throw Rexception("RlinkConnect::WaitAttn()", 
                     "not allowed outside avtice server");

  double rval = fRxPkt.WaitAttn(fpPort.get(), timeout, emsg);
  fStats.Inc(kStatNRxAttn  , double(fRxPkt.Nattn()));
  fStats.Inc(kStatNRxIdle  , double(fRxPkt.Nidle()));
  fStats.Inc(kStatNRxDrop  , double(fRxPkt.Ndrop()));  
  return rval;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RlinkConnect::PollAttn(RerrMsg& emsg)
{
  if (ServerActiveOutside())
    throw Rexception("RlinkConnect::PollAttn()", 
                     "not allowed outside avtice server");
  
  int rval = fRxPkt.PollAttn(fpPort.get(), emsg);
  fStats.Inc(kStatNRxAttn  , double(fRxPkt.Nattn()));
  fStats.Inc(kStatNRxIdle  , double(fRxPkt.Nidle()));
  fStats.Inc(kStatNRxDrop  , double(fRxPkt.Ndrop()));  
  return rval;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::SndOob(uint16_t addr, uint16_t data, RerrMsg& emsg)
{
  boost::lock_guard<RlinkConnect> lock(*this);
  fStats.Inc(kStatNSndOob);
  return fTxPkt.SndOob(fpPort.get(), addr, data, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::SndAttn(RerrMsg& emsg)
{
  boost::lock_guard<RlinkConnect> lock(*this);
  return fTxPkt.SndAttn(fpPort.get(), emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkConnect::SetLogOpts(const LogOpts& opts)
{
  if (opts.baseaddr!=2 && opts.baseaddr!=8 && opts.baseaddr!=16)
    throw Rexception("RlinkConnect::SetLogOpts()",
                     "Bad args: baseaddr != 2,8,16");
  if (opts.basedata!=2 && opts.basedata!=8 && opts.basedata!=16)
    throw Rexception("RlinkConnect::SetLogOpts()",
                     "Bad args: basedata != 2,8,16");
  if (opts.basestat!=2 && opts.basestat!=8 && opts.basestat!=16)
    throw Rexception("RlinkConnect::SetLogOpts()",
                     "Bad args: basestat != 2,8,16");

  fLogOpts = opts;
  if (fpPort) fpPort->SetTraceLevel(opts.tracelevel);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::LogOpen(const std::string& name)
{
  if (!fspLog->Open(name)) {
    fspLog->UseStream(&cout, "<cout>");
    return false;
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkConnect::LogUseStream(std::ostream* pstr, const std::string& name)
{
  fspLog->UseStream(pstr, name);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkConnect::Print(std::ostream& os) const
{
  os << "RlinkConnect::Print(std::ostream& os)" << endl;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkConnect::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkConnect @ " << this << endl;

  if (fpPort) {
    fpPort->Dump(os, ind+2, "fpPort: ");
  } else {
    os << bl << "  fpPort:          " <<  fpPort.get() << endl;
  }

  os << bl << "  fpServ:          " << fpServ << endl;
  os << bl << "  fSeqNumber:      ";
  for (size_t i=0; i<8; i++) os << RosPrintBvi(fSeqNumber[i],16) << " ";
  os << endl;
  
  fTxPkt.Dump(os, ind+2, "fTxPkt: ");
  fRxPkt.Dump(os, ind+2, "fRxPkt: ");
  fContext.Dump(os, ind+2, "fContext: ");
  fAddrMap.Dump(os, ind+2, "fAddrMap: ");
  fStats.Dump(os, ind+2, "fStats: ");
  os << bl << "  fLogOpts.baseaddr   " << fLogOpts.baseaddr << endl;
  os << bl << "          .basedata   " << fLogOpts.basedata << endl;
  os << bl << "          .basestat   " << fLogOpts.basestat << endl;
  os << bl << "          .printlevel " << fLogOpts.printlevel << endl;
  os << bl << "          .dumplevel  " << fLogOpts.dumplevel << endl;
  os << bl << "          .tracelevel " << fLogOpts.tracelevel << endl;
  fspLog->Dump(os, ind+2, "fspLog: ");
  return;
}

} // end namespace Retro
