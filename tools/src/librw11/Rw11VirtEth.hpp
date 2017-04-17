// $Id: Rw11VirtEth.hpp 868 2017-04-07 20:09:33Z mueller $
//
// Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-04-07   868   1.0    Initial version
// 2014-06-09   561   0.1    First draft 
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtEth.hpp 868 2017-04-07 20:09:33Z mueller $
  \brief   Declaration of class Rw11VirtEth.
*/

#ifndef included_Retro_Rw11VirtEth
#define included_Retro_Rw11VirtEth 1

#include <memory>

#include "boost/function.hpp"

#include "RethBuf.hpp"

#include "Rw11Virt.hpp"

namespace Retro {

  class Rw11VirtEth : public Rw11Virt {
    public:
      typedef boost::function<bool(std::shared_ptr<RethBuf>&)> rcvcbfo_t;

      explicit      Rw11VirtEth(Rw11Unit* punit);
                   ~Rw11VirtEth();

      virtual const std::string& ChannelId() const;

      void          SetupRcvCallback(const rcvcbfo_t& rcvcbfo);
      virtual bool  Snd(const RethBuf& ebuf, RerrMsg& emsg) = 0;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

      static Rw11VirtEth* New(const std::string& url, Rw11Unit* punit,
                              RerrMsg& emsg);

    // statistics counter indices
      enum stats {
        kStatNVTRcvPoll = Rw11Virt::kDimStat,
        kStatNVTSnd,
        kStatNVTRcvByt,
        kStatNVTSndByt,
        kDimStat
      };    

    protected:
      std::string   fChannelId;             //!< channel id 
      rcvcbfo_t     fRcvCb;                 //!< receive callback fobj
  };
  
} // end namespace Retro

#include "Rw11VirtEth.ipp"

#endif
