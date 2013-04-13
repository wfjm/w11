// $Id: Rw11UnitTerm.hpp 504 2013-04-13 15:37:24Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-04-13   504   1.0    Initial version
// 2013-02-19   490   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11UnitTerm.hpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Declaration of class Rw11UnitTerm.
*/

#ifndef included_Retro_Rw11UnitTerm
#define included_Retro_Rw11UnitTerm 1

#include <deque>

#include "Rw11VirtTerm.hpp"

#include "Rw11UnitVirt.hpp"

namespace Retro {

  class Rw11UnitTerm : public Rw11UnitVirt<Rw11VirtTerm> {
    public:
                    Rw11UnitTerm(Rw11Cntl* pcntl, size_t index);
                   ~Rw11UnitTerm();

      const std::string& ChannelId() const;

      void          SetRcv7bit(bool rcv7bit);
      bool          Rcv7bit() const;

      virtual bool  RcvQueueEmpty();
      virtual size_t RcvQueueSize();
      virtual uint8_t RcvNext();
      virtual size_t Rcv(uint8_t* buf, size_t count);

      virtual bool  Snd(const uint8_t* buf, size_t count);

      virtual bool  RcvCallback(const uint8_t* buf, size_t count);
      virtual void  WakeupCntl();

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected:
      virtual void  AttachSetup();

    protected:
      bool          fRcv7bit;               //<! discard parity bit on input
      std::deque<uint8_t>  fRcvQueue;       //<! input queue
  };
  
} // end namespace Retro

#include "Rw11UnitTerm.ipp"

#endif
