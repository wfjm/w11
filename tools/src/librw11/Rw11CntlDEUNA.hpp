// $Id: Rw11CntlDEUNA.hpp 901 2017-05-28 11:26:11Z mueller $
//
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-14   875   0.5    Initial version (minimal functions, 211bsd ready)
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rw11CntlDEUNA.
*/

#ifndef included_Retro_Rw11CntlDEUNA
#define included_Retro_Rw11CntlDEUNA 1

#include <deque>

#include "librtools/Rtime.hpp"
#include "librlink/RtimerFd.hpp"

#include "RethBuf.hpp"

#include "Rw11CntlBase.hpp"
#include "Rw11UnitDEUNA.hpp"

namespace Retro {

  class Rw11CntlDEUNA : public Rw11CntlBase<Rw11UnitDEUNA,1> {
    public:

                    Rw11CntlDEUNA();
                   ~Rw11CntlDEUNA();

      void          Config(const std::string& name, uint16_t base, int lam);

      virtual void  Start();

      virtual void  UnitSetup(size_t ind);

      void          SetType(const std::string& type);
      void          SetMacDefault(const std::string& mac);
      void          SetRxPollTime(const Rtime& time);
      void          SetRxQueLimit(size_t rxqlim);

      std::string   MacDefault() const;
      const Rtime&  RxPollTime() const;
      size_t        RxQueLimit() const;

      bool          Running() const;

      const char*   MnemoPcmd(uint16_t pcmd) const;
      const char*   MnemoFunc(uint16_t func) const;
      const char*   MnemoState(uint16_t state) const;

      bool          RcvCallback(RethBuf::pbuf_t& pbuf);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // some constants (also defined in cpp)
      static const uint16_t kIbaddr = 0174510; //!< DEUNA default address
      static const int      kLam    = 9;       //!< DEUNA default lam 

      static const uint16_t kPR0 = 000;     //!< PR0 reg offset
      static const uint16_t kPR1 = 002;     //!< PR1 reg offset
      static const uint16_t kPR2 = 004;     //!< PR2 reg offset
      static const uint16_t kPR3 = 006;     //!< PR3 reg offset

      static const uint16_t kProbeOff = kPR0; //!< probe address offset (pr0)
      static const bool     kProbeInt = true;  //!< probe int active
      static const bool     kProbeRem = true;  //!< probr rem active

      static const uint16_t kPR0_M_SERI = kWBit15; //!< SERI: status error intr
      static const uint16_t kPR0_M_PCEI = kWBit14; //!< PCEI: port cmd err intr
      static const uint16_t kPR0_M_RXI  = kWBit13; //!< RXI: receive rung intr
      static const uint16_t kPR0_M_TXI  = kWBit12; //!< TXI: transmit rung intr
      static const uint16_t kPR0_M_DNI  = kWBit11; //!< DNI: done intr
      static const uint16_t kPR0_M_RCBI = kWBit10; //!< RCBI: rcv buff unavail 
      static const uint16_t kPR0_M_BUSY = kWBit09; //!< BUSY: command busy
      static const uint16_t kPR0_M_USCI = kWBit08; //!< USCI: unsol state chang
      static const uint16_t kPR0_M_INTR = kWBit07; //!< INTR: intr summary
      static const uint16_t kPR0_M_INTE = kWBit06; //!< INTE: intr enable
      static const uint16_t kPR0_M_RSET = kWBit05; //!< RSET: sw reset
      static const uint16_t kPR0_M_BRST = kWBit04; //!< RSET: breset seen
      static const uint16_t kPR0_M_PCMD = 00017;   //!< PCMD: port command

      static const uint16_t kPR0_V_PCMDBP=    12;   //!< PCMDBP: pcmd busy prot
      static const uint16_t kPR0_B_PCMDBP= 00017;   //!< PCMDBP: pcmd busy prot
      static const uint16_t kPR0_M_PDMDWB= kWBit10; //!< PDMDWB: pdmd while busy
      static const uint16_t kPR0_M_PCWWB = kWBit08; //!< PCWWB: pcmd write w busy

