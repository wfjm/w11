// $Id: Rw11VirtTapeTap.hpp 1180 2019-07-08 15:46:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-07-08  1180   1.1    use RfileFd; remove dtor
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rw11VirtTapeTap.
*/

#ifndef included_Retro_Rw11VirtTapeTap
#define included_Retro_Rw11VirtTapeTap 1

#include "librtools/RfileFd.hpp"

#include "Rw11VirtTape.hpp"

namespace Retro {

  class Rw11VirtTapeTap : public Rw11VirtTape {
    public:

      explicit      Rw11VirtTapeTap(Rw11Unit* punit);

      virtual bool  Open(const std::string& url, RerrMsg& emsg);

      virtual bool  ReadRecord(size_t nbyt, uint8_t* data, size_t& ndone, 
                               int& opcode, RerrMsg& emsg);
      virtual bool  WriteRecord(size_t nbyt, const uint8_t* data, 
                                int& opcode, RerrMsg& emsg);
      virtual bool  WriteEof(RerrMsg& emsg);
      virtual bool  SpaceForw(size_t nrec, size_t& ndone, 
                              int& opcode, RerrMsg& emsg);
      virtual bool  SpaceBack(size_t nrec, size_t& ndone, 
                              int& opcode, RerrMsg& emsg);
      virtual bool  Rewind(int& opcode, RerrMsg& emsg);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // some constants (also defined in cpp)
      static const uint32_t kMetaEof = 0x00000000; //!< EOF marker
      static const uint32_t kMetaEom = 0xffffffff; //!< EOM marker
      static const uint32_t kMeta_M_Perr = 0x80000000;
      static const uint32_t kMeta_M_Mbz  = 0x7fff0000;
      static const uint32_t kMeta_B_Rlen = 0x0000ffff;

    protected:
      bool          Seek(size_t seekpos, int dir, RerrMsg& emsg);
      bool          Read(size_t nbyt, uint8_t* data, RerrMsg& emsg);
      bool          Write(size_t nbyt, const uint8_t* data, bool back,
                          RerrMsg& emsg);
      bool          CheckSizeForw(size_t nbyt, const char* text, RerrMsg& emsg);
      bool          CheckSizeBack(size_t nbyt, const char* text, RerrMsg& emsg);
      void          UpdatePos(size_t nbyt, int dir);
      bool          ParseMeta(uint32_t meta, size_t& rlen, bool& perr, 
                              RerrMsg& emsg);
      size_t        BytePadding(size_t rlen);
      bool          SetBad();
      bool          BadTapeMsg(const char* meth, RerrMsg& emsg);
      void          IncPosRecord(int delta);

    protected:
      RfileFd       fFd;                    //!< file number
      size_t        fSize;                  //!< file size
      size_t        fPos;                   //!< file position
      bool          fBad;                   //!< BAD file format flag
      bool          fPadOdd;                //!< do odd byte padding
      bool          fTruncPend;             //!< truncate on next write
  };
  
} // end namespace Retro

#include "Rw11VirtTapeTap.ipp"

#endif
