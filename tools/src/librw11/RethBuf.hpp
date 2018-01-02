// $Id: RethBuf.hpp 983 2018-01-02 20:35:59Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-17   880   1.0    Initial version
// 2017-02-12   850   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class RethBuf.
*/

#ifndef included_Retro_RethBuf
#define included_Retro_RethBuf 1

#include <memory>
#include <string>

#include "librtools/Rtime.hpp"

namespace Retro {

  class RethBuf {
    public:
      typedef std::shared_ptr<RethBuf> pbuf_t;
    
                    RethBuf();
                   ~RethBuf();
    
      void          Clear();
      void          SetSize(uint16_t size);
      void          SetTime();
      void          SetTime(const Rtime& time);

      uint16_t      Size() const;
      const Rtime&  Time() const;

      const uint8_t*  Buf8() const;
      const uint16_t* Buf16() const;
      const uint32_t* Buf32() const;

      uint8_t*      Buf8();
      uint16_t*     Buf16();
      uint32_t*     Buf32();

      void          SetMacDestination(uint64_t mac);
      void          SetMacSource(uint64_t mac);

      uint64_t      MacDestination() const;
      uint64_t      MacSource() const;
      uint16_t      Type() const;
      bool          IsMcast() const;
      bool          IsBcast() const;

      ssize_t       Read(int fd);
      ssize_t       Write(int fd) const;

      std::string   FrameInfo() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // some constants
      static const size_t   kMaxSize  = 1514;  //!< max ethernet frame size
      static const size_t   kMinSize  =   60;  //!< min ethernet frame size
      static const size_t   kCrcSize  =    4;  //!< size of ethernet CRC
      static const size_t   kWOffDstMac =  0;  //!< offset dst mac in 16 bit wrds
      static const size_t   kWOffSrcMac =  3;  //!< offset src mac in 16 bit wrds
      static const size_t   kWOffTyp    =  6;  //!< offset type in 16 bit wrds

    protected:
      Rtime         fTime;
      uint16_t      fSize;
      uint8_t       fBuf[kMaxSize+kCrcSize];
  };

} // end namespace Retro

#include "RethBuf.ipp"

#endif