      static const uint16_t kPCMD_NOOP    =   0;   //!< NOOP: noop 
      static const uint16_t kPCMD_GETPCBB =   1;   //!< GETPCBB: get pcb base
      static const uint16_t kPCMD_GETCMD  =   2;   //!< GETCMD: get command 
      static const uint16_t kPCMD_SELFTST =   3;   //!< SELFTST: self test
      static const uint16_t kPCMD_START   =   4;   //!< START: start tx/rx
      static const uint16_t kPCMD_BOOT    =   5;   //!< BOOT: boot
      static const uint16_t kPCMD_PDMD    = 010;   //!< PDMD: poll demand
      static const uint16_t kPCMD_HALT    = 016;   //!< HALT: halt
      static const uint16_t kPCMD_STOP    = 017;   //!< STOP: stop

      static const uint16_t kPR1_M_XPWR = kWBit15; //!< XPWR: transceive pwr fail
      static const uint16_t kPR1_M_ICAB = kWBit14; //!< ICAB: cable fail
      static const uint16_t kPR1_M_PCTO = kWBit07; //!< PCTO: port cmd timeout
      static const uint16_t kPR1_M_DELUA= kWBit04; //!< ID0: 1=DELUA;0=DEUNA  
      static const uint16_t kPR1_M_STATE= 0017;    //!< STATE: port status

      static const uint16_t kSTATE_RESET  =   0;   //!< reset
      static const uint16_t kSTATE_PLOAD  =   1;   //!< primary load
      static const uint16_t kSTATE_READY  =   2;   //!< ready
      static const uint16_t kSTATE_RUN    =   3;   //!< running
      static const uint16_t kSTATE_UHALT  =   5;   //!< unibus halted
      static const uint16_t kSTATE_NHALT  =   6;   //!< ni halted
      static const uint16_t kSTATE_NUHALT =   7;   //!< ni and unibus halted
      static const uint16_t kSTATE_PHALT  =  010;  //!< port halted
      static const uint16_t kSTATE_SLOAD  =  017;  //!< secondary load

      static const uint16_t kPC0_M_FUNC = 0x00ff;  //!< FUNC: function code
      static const uint16_t kPC0_M_MBZ  = 0xff00;  //!< MBZ

      static const uint16_t kFUNC_NOOP   =   0;  //!< NOOP: noop
      static const uint16_t kFUNC_RDPA   =   2;  //!< RDPA: read def MAC 
      static const uint16_t kFUNC_RPA    =   4;  //!< RPA:  read  phys MAC 
      static const uint16_t kFUNC_WPA    =   5;  //!< WPA:  write phys MAC 
      static const uint16_t kFUNC_RMAL   =   6;  //!< RMAL: read  mcast MAC list
      static const uint16_t kFUNC_WMAL   =   7;  //!< RMAL: write mcast MAC list
      static const uint16_t kFUNC_RRF    = 010;  //!< RRF:  read  ring format 
      static const uint16_t kFUNC_WRF    = 011;  //!< WRF:  write ring format 
      static const uint16_t kFUNC_RCTR   = 012;  //!< RCTR: read counters 
      static const uint16_t kFUNC_RCCTR  = 013;  //!< RCCTR: read&clr counters 
      static const uint16_t kFUNC_RMODE  = 014;  //!< RMODE: read  mode 
      static const uint16_t kFUNC_WMODE  = 015;  //!< WMODE: write write 
      static const uint16_t kFUNC_RSTAT  = 016;  //!< RSTAT:  read  status 
      static const uint16_t kFUNC_RCSTAT = 017;  //!< RCSTAT: read&clr status
      static const uint16_t kFUNC_RSID   = 022;  //!< RSID: read system id
      static const uint16_t kFUNC_WSID   = 023;  //!< WSID: write system id

