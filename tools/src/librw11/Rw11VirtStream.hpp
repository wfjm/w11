// $Id: Rw11VirtStream.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-04-14  1131   1.1.1  add Error(),Eof()
// 2018-12-02  1076   1.1    use unique_ptr for New()
// 2017-04-07   868   1.0.1  Dump(): add detail arg
// 2013-05-04   515   1.0    Initial version
// 2013-05-01   513   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of class Rw11VirtStream.
*/

#ifndef included_Retro_Rw11VirtStream
#define included_Retro_Rw11VirtStream 1

#include <stdio.h>

#include <memory>

#include "Rw11Virt.hpp"

namespace Retro {

  class Rw11VirtStream : public Rw11Virt {
    public:

      explicit      Rw11VirtStream(Rw11Unit* punit);
                   ~Rw11VirtStream();

      virtual bool  Open(const std::string& url, RerrMsg& emsg);
      int           Read(uint8_t* data, size_t count, RerrMsg& emsg);
      bool          Write(const uint8_t* data, size_t count, RerrMsg& emsg);
      bool          Flush(RerrMsg& emsg);
      int           Tell(RerrMsg& emsg);
      bool          Seek(int pos, RerrMsg& emsg);
      bool          Error() const;
      bool          Eof() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

      static std::unique_ptr<Rw11VirtStream> New(const std::string& url,
                                                 Rw11Unit* punit,
                                                 RerrMsg& emsg);

    // statistics counter indices
      enum stats {
        kStatNVSRead = Rw11Virt::kDimStat,
        kStatNVSReadByt,
        kStatNVSWrite,
        kStatNVSWriteByt,
        kStatNVSFlush,
        kStatNVSTell,
        kStatNVSSeek,
        kDimStat
      };    

    protected:
      bool          fIStream;               //!< is input (read only) stream
      bool          fOStream;               //!< is output (write only) stream
      FILE*         fFile;                  //!< file ptr
  };
  
} // end namespace Retro

//#include "Rw11VirtStream.ipp"

#endif
