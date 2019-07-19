// $Id: Rw11CntlPC11.hpp 1185 2019-07-12 17:29:12Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-05-30  1155   1.4.1  size->fuse rename
// 2019-04-20  1134   1.4    add pc11_buf readout
// 2019-04-14  1131   1.3.1  remove SetOnline(), use UnitSetup()
// 2019-04-06  1126   1.3    pbuf.val in msb; rbusy in rbuf (new iface)
// 2017-04-02   865   1.2.1  Dump(): add detail arg
// 2014-12-29   623   1.1    adapt to Rlink V4 attn logic
// 2013-05-03   515   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11CntlPC11.
*/

#ifndef included_Retro_Rw11CntlPC11
#define included_Retro_Rw11CntlPC11 1

#include "Rw11CntlBase.hpp"
#include "Rw11UnitPC11.hpp"

namespace Retro {

  class Rw11CntlPC11 : public Rw11CntlBase<Rw11UnitPC11,2> {
    public:

                    Rw11CntlPC11();
                   ~Rw11CntlPC11();

      void          Config(const std::string& name, uint16_t base, int lam);

      virtual void  Start();

      virtual bool  BootCode(size_t unit, std::vector<uint16_t>& code, 
                             uint16_t& aload, uint16_t& astart);

      virtual void  UnitSetup(size_t ind);
    
      void          SetPrQlim(uint16_t qlim);
      uint16_t      PrQlim() const;
      void          SetPrRlim(uint16_t rlim);
      uint16_t      PrRlim() const;
      void          SetPpRlim(uint16_t rlim);
      uint16_t      PpRlim() const;
    
      uint16_t      Itype() const;
      bool          Buffered() const;
      uint16_t      FifoSize() const;

      void          AttachDone(size_t ind);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // some constants (also defined in cpp)
      static const uint16_t kIbaddr = 0177550; //!< PC11 default address
      static const int      kLam    = 10;      //!< PC11 default lam 

      static const uint16_t kRCSR = 000;  //!< RCSR reg offset
      static const uint16_t kRBUF = 002;  //!< RBUF reg offset
      static const uint16_t kPCSR = 004;  //!< PCSR reg offset
      static const uint16_t kPBUF = 006;  //!< PBUF reg offset

      static const uint16_t kUnit_PR   = 0;   //!< unit number of paper reader 
      static const uint16_t kUnit_PP   = 1;   //!< unit number of paper puncher 

      static const uint16_t kProbeOff = kRCSR; //!< probe address offset (rcsr)
      static const bool     kProbeInt = true;  //!< probe int active
      static const bool     kProbeRem = true;  //!< probr rem active

      static const uint16_t kFifoMaxSize  = 127;     //!< maximal fifo size

      static const uint16_t kRCSR_M_ERROR = kWBit15; //!< rcsr.err mask
      static const uint16_t kRCSR_V_RLIM  = 12;      //!< rcsr.rlim shift 
      static const uint16_t kRCSR_B_RLIM  = 007;     //!< rcsr.rlim bit mask
      static const uint16_t kRCSR_V_TYPE  =  8;      //!< rcsr.type shift
      static const uint16_t kRCSR_B_TYPE  = 0007;    //!< rcsr.type bit mask
      static const uint16_t kRCSR_M_FCLR  = kWBit01; //!< rcsr.fclr mask
      static const uint16_t kRBUF_M_RBUSY = kWBit15; //!< rbuf.rbusy mask
      static const uint16_t kRBUF_V_FUSE =  8;       //!< rbuf.fuse shift
      static const uint16_t kRBUF_B_FUSE = 0177;     //!< rbuf.fuse bit mask
      static const uint16_t kRBUF_M_DATA  = 0377;    //!< rbuf data mask
    
      static const uint16_t kPCSR_M_ERROR = kWBit15; //!< pcsr.err mask
      static const uint16_t kPCSR_V_RLIM  = 12;      //!< pcsr.rlim shift 
      static const uint16_t kPCSR_B_RLIM  = 007;     //!< pcsr.rlim bit mask
      static const uint16_t kPBUF_M_VAL   = kWBit15; //!< pbuf.val mask
      static const uint16_t kPBUF_V_FUSE  =  8;      //!< pbuf.fuse shift
      static const uint16_t kPBUF_B_FUSE  = 0177;    //!< pbuf.fuse bit mask
      static const uint16_t kPBUF_M_DATA  = 0377;    //!< pbuf data mask
    
    // statistics counter indices
      enum stats {
        kStatNPrBlk= Rw11Cntl::kDimStat,    //!< done wblk
        kStatNPpQue,                        //!< queue rblk
        kDimStat
      };

    // PrDrain state definitions
      enum prdrain {
        kPrDrain_Idle = 0,                  //!< draining not active
        kPrDrain_Pend,                      //!< draining pending
        kPrDrain_Done                       //!< draining done
      };
    
    protected:
      int           AttnHandler(RlinkServer::AttnArgs& args);
      void          ProcessUnbuf(uint16_t rbuf, uint16_t pbuf);
      void          PpWriteChar(uint8_t ochr);
      void          PrProcessBuf(uint16_t rbuf);
      void          PpProcessBuf(const RlinkCommand& cmd, bool prim,
                                 uint16_t rbuf);
      int           PpRcvHandler();
    
    protected:
      size_t        fPC_pbuf;               //!< PrimClist: pbuf index
      size_t        fPC_rbuf;               //!< PrimClist: rbuf index
      uint16_t      fPrQlim;                //!< reader queue limit
      uint16_t      fPrRlim;                //!< reader interrupt rate limit
      uint16_t      fPpRlim;                //!< puncher interrupt rate limit
      uint16_t      fItype;                 //!< interface type
      uint16_t      fFsize;                 //!< fifo size
      uint16_t      fPpRblkSize;            //!< puncher rblk chunk size
      bool          fPpQueBusy;             //!< puncher queue busy
      int           fPrDrain;               //!< reader drain state
  };
  
} // end namespace Retro

#include "Rw11CntlPC11.ipp"

#endif