      static const uint16_t kSTAT_M_ERRS = kWBit15;//!< ERRS: error summary
      static const uint16_t kSTAT_M_MERR = kWBit14;//!< MERR: multiple errors
      static const uint16_t kSTAT_M_BABL = kWBit13;//!< BABL: xmit on long(DELUA)
      static const uint16_t kSTAT_M_CERR = kWBit12;//!< CERR: collision test er
      static const uint16_t kSTAT_M_TMOT = kWBit11;//!< TMOT: UNIBUS timeout
      static const uint16_t kSTAT_M_RRNG = kWBit09;//!< RRNG: rx ring error
      static const uint16_t kSTAT_M_TRNG = kWBit08;//!< TRNG: tx ring error
      static const uint16_t kSTAT_M_PTCH = kWBit07;//!< PTCH: ROM patch
      static const uint16_t kSTAT_M_RRAM = kWBit06;//!< RRAM: run from RAM
      static const uint16_t kSTAT_M_RREV = 077;    //!< RREV: ROM version

      static const uint16_t kMODE_M_PROM = kWBit15;//!< PROM: promiscous mode
      static const uint16_t kMODE_M_ENAL = kWBit14;//!< ENAL: ena all mcasts
      static const uint16_t kMODE_M_DRDC = kWBit13;//!< DRDC: dis data chaining
      static const uint16_t kMODE_M_TPAD = kWBit12;//!< TPAD: tx msg padding ena
      static const uint16_t kMODE_M_ECT  = kWBit11;//!< ECT: ena collision test
      static const uint16_t kMODE_M_DMNT = kWBit09;//!< DMNT: dis maint message
      static const uint16_t kMODE_M_INTL = kWBit06;//!< INTL: int loopback(DELUA)
      static const uint16_t kMODE_M_DTCR = kWBit03;//!< DTCR:  dis tx CRC
      static const uint16_t kMODE_M_LOOP = kWBit02;//!< LOOP: int loopback
      static const uint16_t kMODE_M_HDPX = kWBit00;//!< HDPX: half-duplex (DEUNA)
      static const uint16_t kMODE_M_MBZ_DEUNA = 0x05f2; //!< MBZ bit:10,8:4,1
      static const uint16_t kMODE_M_MBZ_DELUA = 0x05b2; //!< MBZ bit:10,8:7,5:4,1

      static const uint16_t kTXR2_M_OWN  = kWBit15; //!< OWN: owned by DEUNA
      static const uint16_t kTXR2_M_ERRS = kWBit14; //!< ERRS: error summary
      static const uint16_t kTXR2_M_MTCH = kWBit13; //!< MTCH: station match
      static const uint16_t kTXR2_M_MORE = kWBit12; //!< MORE: mult retry needed
      static const uint16_t kTXR2_M_ONE  = kWBit11; //!< ONE: one collision
      static const uint16_t kTXR2_M_DEF  = kWBit10; //!< DEF: deferred
      static const uint16_t kTXR2_M_STF  = kWBit09; //!< STF: start of frame 
      static const uint16_t kTXR2_M_ENF  = kWBit08; //!< ENF: end of frame 
      static const uint16_t kTXR2_M_SEGB = 00003;   //!< SEGB: msg of seg base
      static const uint16_t kTXR3_M_BUFL = kWBit15; //!< BUFL: buf length error
      static const uint16_t kTXR3_M_UBTO = kWBit14; //!< UBTO: UNIBUS timeout
      static const uint16_t kTXR3_M_UFLO = kWBit13; //!< UFLO: UNIBUS underflow
      static const uint16_t kTXR3_M_LCOL = kWBit12; //!< LCOL: late collision
      static const uint16_t kTXR3_M_LCAR = kWBit11; //!< LCAR: lost carrier
      static const uint16_t kTXR3_M_RTRY = kWBit10; //!< RTRY: retry failure
      static const uint16_t kTXR3_M_TDR  = 01777;   //!< TDR: TDR value if RTRY=1

