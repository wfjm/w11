// $Id: Rw11CntlDL11.hpp 1156 2019-05-31 18:22:40Z mueller $
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
// 2019-05-30  1155   1.4.1  size->fuse rename; use unit.StatInc[RT]x
// 2019-04-26  1139   1.4    add dl11_buf readout
// 2019-04-06  1126   1.3    xbuf.val in msb; rrdy in rbuf (new iface)
// 2017-05-14   897   1.2    add RcvChar(),TraceChar()
// 2017-04-02   865   1.1.1  Dump(): add detail arg
// 2014-12-29   623   1.1    adopt to Rlink V4 attn logic
// 2013-05-04   516   1.0.1  add RxRlim support (receive interrupt rate limit)
// 2013-03-06   495   1.0    Initial version
// 2013-02-05   483   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11CntlDL11.
*/

#ifndef included_Retro_Rw11CntlDL11
#define included_Retro_Rw11CntlDL11 1

#include "Rw11CntlBase.hpp"
#include "Rw11UnitDL11.hpp"

namespace Retro {

  class Rw11CntlDL11 : public Rw11CntlBase<Rw11UnitDL11,1> {
    public:

                    Rw11CntlDL11();
                   ~Rw11CntlDL11();

      void          Config(const std::string& name, uint16_t base, int lam);

      virtual void  Start();

      virtual void  UnitSetup(size_t ind);
      void          Wakeup();

      void          SetRxQlim(uint16_t qlim);
      uint16_t      RxQlim() const;
      void          SetRxRlim(uint16_t rlim);
      uint16_t      RxRlim() const;
      void          SetTxRlim(uint16_t rlim);
      uint16_t      TxRlim() const;
    
      uint16_t      Itype() const;
      bool          Buffered() const;
      uint16_t      FifoSize() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // some constants (also defined in cpp)
      static const uint16_t kIbaddr = 0177560; //!< DL11 default address
      static const int      kLam    = 1;       //!< DL11 default lam 

      static const uint16_t kRCSR = 000; //!< RCSR reg offset
      static const uint16_t kRBUF = 002; //!< RBUF reg offset
      static const uint16_t kXCSR = 004; //!< XCSR reg offset
      static const uint16_t kXBUF = 006; //!< XBUF reg offset

      static const uint16_t kProbeOff = kRCSR; //!< probe address offset (rcsr)
      static const bool     kProbeInt = true;  //!< probe int active
      static const bool     kProbeRem = true;  //!< probr rem active

      static const uint16_t kFifoMaxSize  = 127;     //!< maximal fifo size
    
      static const uint16_t kRCSR_V_RLIM  = 12;      //!< rcsr.rlim shift
      static const uint16_t kRCSR_B_RLIM  = 007;     //!< rcsr.rlim bit mask
      static const uint16_t kRCSR_V_TYPE  =  8;      //!< rcsr.type shift
      static const uint16_t kRCSR_B_TYPE  = 0007;    //!< rcsr.type bit mask
      static const uint16_t kRCSR_M_RDONE = kWBit07; //!< rcsr.rdone mask
      static const uint16_t kRCSR_M_FCLR  = kWBit01; //!< rcsr.fclr mask    
      static const uint16_t kRBUF_V_RFUSE =  8;      //!< rbuf.rfuse shift
      static const uint16_t kRBUF_B_RFUSE = 0177;    //!< rbuf.rfuse bit mask
      static const uint16_t kRBUF_M_DATA  = 0377;    //!< rbuf data mask
  
      static const uint16_t kXCSR_V_RLIM  = 12;      //!< xcsr.rlim shift 
      static const uint16_t kXCSR_B_RLIM  = 007;     //!< xcsr.rlim bit mask
      static const uint16_t kXCSR_M_XRDY  = kWBit07; //!< xcsr.xrdy mask
      static const uint16_t kXCSR_M_FCLR  = kWBit01; //!< xcsr.fclr mask    
      static const uint16_t kXBUF_M_VAL   = kWBit15; //!< xbuf.val mask
      static const uint16_t kXBUF_V_FUSE  =  8;      //!< xbuf.fuse shift
      static const uint16_t kXBUF_B_FUSE  = 0177;    //!< xbuf.fuse bit mask
      static const uint16_t kXBUF_M_DATA  = 0xff;    //!< xbuf data mask

    // statistics counter indices
      enum stats {
        kStatNRxBlk= Rw11Cntl::kDimStat,    //!< done wblk
        kStatNTxQue,                        //!< queue rblk
        kDimStat
      };
    
    protected:
      int           AttnHandler(RlinkServer::AttnArgs& args);
      void          ProcessUnbuf(uint16_t rbuf, uint16_t xbuf);
      void          RxProcessUnbuf();
      void          RxProcessBuf(uint16_t rbuf);
      void          TxProcessBuf(const RlinkCommand& cmd, bool prim,
                                 uint16_t rbuf);
      int           TxRcvHandler();
      void          TraceChar(char dir, uint16_t xbuf, uint8_t chr);
    
    protected:
      size_t        fPC_xbuf;               //!< PrimClist: xbuf index
      size_t        fPC_rbuf;               //!< PrimClist: rbuf index
      uint16_t      fRxQlim;                //!< rx queue limit
      uint16_t      fRxRlim;                //!< rx interrupt rate limit
      uint16_t      fTxRlim;                //!< tx interrupt rate limit
      uint16_t      fItype;                 //!< interface type
      uint16_t      fFsize;                 //!< fifo size
      uint16_t      fTxRblkSize;            //!< tx rblk chunk size
      bool          fTxQueBusy;             //!< tx queue busy
      uint16_t      fLastRbuf;              //!< last seen rbuf
  };
  
} // end namespace Retro

#include "Rw11CntlDL11.ipp"

#endif
