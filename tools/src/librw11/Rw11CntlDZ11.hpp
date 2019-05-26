// $Id: Rw11CntlDZ11.hpp 1150 2019-05-19 17:52:54Z mueller $
//
// Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2019-05-19  1150   1.0    Initial version
// 2019-05-04  1146   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11CntlDZ11.
*/

#ifndef included_Retro_Rw11CntlDZ11
#define included_Retro_Rw11CntlDZ11 1

#include "Rw11CntlBase.hpp"
#include "Rw11UnitDZ11.hpp"

namespace Retro {

  class Rw11CntlDZ11 : public Rw11CntlBase<Rw11UnitDZ11,8> {
    public:

                    Rw11CntlDZ11();
                   ~Rw11CntlDZ11();

      void          Config(const std::string& name, uint16_t base, int lam);

      virtual void  Start();

      virtual void  UnitSetup(size_t ind);
      virtual void  UnitSetupAll();
      void          Wakeup();

      void          SetRxQlim(uint16_t qlim);
      uint16_t      RxQlim() const;
      void          SetRxRlim(uint16_t rlim);
      uint16_t      RxRlim() const;
      void          SetTxRlim(uint16_t rlim);
      uint16_t      TxRlim() const;
      void          SetModCntl(bool modcntl);
      bool          ModCntl() const;
    
      uint16_t      Itype() const;
      bool          Buffered() const;
      uint16_t      FifoSize() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // some constants (also defined in cpp)
      static const uint16_t kIbaddr = 0160100; //!< DZ11 default address
      static const int      kLam    = 3;       //!< DZ11 default lam 

      static const uint16_t kCNTL = 000; //!< CNTL and CSR      reg offset
      static const uint16_t kSTAT = 002; //!< STAT and RBUF/LPR reg offset
      static const uint16_t kFUSE = 004; //!< FUSE and TCR      reg offset
      static const uint16_t kFDAT = 006; //!< FDAT and TDR/MSR  reg offset

      static const uint16_t kProbeOff = kCNTL; //!< probe address offset (cntl)
      static const bool     kProbeInt = true;  //!< probe int active
      static const bool     kProbeRem = true;  //!< probr rem active

      static const uint16_t kFifoMaxSize  = 127;     //!< maximal fifo size

    // cntl read view
      static const uint16_t kCNTL_V_AWDTH  =  8;      //!< cntl.awdth shift
      static const uint16_t kCNTL_B_AWDTH  = 0007;    //!< cntl.awdth bit mask
      static const uint16_t kCNTL_V_SSEL   =  3;      //!< cntl.ssel  shift
      static const uint16_t kCNTL_B_SSEL   = 0003;    //!< cntl.ssel  bit mask 
      static const uint16_t kCNTL_M_MSE    = kWBit02; //!< cntl.mse   mask
      static const uint16_t kCNTL_M_MAINT  = kWBit01; //!< cntl.maint mask
    // cntl write view
      static const uint16_t kCNTL_V_DATA   =  8;      //!< cntl.data  shift
      static const uint16_t kCNTL_B_DATA   = 0377;    //!< cntl.data  bit mask
      static const uint16_t kCNTL_V_RRLIM  = 12;      //!< cntl.rrlim shift
      static const uint16_t kCNTL_B_RRLIM  = 0007;    //!< cntl.rrlim bit mask
      static const uint16_t kCNTL_V_TRLIM  =  8;      //!< cntl.trlim shift
      static const uint16_t kCNTL_B_TRLIM  = 0007;    //!< cntl.trlim bit mask
      static const uint16_t kCNTL_M_RCLR   = kWBit06; //!< cntl.rclr  mask
      static const uint16_t kCNTL_M_TCLR   = kWBit05; //!< cntl.rclr  mask
      static const uint16_t kCNTL_M_FUNC   = 0007;    //!< cntl.func  mask
    
      static const uint16_t kSSEL_DTLE   =  0;
      static const uint16_t kSSEL_BRRK   =  1;
      static const uint16_t kSSEL_CORI   =  2;
      static const uint16_t kSSEL_RLCN   =  3;
    
