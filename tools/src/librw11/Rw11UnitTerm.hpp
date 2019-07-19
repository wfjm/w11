// $Id: Rw11UnitTerm.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-05-18  1150   1.2    add detailed stats and StatInc{Rx,Tx}
// 2017-04-07   868   1.1.2  Dump(): add detail arg
// 2017-02-25   855   1.1.1  RcvNext() --> RcvQueueNext(); WakeupCntl() now pure
// 2013-05-03   515   1.1    use AttachDone(),DetachCleanup(),DetachDone()
// 2013-04-20   508   1.0.1  add 7bit and non-printable masking; add log file
// 2013-04-13   504   1.0    Initial version
// 2013-02-19   490   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class Rw11UnitTerm.
*/

#ifndef included_Retro_Rw11UnitTerm
#define included_Retro_Rw11UnitTerm 1

#include <iostream>
#include <fstream>
#include <deque>

#include "Rw11VirtTerm.hpp"

#include "Rw11UnitVirt.hpp"

namespace Retro {

  class Rw11UnitTerm : public Rw11UnitVirt<Rw11VirtTerm> {
    public:
                    Rw11UnitTerm(Rw11Cntl* pcntl, size_t index);
                   ~Rw11UnitTerm();

      const std::string& ChannelId() const;

      void          SetTo7bit(bool to7bit);
      void          SetToEnpc(bool toenpc);
      void          SetTi7bit(bool ti7bit);
      bool          To7bit() const;
      bool          ToEnpc() const;
      bool          Ti7bit() const;

      void          SetLog(const std::string& fname);
      const std::string&  Log() const;

      void          StatIncRx(uint8_t ichr, bool ferr=false);
      void          StatIncTx(uint8_t ochr, bool ferr=false);

      virtual bool    RcvQueueEmpty();
      virtual size_t  RcvQueueSize();
      virtual uint8_t RcvQueueNext();
      virtual size_t Rcv(uint8_t* buf, size_t count);

      virtual bool  Snd(const uint8_t* buf, size_t count);

      virtual bool  RcvCallback(const uint8_t* buf, size_t count);
      virtual void  WakeupCntl() = 0;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // statistics counter indices
      enum stats {
        kStatNPreAttDrop = Rw11Unit::kDimStat, //!< dropped prior to attach
        kStatNRxFerr,                          //!< rx frame error
        kStatNRxChar,                          //!< rx char (no ferr)
        kStatNRxNull,                          //!< rx null char
        kStatNRx8bit,                          //!< rx with bit 8 set
        kStatNRxLine,                          //!< rx lines (CR)
        kStatNTxFerr,                          //!< tx frame error
        kStatNTxChar,                          //!< tx char (no ferr)
        kStatNTxNull,                          //!< tx null char
        kStatNTx8bit,                          //!< tx with bit 8 set
        kStatNTxLine,                          //!< tx lines (LF)
        kDimStat
      };
    
    protected:
      virtual void  AttachDone();

    protected:
      bool          fTo7bit;                //!< discard parity bit on output
      bool          fToEnpc;                //!< escape non-printables on output
      bool          fTi7bit;                //!< discard parity bit on input
      std::deque<uint8_t>  fRcvQueue;       //!< input queue
      std::string   fLogFname;              //!< log file name
      std::ofstream fLogStream;             //!< log file stream
      bool          fLogOptCrlf;            //!< log file: crlf option given
      bool          fLogCrPend;             //!< log file: cr pending
      bool          fLogLfLast;             //!< log file: lf was last char
  };
  
} // end namespace Retro

#include "Rw11UnitTerm.ipp"

#endif