      static const uint16_t kRXR2_M_OWN  = kWBit15; //!< OWN: owned by DENUA
      static const uint16_t kRXR2_M_ERRS = kWBit14; //!< ERRS: error summary
      static const uint16_t kRXR2_M_FRAM = kWBit13; //!< FRAM: frame error
      static const uint16_t kRXR2_M_OFLO = kWBit12; //!< OFLO: message overflow
      static const uint16_t kRXR2_M_CRC  = kWBit11; //!< CRC: CRC check error
      static const uint16_t kRXR2_M_STF  = kWBit09; //!< STF: start of frame 
      static const uint16_t kRXR2_M_ENF  = kWBit08; //!< ENF: end of frame 
      static const uint16_t kRXR2_M_SEGB = 000003;  //!< SEGB: msg of seg base
      static const uint16_t kRXR3_M_BUFL = kWBit15; //!< BUFL: buf length error
      static const uint16_t kRXR3_M_UBTO = kWBit14; //!< UBTO: UNIBUS timeout
      static const uint16_t kRXR3_M_NCHN = kWBit13; //!< NCHN: no data chaining
      static const uint16_t kRXR3_M_OVRN = kWBit12; //!< OVRN: overrun error
      static const uint16_t kRXR3_M_MLEN = 07777;   //!< MLEN: message length

      static const uint32_t kUBA_M    = 0x3fffe; //!< bits of even unibus address
      static const uint32_t kUBAODD_M = 0x3ffff; //!< bits of  odd unibus address
      static const uint16_t kDimMcast = 10;   //!< max length Mcast list (MAXMLT)
      static const uint16_t kDimCtrDeuna =  32; //!< DEUNA count words (MAXCTR)
      static const uint16_t kDimCtrDelua =  34; //!< DELUA count words (MAXCTR)
      static const uint16_t kDimCtr      =  34; //!< max MAXCTR
      static const uint16_t kDimPlt      = 100; //!< max MAXPLT

    // statistics counter indices
      enum stats {
        kStatNPcmdNoop = Rw11Cntl::kDimStat,
        kStatNPcmdGetpcbb,
        kStatNPcmdGetcmd,
        kStatNPcmdSelftst,
        kStatNPcmdStart,
        kStatNPcmdPdmd,
        kStatNPcmdStop,
        kStatNPcmdHalt,
        kStatNPcmdRsrvd,
        kStatNPcmdUimpl,
        kStatNPcmdWBPdmd,
        kStatNPcmdWBOther,
        kStatNPdmdRestart,
        kStatNFuncNoop,
        kStatNFuncRdpa,
        kStatNFuncRpa,
        kStatNFuncWpa,
        kStatNFuncRmal,
        kStatNFuncWmal,
        kStatNFuncRrf,
        kStatNFuncWrf,
        kStatNFuncRctr,
        kStatNFuncRcctr,
        kStatNFuncRmode,
        kStatNFuncWmode,
        kStatNFuncRstat,
        kStatNFuncRcstat,
        kStatNFuncRsid,
        kStatNFuncWsid,
        kStatNFuncUimpl,
        kStatNRxFraSeen,
        kStatNRxFraFDst,
        kStatNRxFraFBcast,
        kStatNRxFraFMcast,
        kStatNRxFraFProm,
        kStatNRxFraFUDrop,
        kStatNRxFraFMDrop,
        kStatNRxFraQLDrop,
        kStatNRxFraNRDrop,
        kStatNRxFra,
        kStatNRxFraMcast,
        kStatNRxFraBcast,
        kStatNRxByt,
        kStatNRxBytMcast,
        kStatNRxFraLoInt,
        kStatNRxFraLoBuf,
        kStatNRxFraPad,
        kStatNTxFra,
        kStatNTxFraMcast,
        kStatNTxFraBcast,
        kStatNTxByt,
        kStatNTxBytMcast,
        kStatNTxFraAbort,
        kStatNTxFraPad,
        kStatNFraLoop,
        kDimStat
      };    

