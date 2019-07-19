// $Id: RlinkPortCuff.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2012-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-17  1088   1.0.2  use std::thread instead of boost
// 2013-01-02   467   1.0.1  get cleanup code right; add USBErrorName()
// 2012-12-26   465   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \brief   Declaration of class RlinkPortCuff.
*/

#ifndef included_Retro_RlinkPortCuff
#define included_Retro_RlinkPortCuff 1

#include "RlinkPort.hpp"

#include <poll.h>
#include <libusb-1.0/libusb.h>

#include <vector>
#include <deque>
#include <thread>

namespace Retro {

  class RlinkPortCuff : public RlinkPort {
    public:

                    RlinkPortCuff();
      virtual       ~RlinkPortCuff();

      virtual bool  Open(const std::string& url, RerrMsg& emsg);
      virtual void  Close();

    // some constants (also defined in cpp)
      static const size_t kUSBBufferSize  = 4096;  //!< USB buffer size
      static const int    kUSBWriteEP     = 4   ;  //!< USB write endpoint
      static const int    kUSBReadEP      = 6   ;  //!< USB read endpoint
      static const size_t kUSBReadQueue   = 2   ;  //!< USB read queue length

    // statistics counter indices
      enum stats {
        kStatNPollAddCB = RlinkPort::kDimStat,
        kStatNPollRemoveCB,
        kStatNUSBWrite,
        kStatNUSBRead,
        kDimStat
      };

    // event loop states
      enum loopState {
        kLoopStateStopped,
        kLoopStateRunning,
        kLoopStateStopping
      };

    protected:
      int           fFdReadDriver;          //!< fd for read (driver end)
      int           fFdWriteDriver;         //!< fd for write (driver end)
      std::thread   fDriverThread;          //!< driver thread
      libusb_context*  fpUsbContext;
      libusb_device**  fpUsbDevList;
      ssize_t          fUsbDevCount;
      libusb_device_handle* fpUsbDevHdl;
      loopState        fLoopState;
      std::vector<pollfd>   fPollFds;
      std::deque<libusb_transfer*>  fWriteQueueFree;
      std::deque<libusb_transfer*>  fWriteQueuePending;
      std::deque<libusb_transfer*>  fReadQueuePending;

    private:
      void          Cleanup();
      bool          OpenPipe(int& fdread, int& fdwrite, RerrMsg& emsg);
      void          Driver();
      void          DriverEventWritePipe();
      void          DriverEventUSB();
      libusb_transfer* NewWriteTransfer();
      bool          TraceOn();
      [[noreturn]] void BadSysCall(const char* meth, const char* text, int rc);
      [[noreturn]] void BadUSBCall(const char* meth, const char* text, int rc);
      void          CheckUSBTransfer(const char* meth, libusb_transfer *t);
      const char*   USBErrorName(int rc);

      void          PollfdAdd(int fd, short events);
      void          PollfdRemove(int fd);
      void          USBWriteDone(libusb_transfer* t);
      void          USBReadDone(libusb_transfer* t);

      static void   ThunkPollfdAdd(int fd, short events, void* udata);
      static void   ThunkPollfdRemove(int fd, void* udata);
      static void   ThunkUSBWriteDone(libusb_transfer* t);
      static void   ThunkUSBReadDone(libusb_transfer* t);

  };
  
} // end namespace Retro

//#include "RlinkPortCuff.ipp"

#endif
