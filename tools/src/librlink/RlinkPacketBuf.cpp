// $Id: RlinkPacketBuf.cpp 1198 2019-07-27 19:08:31Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-07-27  1198   2.0.4  add kNc* definitions
// 2017-04-07   868   2.0.1  Dump(): add detail arg
// 2014-11-23   606   2.0    re-organize for rlink v4
// 2013-04-21   509   1.0.4  add SndAttn() method
// 2013-02-03   481   1.0.3  use Rexception
// 2013-01-13   474   1.0.2  add PollAttn() method
// 2013-01-04   469   1.0.1  SndOob(): Add filler 0 to ensure escape state
// 2011-04-02   375   1.0    Initial version
// 2011-03-05   366   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation of class RlinkPacketBuf.
 */

#include "RlinkPacketBuf.hpp"

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"

using namespace std;

/*!
  \class Retro::RlinkPacketBuf
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint32_t RlinkPacketBuf::kFlagSopSeen;
const uint32_t RlinkPacketBuf::kFlagEopSeen;
const uint32_t RlinkPacketBuf::kFlagNakSeen;
const uint32_t RlinkPacketBuf::kFlagAttnSeen;
const uint32_t RlinkPacketBuf::kFlagErrTout;
const uint32_t RlinkPacketBuf::kFlagErrIO;
const uint32_t RlinkPacketBuf::kFlagErrFrame;
const uint32_t RlinkPacketBuf::kFlagErrClobber;

const uint8_t RlinkPacketBuf::kSymEsc;
const uint8_t RlinkPacketBuf::kSymFill;
const uint8_t RlinkPacketBuf::kSymXon;
const uint8_t RlinkPacketBuf::kSymXoff;
const uint8_t RlinkPacketBuf::kSymEdPref;
const uint8_t RlinkPacketBuf::kEcSop;
const uint8_t RlinkPacketBuf::kEcEop;
const uint8_t RlinkPacketBuf::kEcNak;
const uint8_t RlinkPacketBuf::kEcAttn;
const uint8_t RlinkPacketBuf::kEcXon;
const uint8_t RlinkPacketBuf::kEcXoff;
const uint8_t RlinkPacketBuf::kEcFill;
const uint8_t RlinkPacketBuf::kEcEsc;
const uint8_t RlinkPacketBuf::kEcClobber;
const uint8_t RlinkPacketBuf::kNcCcrc;
const uint8_t RlinkPacketBuf::kNcDcrc;
const uint8_t RlinkPacketBuf::kNcFrame;
const uint8_t RlinkPacketBuf::kNcUnused;
const uint8_t RlinkPacketBuf::kNcCmd;
const uint8_t RlinkPacketBuf::kNcCnt;
const uint8_t RlinkPacketBuf::kNcRtOvlf;
const uint8_t RlinkPacketBuf::kNcRtWblk;
const uint8_t RlinkPacketBuf::kNcInval;

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkPacketBuf::RlinkPacketBuf()
  : fPktBuf(),
    fCrc(),
    fFlags(0),
    fStats()
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkPacketBuf::~RlinkPacketBuf()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPacketBuf::Dump(std::ostream& os, int ind, const char* text,
                          int detail) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkPacketBuf @ " << this << endl;
  os << bl << "  fCrc:          " << RosPrintBvi(fCrc.Crc(), 0) << endl;
  os << bl << "  fFlags:        " << RosPrintBvi(fFlags, 0) << endl;
  fStats.Dump(os, ind+2, "fStats: ", detail-1);

  os << bl << "  fPktBuf.size:  " << RosPrintf(fPktBuf.size(),"d",4);
  size_t ncol  = max(1, (80-ind-4-6)/(2+1));
  for (size_t i=0; i< fPktBuf.size(); i++) {
    if (i%ncol == 0) os << "\n" << bl << "    " << RosPrintf(i,"d",4) << ": ";
    os << RosPrintBvi(fPktBuf[i],16) << " ";
  }
  os << endl;

  return;
}

} // end namespace Retro