    protected:

      enum s_tx {
        kStateTxIdle = 0,
        kStateTxBusy
      };    
      enum s_rx {
        kStateRxIdle = 0,
        kStateRxBusy,
        kStateRxPoll
      };

      int           AttnHandler(RlinkServer::AttnArgs& args);

      void          ClearMacList();
      void          ClearCtr();
      void          ClearStatus();

      void          Reset();
      void          SetRunning(bool run);
      bool          ExecGetcmd(RlinkCommandList& clist);

      void          Wlist2UBAddr(const uint16_t wlist[2], uint32_t& addr);
      void          Wlist2UBAddrLen(const uint16_t wlist[2], 
                                    uint32_t& addr, uint16_t& len);
      void          UBAddrLen2Wlist(uint16_t wlist[2], 
                                    uint32_t addr, uint16_t len);
      void          SetupPrimClist();

      uint16_t      GetPr1() const;

      void          StartTxRing();
      void          StartTxRing(const uint16_t dsccur[4],
                                const uint16_t dscnxt[4]);
      void          StopTxRing();

      void          StartRxRing();
      void          StartRxRing(const uint16_t dsccur[4],
                                const uint16_t dscnxt[4]);
      void          StopRxRing();

      int           TxRingHandler();
      int           RxRingHandler();
      int           RxPollHandler(const pollfd& pfd);

      uint16_t      RingIndexNext(uint16_t index, uint16_t size, 
                                  uint16_t inc=1) const;
      uint16_t      TxRingIndexNext(uint16_t inc=1) const;
      uint16_t      RxRingIndexNext(uint16_t inc=1) const;

      uint32_t      RingDscAddr(uint32_t base, uint16_t elen, 
                                uint16_t index) const;
      uint32_t      TxRingDscAddr(uint16_t index) const;
      uint32_t      RxRingDscAddr(uint16_t index) const;
    
      int           MacFilter(uint64_t mac);

      void          UpdateStat16(uint32_t& stat, size_t ind, uint32_t inc=1);
      void          UpdateStat32(uint32_t& stat, size_t ind, uint32_t inc=1);

      void          LogMacFunc(const char* cmd, uint64_t mac);
      void          LogMcastFunc(const char* cmd);
      void          LogRingFunc(const char* cmd);
      void          LogFunc(const char* cmd, const char* tag1, uint16_t val1,
                            const char* tag2=nullptr, uint16_t val2=0);
      void          LogRingInfo(char rxtx, char rw);
      void          LogFrameInfo(char rxtx, const RethBuf& buf);

      static void   SetRingDsc(uint16_t dst[4], const uint16_t src[4]);
      static std::string RingDsc2String(const uint16_t dsc[4], char rxtx);
      static std::string RingDsc2OSEString(const uint16_t dsc[4], char fill=' ');

