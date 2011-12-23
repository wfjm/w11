// $Id: RlinkPortTerm.hpp 440 2011-12-18 20:08:09Z mueller $
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
// 2011-12-18   440   1.0.2  add kStatNPort stats
// 2011-12-11   438   1.0.1  Read(),Write(): added for xon handling, tcdrain();
// 2011-03-27   374   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkPortTerm.hpp 440 2011-12-18 20:08:09Z mueller $
  \brief   Declaration of class RlinkPortTerm.
*/

#ifndef included_Retro_RlinkPortTerm
#define included_Retro_RlinkPortTerm 1

#include <vector>
#include <termios.h>

#include "RlinkPort.hpp"

namespace Retro {

  class RlinkPortTerm : public RlinkPort {
    public:

                    RlinkPortTerm();
      virtual       ~RlinkPortTerm();

      virtual bool  Open(const std::string& url, RerrMsg& emsg);
      virtual void  Close();
      virtual int   Read(uint8_t* buf, size_t size, double timeout, 
                         RerrMsg& emsg);
      virtual int   Write(const uint8_t* buf, size_t size, RerrMsg& emsg);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // some constants
      static const uint8_t kc_xon  = 0x11;  // XON  char -> ^Q = hex 11
      static const uint8_t kc_xoff = 0x13;  // XOFF char -> ^S = hex 13
      static const uint8_t kc_xesc = 0x1b;  // XESC char -> ^[ = ESC = hex 1B

    // statistics counter indices
      enum stats {
        kStatNPortTxXesc = RlinkPort::kDimStat,
        kStatNPortRxXesc,
        kDimStat
      };    

    protected:
      void          DumpTios(std::ostream& os, int ind, const std::string& name,
                             const struct termios& tios) const;

    protected:
      struct termios fTiosOld;
      struct termios fTiosNew;
      bool fUseXon;                         //!< xon attribute set 
      bool fPendXesc;                       //!< xesc pending
      std::vector<uint8_t> fTxBuf;          //!< buffer to handle xesc
      std::vector<uint8_t> fRxBuf;          //!< buffer to handle xesc
  };
  
} // end namespace Retro

#if !(defined(Retro_NoInline) || defined(Retro_RlinkPortTerm_NoInline))
//#include "RlinkPortTerm.ipp"
#endif

#endif