      static const uint16_t kFUNC_NOOP   =  0;
      static const uint16_t kFUNC_SCO    =  1;
      static const uint16_t kFUNC_SRING  =  2;
      static const uint16_t kFUNC_SRLIM  =  3;
    
      static const uint16_t kCAL_DTR     =  0;
      static const uint16_t kCAL_BRK     =  1;
      static const uint16_t kCAL_RXON    =  2;
      static const uint16_t kCAL_CSR     =  3;    

      static const uint16_t kFUSE_V_RFUSE  =  8;      //!< rfuse shift
      static const uint16_t kFUSE_B_RFUSE  = 0177;    //!< rfuse bit mask
      static const uint16_t kFUSE_M_TFUSE  = 0177;    //!< tfuse mask

      static const uint16_t kFDAT_M_VAL    = kWBit15; //!< fdat.val  mask
      static const uint16_t kFDAT_M_LAST   = kWBit14; //!< fdat.last mask
      static const uint16_t kFDAT_M_FERR   = kWBit13; //!< fdat.ferr mask
      static const uint16_t kFDAT_M_CAL    = kWBit11; //!< fdat.cal  mask
      static const uint16_t kFDAT_V_LINE   =  8;      //!< fdat.line shift
      static const uint16_t kFDAT_B_LINE   = 0007;    //!< fdat.line bit mask
      static const uint16_t kFDAT_M_BUF    = 0xFF;    //!< fdat.buf  mask
    
      static const uint16_t kCALCSR_M_MSE  = kWBit05; //!< fdat_cal.mse   mask
      static const uint16_t kCALCSR_M_CLR  = kWBit04; //!< fdat_cal.clr   mask
      static const uint16_t kCALCSR_M_MAINT= kWBit03; //!< fdat_cal.maint mask

    // statistics counter indices
      enum stats {
        kStatNRxBlk= Rw11Cntl::kDimStat,    //!< done wblk
        kStatNTxQue,                        //!< queue rblk
        kStatNCalDtr,                       //!< cal dtr received
        kStatNCalBrk,                       //!< cal brk received
        kStatNCalRxon,                      //!< cal rxon received
        kStatNCalCsr,                       //!< cal csr received
        kStatNCalBad,                       //!< cal invalid
        kStatNDropMse,                      //!< drop because mse=0
        kStatNDropMaint,                    //!< drop because maint=1
        kStatNDropRxon,                     //!< drop because rxon=0
        kDimStat
      };
    
    protected:
      int           AttnHandler(RlinkServer::AttnArgs& args);
      void          RxProcess(uint16_t fuse);
      void          TxProcess(const RlinkCommand& cmd, bool prim,
                              uint16_t fuse);
      int           TxRcvHandler();
      bool          NextBusyRxUnit();
    
    protected:
      size_t        fPC_fdat;               //!< PrimClist: fdat index
      size_t        fPC_fuse;               //!< PrimClist: fuse index
      uint16_t      fRxQlim;                //!< rx queue limit
      uint16_t      fRxRlim;                //!< rx interrupt rate limit
      uint16_t      fTxRlim;                //!< tx interrupt rate limit
      bool          fModCntl;               //!< modem control enable
      uint16_t      fItype;                 //!< interface type
      uint16_t      fFsize;                 //!< fifo size
      uint16_t      fTxRblkSize;            //!< tx rblk chunk size
      bool          fTxQueBusy;             //!< tx queue busy
      size_t        fRxCurUnit;             //!< rx current unit
      uint16_t      fLastFuse;              //!< last seen fuse
      uint8_t       fCurDtr;                //!< current dtr
      uint8_t       fCurBrk;                //!< current brk
      uint8_t       fCurRxon;               //!< current rxon
      uint8_t       fCurCsr;                //!< current csr
  };
  
} // end namespace Retro

#include "Rw11CntlDZ11.ipp"

#endif
