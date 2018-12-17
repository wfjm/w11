// $Id: Rw11Rdma.hpp 1084 2018-12-16 12:23:53Z mueller $
//
// Copyright 2015-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2018-12-16  1084   1.1.4  use =delete for noncopyable instead of boost
// 2018-12-15  1083   1.1.3  for std::function setups: use rval ref and move
// 2018-12-14  1081   1.1.2  use std::function instead of boost
// 2017-04-02   865   1.1.1  Dump(): add detail arg
// 2015-02-17   647   1.1    PreExecCB with nwdone and nwnext
// 2015-01-04   627   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \brief   Declaration of class Rw11Rdma.
*/

#ifndef included_Retro_Rw11Rdma
#define included_Retro_Rw11Rdma 1

#include <functional>

#include "librtools/Rstats.hpp"
#include "librtools/RerrMsg.hpp"

#include "librtools/Rbits.hpp"
#include "Rw11Cntl.hpp"

namespace Retro {

  class Rw11Rdma : public Rbits {
    public:

      typedef std::function<void(int,size_t,size_t,
                                 RlinkCommandList&)>  precb_t;
      typedef std::function<void(int,size_t,
                                 RlinkCommandList&,size_t)>  postcb_t;

                    Rw11Rdma(Rw11Cntl* pcntl, precb_t&& precb,
                             postcb_t&& postcb);
      virtual      ~Rw11Rdma();

                    Rw11Rdma(const Rw11Rdma&) = delete;   // noncopyable 
      Rw11Rdma&     operator=(const Rw11Rdma&) = delete;  // noncopyable
    
      Rw11Cntl&     CntlBase() const;
      Rw11Cpu&      Cpu() const;
      Rw11&         W11() const;
      RlinkServer&  Server() const;
      RlinkConnect& Connect() const;
      RlogFile&     LogFile() const;

      void          SetChunkSize(size_t chunk);
      size_t        ChunkSize() const;

      bool          IsActive() const;

      void          QueueRMem(uint32_t addr, uint16_t* block, size_t size,
                              uint16_t mode);
      void          QueueWMem(uint32_t addr, const uint16_t* block, size_t size,
                              uint16_t mode);

      const Rstats& Stats() const;
      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

    // statistics counter indices
      enum stats {
        kStatNQueRMem,                      //!< RMem chains queued
        kStatNQueWMem,                      //!< WMem chains queued
        kStatNRdmaRMem,                     //!< RMem chunks done
        kStatNRdmaWMem,                     //!< WMem chunks done
        kStatNExtClist,                     //!< clist extended
        kStatNFailRdma,                     //!< Rdma failures
        kDimStat
      };    

    // status values
      enum status {
        kStatusDone,                        //!< all chunks done and ok
        kStatusBusy,                        //!< more chunks to come
        kStatusBusyLast,                    //!< last chunk to come
        kStatusFailRdma                     //!< last rdma transfer failed
      };

    protected:
      void          SetupRdma(bool iswmem, uint32_t addr, uint16_t* block,
                              size_t size, uint16_t mode);
      int           RdmaHandler();
      virtual void  PreRdmaHook();
      virtual void  PostRdmaHook(size_t nwdone);

    protected:
      Rw11Cntl*     fpCntlBase;             //!< plain Rw11Cntl ptr
      precb_t       fPreExecCB;             //!< pre Exec callback
      postcb_t      fPostExecCB;            //!< post Exec callback
      size_t        fChunksize;             //!< channel chunk size
      enum status   fStatus;                //!< dma status
      bool          fIsWMem;                //!< is memory write
      uint32_t      fAddr;                  //!< current mem address
      uint16_t      fMode;                  //!< current mode
      size_t        fNWordMax;              //!< transfer chunk size
      size_t        fNWordRest;             //!< words to be done
      size_t        fNWordDone;             //!< words transfered
      uint16_t*     fpBlock;                //!< current buffer pointer
      Rstats        fStats;                 //!< statistics
  };
  
} // end namespace Retro

#include "Rw11Rdma.ipp"

#endif
