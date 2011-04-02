// $Id: RlinkConnect.cpp 375 2011-04-02 07:56:47Z mueller $
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
// 2011-04-02   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkConnect.cpp 375 2011-04-02 07:56:47Z mueller $
  \brief   Implemenation of RlinkConnect.
*/

#include <iostream>

#include <stdexcept>

#include "RlinkConnect.hpp"
#include "RlinkPortFactory.hpp"

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::RlinkConnect
  \brief FIXME_docs
*/

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkConnect::RlinkConnect()
  : fpPort(0),
    fTxPkt(),
    fRxPkt(),
    fAddrMap(),
    fStats(),
    fLogOpts(),
    fLogFile(&cout)
{
  for (size_t i=0; i<8; i++) fSeqNumber[i] = 0;
  
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
  delete fpPort;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::Open(const std::string& name, RerrMsg& emsg)
{
  if (fpPort) Close();

  fpPort = RlinkPortFactory::Open(name, emsg);
  if (!fpPort) return false;

  fpPort->SetLogFile(&fLogFile);
  fpPort->SetTraceLevel(fLogOpts.tracelevel);
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkConnect::Close()
{
  if (!fpPort)
    throw logic_error("RlinkConnect::PortClose(): no port connected");

  if (fpPort->UrlFindOpt("keep")) {
    RerrMsg emsg;
    fTxPkt.SndKeep(fpPort, emsg);
  }

  delete fpPort;
  fpPort = 0;
    
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::Exec(RlinkCommandList& clist, RerrMsg& emsg)
{
  if (clist.Size() == 0)
    throw invalid_argument("RlinkConnect::Exec(): clist empty");
  if (! IsOpen())
    throw logic_error("RlinkConnect::Exec(): port not open");

  fStats.Inc(kStatNExec);

  size_t ibeg = 0;
  size_t size = clist.Size();

  for (size_t i=0; i<size; i++) {
    RlinkCommand& cmd = clist[i];
   if (!cmd.TestFlagAny(RlinkCommand::kFlagInit))
      throw invalid_argument("RlinkConnect::Exec(): command not initialized");
    if (cmd.Command() > RlinkCommand::kCmdInit)
      throw invalid_argument("RlinkConnect::Exec(): invalid command code");
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
    bool rc = ExecPart(clist, ibeg, iend, emsg);
    if (!rc) return rc;
    ibeg = iend+1;
  }

  bool checkseen = false;
  bool errorseen = false;

  for (size_t i=0; i<size; i++) {
    RlinkCommand& cmd = clist[i];
    
    checkseen |= cmd.TestFlagAny(RlinkCommand::kFlagChkStat | 
                                 RlinkCommand::kFlagChkData);
    errorseen |= cmd.TestFlagAny(RlinkCommand::kFlagErrNak | 
                                 RlinkCommand::kFlagErrMiss |
                                 RlinkCommand::kFlagErrCmd |
                                 RlinkCommand::kFlagErrCrc);
  }

  size_t loglevel = 3;
  if (checkseen) loglevel = 2;
  if (errorseen) loglevel = 1;
  if (loglevel <= fLogOpts.printlevel) 
    clist.Print(fLogFile(), &AddrMap(), fLogOpts.baseaddr, fLogOpts.basedata,
                fLogOpts.basestat);
  if (loglevel <= fLogOpts.dumplevel) 
    clist.Dump(fLogFile(), 0);

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::ExecPart(RlinkCommandList& clist, size_t ibeg, size_t iend,
                            RerrMsg& emsg)
{
  if (ibeg<0 || ibeg>iend || iend>=clist.Size())
    throw invalid_argument("RlinkConnect::ExecPart(): ibeg or iend invalid");
  if (!IsOpen())
    throw logic_error("RlinkConnect::ExecPart(): port not open");

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
        throw logic_error("RlinkConnect::Exec(): invalid command");
    }

    fTxPkt.PutCrc();
    cmd.SetFlagBit(RlinkCommand::kFlagSend);
    nrcvtot += cmd.RcvSize();
  }

  clist[ibeg].SetFlagBit(RlinkCommand::kFlagPktBeg);
  clist[iend].SetFlagBit(RlinkCommand::kFlagPktEnd);

  // FIXME_code: handle send fail properly;
  if (!fTxPkt.SndPacket(fpPort, emsg)) return false;
  fStats.Inc(kStatNTxPktByt, double(fTxPkt.PktSize()));
  fStats.Inc(kStatNTxEsc   , double(fTxPkt.Nesc()));

  fRxPkt.Init();
  // FIXME_code: handle timeout properly; parametrize timeout
  if (!fRxPkt.RcvPacket(fpPort, nrcvtot, 1.0, emsg)) return false;
  fStats.Inc(kStatNRxPktByt, double(fRxPkt.PktSize()));
  fStats.Inc(kStatNRxEsc   , double(fRxPkt.Nesc()));
  fStats.Inc(kStatNRxAttn  , double(fRxPkt.Nattn()));
  fStats.Inc(kStatNRxIdle  , double(fRxPkt.Nidle()));
  fStats.Inc(kStatNRxDrop  , double(fRxPkt.Ndrop()));

  size_t ncmd = 0;

  for (size_t i=ibeg; i<=iend; i++) {
    RlinkCommand& cmd = clist[i];
    uint8_t   ccode = cmd.Command();
    size_t    ndata = cmd.BlockSize();
    uint16_t* pdata = cmd.BlockPointer();

    if (!fRxPkt.CheckSize(cmd.RcvSize())) {   // not enough data for cmd
      cmd.SetFlagBit(RlinkCommand::kFlagErrMiss);
      break;
    }
    
    if (fRxPkt.Get8WithCrc() != cmd.Request()) { // command mismatch
      cmd.SetFlagBit(RlinkCommand::kFlagErrCmd);
      break;
    }

    // check length mismatch in rblk here (simpler than multi-level break)
    if (ccode == RlinkCommand::kCmdRblk) {
      if (fRxPkt.Get8WithCrc() != (uint8_t)(ndata-1)) {  // length mismatch
        cmd.SetFlagBit(RlinkCommand::kFlagErrCmd);
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
    }

    cmd.SetStatus(fRxPkt.Get8WithCrc());
    if (!fRxPkt.CheckCrc()) {                 // crc mismatch
      cmd.SetFlagBit(RlinkCommand::kFlagErrCrc);
      //fStats.Inc(kStatNRxCcrc);
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

    if (cmd.Expect()) {
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
    }

  }

  // FIXME_code: add proper error handling...
  if (ncmd != iend-ibeg+1) {
    return false;
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

double RlinkConnect::WaitAttn(double timeout, RerrMsg& emsg)
{
  double rval = fRxPkt.WaitAttn(fpPort, timeout, emsg);
  fStats.Inc(kStatNRxAttn  , double(fRxPkt.Nattn()));
  fStats.Inc(kStatNRxIdle  , double(fRxPkt.Nidle()));
  fStats.Inc(kStatNRxDrop  , double(fRxPkt.Ndrop()));  
  return rval;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::SndOob(uint16_t addr, uint16_t data, RerrMsg& emsg)
{
  fStats.Inc(kStatNSndOob);
  return fTxPkt.SndOob(fpPort, addr, data, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkConnect::LogOpen(const std::string& name)
{
  if (!fLogFile.Open(name)) {
    fLogFile.UseStream(&cout);
    return false;
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkConnect::LogUseStream(std::ostream* pstr)
{
  fLogFile.UseStream(pstr);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkConnect::SetLogOpts(const LogOpts& opts)
{
  if (opts.baseaddr!=2 && opts.baseaddr!=8 && opts.baseaddr!=16)
    throw invalid_argument("RlinkConnect::SetLogOpts(): baseaddr != 2,8,16");
  if (opts.basedata!=2 && opts.basedata!=8 && opts.basedata!=16)
    throw invalid_argument("RlinkConnect::SetLogOpts(): basedata != 2,8,16");
  if (opts.basestat!=2 && opts.basestat!=8 && opts.basestat!=16)
    throw invalid_argument("RlinkConnect::SetLogOpts(): basestat != 2,8,16");

  fLogOpts = opts;
  if (fpPort) fpPort->SetTraceLevel(opts.tracelevel);
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
    os << bl << "  fpPort:          " <<  fpPort << endl;
  }

  os << bl << "  fSeqNumber:      ";
  for (size_t i=0; i<8; i++) os << RosPrintBvi(fSeqNumber[i],16) << " ";
  os << endl;
  
  fTxPkt.Dump(os, ind+2, "fTxPkt: ");
  fRxPkt.Dump(os, ind+2, "fRxPkt: ");
  fAddrMap.Dump(os, ind+2, "fAddrMap: ");
  fStats.Dump(os, ind+2, "fStats: ");
  return;
}

//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_RlinkConnect_NoInline))
#define inline
#include "RlinkConnect.ipp"
#undef  inline
#endif