    protected:
      size_t        fPC_rdpr0;              //!< PrimClist: rd pr0 index
      size_t        fPC_rdpcb;              //!< PrimClist: rd pcb index
      size_t        fPC_lapcb;              //!< PrimClist: la pcb index
      size_t        fPC_rdtxdsccur;         //!< PrimClist: rd txdsc cur index
      size_t        fPC_latxdsccur;         //!< PrimClist: la txdsc cur index
      size_t        fPC_rdtxdscnxt;         //!< PrimClist: rd txdsc nxt index
      size_t        fPC_latxdscnxt;         //!< PrimClist: la txdsc nxt index
      size_t        fPC_rdrxdsccur;         //!< PrimClist: rd rxdsc index
      size_t        fPC_larxdsccur;         //!< PrimClist: la rxdsc index
      size_t        fPC_rdrxdscnxt;         //!< PrimClist: rd rxdsc index
      bool          fPcbbValid;             //!< pcbb valid
      uint32_t      fPcbb;                  //!< process control block base
      uint16_t      fPcb[4];                //!< process control block
      bool          fRingValid;             //!< ring format valid
      uint32_t      fTxRingBase;            //!< tx ring base
      uint16_t      fTxRingSize;            //!< tx ring size (# of entries)
      uint16_t      fTxRingELen;            //!< tx ring entry length
      uint32_t      fRxRingBase;            //!< rx ring base
      uint16_t      fRxRingSize;            //!< rx ring size (# of entries)
      uint16_t      fRxRingELen;            //!< rx ring entry length
      uint64_t      fMacDefault;            //!< default MAC
      uint64_t      fMacList[2+kDimMcast];  //!< MAC list:0=phys,1=bcast,2+=mcast
      int           fMcastCnt;              //!< mcast count
      uint16_t      fPr0Last;               //!< last pr0 value
      bool          fPr1Pcto;               //!< pr1 pcto flag
      bool          fPr1Delua;              //!< pr1 delua flag
      uint16_t      fPr1State;              //!< pr1 state
      bool          fRunning;               //!< in kSTATE_RUN and active
      uint16_t      fMode;                  //!< mode
      uint16_t      fStatus;                //!< status
      uint16_t      fTxRingIndex;           //!< tx ring index
      uint16_t      fRxRingIndex;           //!< rx ring index
      uint16_t      fTxDscCurPC[4];         //!< tx cur ring dsc from PrimClist
      uint16_t      fTxDscNxtPC[4];         //!< tx nxt ring dsc from PrimClist
      uint16_t      fRxDscCurPC[4];         //!< rx cur ring dsc from PrimClist
      uint16_t      fRxDscNxtPC[4];         //!< rx nxt ring dsc from PrimClist
      enum s_tx     fTxRingState;           //!< tx ring handler state
      uint16_t      fTxDscCur[4];           //!< tx cur ring dsc
      uint16_t      fTxDscNxt[4];           //!< tx nxt ring dsc
      RethBuf       fTxBuf;                 //!< tx packet buffer
      size_t        fTxBufOffset;           //!< tx packet offset
      enum s_rx     fRxRingState;           //!< rx ring handler busy
      uint16_t      fRxDscCur[4];           //!< rx cur ring dsc
      uint16_t      fRxDscNxt[4];           //!< rx nxt ring dsc
      Rtime         fRxPollTime;            //!< rx poll time interval
      size_t        fRxQueLimit;            //!< rx queue limit
      RtimerFd      fRxPollTimer;           //!< rx poll timer
      std::deque<RethBuf::pbuf_t> fRxBufQueue; //!< rx packet queue
      RethBuf::pbuf_t fRxBufCurr;           //!< rx packet current
      size_t        fRxBufOffset;           //!< rx packet offset
      Rtime         fCtrTimeCleared;        //!< ctr: time when cleared
      uint32_t      fCtrRxFra;              //!< ctr: rcvd frames
      uint32_t      fCtrRxFraMcast;         //!< ctr: rcvd mcast frames
      uint32_t      fCtrRxByt;              //!< ctr: rcvd bytes
      uint32_t      fCtrRxBytMcast;         //!< ctr: rcvd mcast bytes
      uint32_t      fCtrRxFraLoInt;         //!< ctr: rcvd frame lost int error
      uint32_t      fCtrRxFraLoBuf;         //!< ctr: rcvd frame lost buffers
      uint32_t      fCtrTxFra;              //!< ctr: xmit frames
      uint32_t      fCtrTxFraMcast;         //!< ctr: xmit mcast frames
      uint32_t      fCtrTxByt;              //!< ctr: xmit bytes
      uint32_t      fCtrTxBytMcast;         //!< ctr: xmit mcast bytes
      uint32_t      fCtrTxFraAbort;         //!< ctr: xmit aborted frames
      uint32_t      fCtrFraLoop;            //!< ctr: loopback frames
 };
  
} // end namespace Retro

#include "Rw11CntlDEUNA.ipp"

#endif
