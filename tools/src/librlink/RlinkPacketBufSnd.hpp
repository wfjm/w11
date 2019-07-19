// $Id: RlinkPacketBufSnd.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2014-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-08  1079   1.2    use ref not ptr for RlinkPort
// 2017-04-07   868   1.1.2  Dump(): add detail arg
// 2015-04-11   666   1.1    handle xon/xoff escaping, add (Set)XonEscape()
// 2014-12-25   621   1.0.1  Reorganize packet send/revd stats
// 2014-11-14   604   1.0    Initial version
// 2014-11-02   600   0.1    First draft (re-organize PacketBuf for rlink v4)
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RlinkPacketBufSnd.
*/

#ifndef included_Retro_RlinkPacketBufSnd
#define included_Retro_RlinkPacketBufSnd

#include "RlinkPacketBuf.hpp"
#include "RlinkPort.hpp"

namespace Retro {

  class RlinkPacketBufSnd : public RlinkPacketBuf {
    public:

                    RlinkPacketBufSnd();
                   ~RlinkPacketBufSnd();

      void          SetXonEscape(bool xon);
      bool          XonEscape() const;

      void          Init();

      void          PutWithCrc(uint8_t data);
      void          PutWithCrc(uint16_t data);
      void          PutWithCrc(const uint16_t* pdata, size_t count);
      void          PutCrc();

      void          PutRawEsc(uint8_t ec);

      bool          SndPacket(RlinkPort& port, RerrMsg& emsg);
      bool          SndOob(RlinkPort& port, uint16_t addr, uint16_t data, 
                           RerrMsg& emsg);
      bool          SndKeep(RlinkPort& port, RerrMsg& emsg);
      bool          SndAttn(RlinkPort& port, RerrMsg& emsg);    
      bool          SndNak(RlinkPort& port, RerrMsg& emsg);    
      bool          SndUnJam(RlinkPort& port, RerrMsg& emsg);

      size_t        RawSize() const;

      void          Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;
 
   // statistics counter indices
      enum stats {
        kStatNTxPktByt=0,                   //!< Tx packet bytes send
        kStatNTxEsc,                        //!< Tx esc escapes
        kStatNTxXEsc                        //!< Tx xon escapes
      };

    protected:
      bool          SndRaw(RlinkPort& port, RerrMsg& emsg);

    protected:
      bool          fXonEscape;             //!< escape XON/XOFF
      std::vector<uint8_t> fRawBuf;         //!< raw data buffer
  };
  
} // end namespace Retro

#include "RlinkPacketBufSnd.ipp"

#endif
