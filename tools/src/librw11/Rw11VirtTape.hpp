// $Id: Rw11VirtTape.hpp 1180 2019-07-08 15:46:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-07-08  1180   1.2.1  remove dtor
// 2018-12-02  1076   1.2    use unique_ptr for New()
// 2017-04-07   868   1.1.1  Dump(): add detail arg
// 2017-04-02   864   1.1    move fWProt,WProt() to Rw11Virt base
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rw11VirtTape.
*/

#ifndef included_Retro_Rw11VirtTape
#define included_Retro_Rw11VirtTape 1

#include <memory>

#include "Rw11Virt.hpp"

namespace Retro {

  class Rw11VirtTape : public Rw11Virt {
    public:
      explicit      Rw11VirtTape(Rw11Unit* punit);

      void          SetCapacity(size_t nbyte);
      size_t        Capacity() const;

      virtual bool  ReadRecord(size_t nbyte, uint8_t* data, size_t& ndone, 
                               int& opcode, RerrMsg& emsg) = 0;
      virtual bool  WriteRecord(size_t nbyte, const uint8_t* data, 
                                int& opcode, RerrMsg& emsg) = 0;
      virtual bool  WriteEof(RerrMsg& emsg) = 0;
      virtual bool  SpaceForw(size_t nrec, size_t& ndone, 
                              int& opcode, RerrMsg& emsg) = 0;
      virtual bool  SpaceBack(size_t nrec, size_t& ndone, 
                              int& opcode, RerrMsg& emsg) = 0;
      virtual bool  Rewind(int& opcode, RerrMsg& emsg) = 0;

      void          SetPosFile(int posfile);
      void          SetPosRecord(int posrec);

      bool          Bot() const;
      bool          Eot() const;
      bool          Eom() const;

      int           PosFile() const;
      int           PosRecord() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

      static std::unique_ptr<Rw11VirtTape> New(const std::string& url,
                                               Rw11Unit* punit, RerrMsg& emsg);

    // statistics counter indices
      enum stats {
        kStatNVTReadRec = Rw11Virt::kDimStat,
        kStatNVTReadByt,
        kStatNVTReadEof,
        kStatNVTReadEom,
        kStatNVTReadPErr,
        kStatNVTReadLErr,
        kStatNVTWriteRec,
        kStatNVTWriteByt,
        kStatNVTWriteEof,
        kStatNVTSpaForw,
        kStatNVTSpaBack,
        kStatNVTRewind,
        kDimStat
      };    

    // operation code
      enum OpCode {
        kOpCodeOK = 0,                      //!< operation OK
        kOpCodeBot,                         //!< ended at BOT
        kOpCodeEof,                         //!< ended at EOF
        kOpCodeEom,                         //!< ended at EOM
        kOpCodeRecLenErr,                   //!< record length error
        kOpCodeBadParity,                   //!< record with parity error
        kOpCodeBadFormat                    //!< file format error
      };

    protected:
      size_t        fCapacity;              //!< capacity in byte (0=unlimited)
      bool          fBot;                   //!< tape at bot
      bool          fEot;                   //!< tape beyond eot
      bool          fEom;                   //!< tape beyond medium
      int           fPosFile;               //!< tape pos: #files  (-1=unknown)
      int           fPosRecord;             //!< tape pos: #record (-1=unknown)
  };
  
} // end namespace Retro

#include "Rw11VirtTape.ipp"

#endif
