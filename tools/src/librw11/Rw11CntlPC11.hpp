// $Id: Rw11CntlPC11.hpp 1131 2019-04-14 13:24:25Z mueller $
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

      static const uint16_t kRCSR_M_ERROR = kWBit15; //!< rcsr.err mask
      static const uint16_t kRCSR_V_RLIM  = 12;      //!< rcsr.rlim shift 
      static const uint16_t kRCSR_B_RLIM  = 007;     //!< rcsr.rlim bit mask
      static const uint16_t kRCSR_V_TYPE  =  8;      //!< rcsr.type shift
      static const uint16_t kRCSR_B_TYPE  = 0007;    //!< rcsr.type bit mask
      static const uint16_t kRCSR_M_FCLR  = kWBit05; //!< rcsr.fclr mask
      static const uint16_t kRBUF_M_RBUSY = kWBit15; //!< rbuf.rbusy mask
      static const uint16_t kRBUF_V_SIZE =  8;       //!< rbuf.size shift
      static const uint16_t kRBUF_B_SIZE = 0177;     //!< rbuf.size bit mask
      static const uint16_t kRBUF_M_BUF   = 0377;    //!< rbuf data mask
    
      static const uint16_t kPCSR_M_ERROR = kWBit15; //!< pcsr.err mask
      static const uint16_t kPCSR_V_RLIM  = 12;      //!< pcsr.rlim shift 
      static const uint16_t kPCSR_B_RLIM  = 007;     //!< pcsr.rlim bit mask
      static const uint16_t kPBUF_M_VAL   = kWBit15; //!< pbuf.val mask
      static const uint16_t kPBUF_V_SIZE  =  8;      //!< pbuf.size shift
      static const uint16_t kPBUF_B_SIZE  = 0177;    //!< pbuf.size bit mask
      static const uint16_t kPBUF_M_BUF   = 0377;    //!< pbuf data mask

    protected:
      int           AttnHandler(RlinkServer::AttnArgs& args);
    
    protected:
      size_t        fPC_pbuf;               //!< PrimClist: pbuf index
      size_t        fPC_rbuf;               //!< PrimClist: rbuf index
  };
  
} // end namespace Retro

//#include "Rw11CntlPC11.ipp"

#endif
