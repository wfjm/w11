// $Id: RlinkPortTerm.cpp 435 2011-12-04 20:15:25Z mueller $
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
// 2011-12-04   435   1.0.2  Open(): add cts attr, hw flow control now optional
// 2011-07-04   388   1.0.1  add termios readback and verification
// 2011-03-27   374   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPortTerm.cpp 435 2011-12-04 20:15:25Z mueller $
  \brief   Implemenation of RlinkPortTerm.
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <termios.h>

#include "RlinkPortTerm.hpp"

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"

using namespace std;
using namespace Retro;

/*!
  \class Retro::RlinkPortTerm
  \brief FIXME_text
*/

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkPortTerm::RlinkPortTerm()
  : RlinkPort()
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkPortTerm::~RlinkPortTerm()
{
  if (IsOpen()) RlinkPortTerm::Close();
}

//------------------------------------------+-----------------------------------
//! FIXME_text

bool RlinkPortTerm::Open(const std::string& url, RerrMsg& emsg)
{
  if (IsOpen()) Close();

  if (!ParseUrl(url, "|baud=|break|cts|", emsg)) return false;

  speed_t speed = B115200;
  string baud;
  if (UrlFindOpt("baud", baud)) {
    speed = B0;
    if (baud=="9600")                     speed = B9600;
    if (baud=="19200"   || baud=="19k")   speed = B19200;
    if (baud=="38400"   || baud=="38k")   speed = B38400;
    if (baud=="57600"   || baud=="57k")   speed = B57600;
    if (baud=="115200"  || baud=="115k")  speed = B115200;
    if (baud=="230400"  || baud=="230k")  speed = B230400;
    if (baud=="460800"  || baud=="460k")  speed = B460800;
    if (baud=="500000"  || baud=="500k")  speed = B500000;
    if (baud=="921600"  || baud=="921k")  speed = B921600;
    if (baud=="1000000" || baud=="1M")    speed = B1000000;
    if (baud=="2000000" || baud=="2M")    speed = B2000000;
    if (baud=="3000000" || baud=="3M")    speed = B3000000;
    if (speed == B0) {
      emsg.Init("RlinkPortTerm::Open()", 
                string("invalid baud rate \"") + baud + string("\" specified"));
      return false;
    }
  }

  int fd;

  fd = open(fPath.c_str(), O_RDWR|O_NOCTTY);
  if (fd < 0) {
    emsg.InitErrno("RlinkPortTerm::Open()", 
                   string("open() for \"") + fPath + string("\" failed: "),
                   errno);
    return false;
  }

  if (!isatty(fd)) {
    emsg.Init("RlinkPortTerm::Open()", 
              string("isatty() check for \"") + fPath + 
              string("\" failed: not a TTY"));
    close(fd);
    return false;
  }

  if (tcgetattr(fd, &fTiosOld) != 0) {
    emsg.InitErrno("RlinkPortTerm::Open()", 
                   string("tcgetattr() for \"") + fPath + string("\" failed: "),
                   errno);
    close(fd);
    return false;
  }

  fTiosNew = fTiosOld;

  fTiosNew.c_iflag = IGNBRK |               // ignore breaks on input
                     IGNPAR;                // ignore parity errors

  fTiosNew.c_oflag = 0;

  fTiosNew.c_cflag = CS8 |                  // 8 bit chars
                     CSTOPB |               // 2 stop bits
                     CREAD |                // enable receiver
                     CLOCAL;                // ignore modem control
  if (UrlFindOpt("cts")) {
    fTiosNew.c_cflag |= CRTSCTS;            // enable hardware flow control
  }

  fTiosNew.c_lflag = 0;

  if (cfsetspeed(&fTiosNew, speed) != 0) {
    emsg.InitErrno("RlinkPortTerm::Open()", 
                   string("cfsetspeed() for \"") + baud + string("\" failed: "),
                   errno);
    close(fd);
    return false;
  }

  fTiosNew.c_cc[VEOF]   = 0;                // undef
  fTiosNew.c_cc[VEOL]   = 0;                // undef
  fTiosNew.c_cc[VERASE] = 0;                // undef
  fTiosNew.c_cc[VINTR]  = 0;                // undef
  fTiosNew.c_cc[VKILL]  = 0;                // undef
  fTiosNew.c_cc[VQUIT]  = 0;                // undef
  fTiosNew.c_cc[VSUSP]  = 0;                // undef
  fTiosNew.c_cc[VSTART] = 0;                // undef
  fTiosNew.c_cc[VSTOP]  = 0;                // undef
  fTiosNew.c_cc[VMIN]   = 1;                // wait for 1 char
  fTiosNew.c_cc[VTIME]  = 0;                // 

  if (tcsetattr(fd, TCSANOW, &fTiosNew) != 0) {
    emsg.InitErrno("RlinkPortTerm::Open()", 
                   string("tcsetattr() for \"") + fPath + string("\" failed: "),
                   errno);
    close(fd);
    return false;
  }

  // tcsetattr() returns success if any of the requested changes could be
  // successfully carried out. Therefore the termios structure is read back
  // and verified.

  struct termios tios;
  if (tcgetattr(fd, &tios) != 0) {
    emsg.InitErrno("RlinkPortTerm::Open()", 
                   string("2nd tcgetattr() for \"") + fPath + 
                     string("\" failed: "), 
                   errno);
    close(fd);
    return false;
  }

  const char* pmsg = 0;
  if (tios.c_iflag != fTiosNew.c_iflag) pmsg = "c_iflag";
  if (tios.c_oflag != fTiosNew.c_oflag) pmsg = "c_oflag";
  if (tios.c_cflag != fTiosNew.c_cflag) pmsg = "c_cflag";
  if (tios.c_lflag != fTiosNew.c_lflag) pmsg = "c_lflag";
  if (cfgetispeed(&tios) != speed)      pmsg = "ispeed";
  if (cfgetospeed(&tios) != speed)      pmsg = "ospeed";
  for (int i=0; i<NCCS; i++) {
    if (tios.c_cc[i] != fTiosNew.c_cc[i]) pmsg = "c_cc char";
  }

  if (pmsg) {
    emsg.Init("RlinkPortTerm::Open()",
              string("tcsetattr() failed to set") +
                string(pmsg));
    close(fd);
    return false;
  }

  fFdWrite = fd;
  fFdRead  = fd;
  fIsOpen  = true;

  if (UrlFindOpt("break")) {
    if (tcsendbreak(fd, 0) != 0) {
      emsg.InitErrno("RlinkPortTerm::Open()", 
                     string("tcsendbreak() for \"") + fPath + 
                     string("\" failed: "), errno);
      Close();
      return false;
    }
    uint8_t buf[1];
    buf[0] = 0x80;
    if (Write(buf, 1, emsg) != 1) {
      Close();
      return false;      
    }
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

void RlinkPortTerm::Close()
{
  if (fIsOpen) {
    if (fFdWrite >= 0) {
      tcflush(fFdWrite, TCIOFLUSH);
      tcsetattr(fFdWrite, TCSANOW, &fTiosOld);
    }
    RlinkPort::Close();
  }
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_text

void RlinkPortTerm::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkPortTerm @ " << this << endl;
  DumpTios(os, ind, "fTiosOld", fTiosOld);
  DumpTios(os, ind, "fTiosNew", fTiosNew);
  RlinkPort::Dump(os, ind+2, "");
  return;
}
  

//------------------------------------------+-----------------------------------
//! FIXME_text

void RlinkPortTerm::DumpTios(std::ostream& os, int ind, const std::string& name,
                             const struct termios& tios) const
{
  RosFill bl(ind+2);
  os << bl << name << ":" << endl;
  os << bl << "  c_iflag : " << RosPrintf(tios.c_iflag,"x0",8);
  if (tios.c_iflag & BRKINT) os << " BRKINT";
  if (tios.c_iflag & ICRNL)  os << " ICRNL ";
  if (tios.c_iflag & IGNBRK) os << " IGNBRK";
  if (tios.c_iflag & IGNCR)  os << " IGNCR ";
  if (tios.c_iflag & IGNPAR) os << " IGNPAR";
  if (tios.c_iflag & INLCR)  os << " INLCR ";
  if (tios.c_iflag & INPCK)  os << " INPCK ";
  if (tios.c_iflag & ISTRIP) os << " ISTRIP";
  if (tios.c_iflag & IXOFF)  os << " IXOFF ";
  if (tios.c_iflag & IXON)   os << " IXON  ";
  if (tios.c_iflag & PARMRK) os << " PARMRK";
  os << endl;

  os << bl << "  c_oflag : " << RosPrintf(tios.c_oflag,"x0",8);
  if (tios.c_oflag & OPOST)  os << " OPOST ";
  os << endl;

  os << bl << "  c_cflag : " << RosPrintf(tios.c_cflag,"x0",8);
  if (tios.c_cflag & CLOCAL) os << " CLOCAL";
  if (tios.c_cflag & CREAD)  os << " CREAD ";
  if ((tios.c_cflag & CSIZE) == CS5)  os << " CS5   ";
  if ((tios.c_cflag & CSIZE) == CS6)  os << " CS6   ";
  if ((tios.c_cflag & CSIZE) == CS7)  os << " CS7   ";
  if ((tios.c_cflag & CSIZE) == CS8)  os << " CS8   ";
  if (tios.c_cflag & CSTOPB) os << " CSTOPB";
  if (tios.c_cflag & HUPCL)  os << " HUPCL ";
  if (tios.c_cflag & PARENB) os << " PARENB";
  if (tios.c_cflag & PARODD) os << " PARODD";
  speed_t speed = cfgetispeed(&tios);
  int baud = 0;
  if (speed == B9600)    baud =    9600;
  if (speed == B19200)   baud =   19200;
  if (speed == B38400)   baud =   38400;
  if (speed == B57600)   baud =   57600;
  if (speed == B115200)  baud =  115200;
  if (speed == B230400)  baud =  230400;
  if (speed == B460800)  baud =  460800;
  if (speed == B500000)  baud =  500000;
  if (speed == B921600)  baud =  921600;
  if (speed == B1000000) baud = 1000000;
  if (speed == B2000000) baud = 2000000;
  if (speed == B3000000) baud = 3000000;
  os << " speed: " << RosPrintf(baud, "d", 7);
  os << endl;

  os << bl << "  c_lflag : " << RosPrintf(tios.c_lflag,"x0",8);
  if (tios.c_lflag & ECHO)   os << " ECHO  ";
  if (tios.c_lflag & ECHOE)  os << " ECHOE ";
  if (tios.c_lflag & ECHOK)  os << " ECHOK ";
  if (tios.c_lflag & ECHONL) os << " ECHONL";
  if (tios.c_lflag & ICANON) os << " ICANON";
  if (tios.c_lflag & IEXTEN) os << " IEXTEN";
  if (tios.c_lflag & ISIG)   os << " ISIG  ";
  if (tios.c_lflag & NOFLSH) os << " NOFLSH";
  if (tios.c_lflag & TOSTOP) os << " TOSTOP";
  os << endl;

  os << bl << "  c_cc    : " << endl;
  os << bl << "    [VEOF]  : " << RosPrintf(tios.c_cc[VEOF],"o",3);
  os       << "    [VEOL]  : " << RosPrintf(tios.c_cc[VEOL],"o",3);
  os       << "    [VERASE]: " << RosPrintf(tios.c_cc[VERASE],"o",3);
  os       << "    [VINTR] : " << RosPrintf(tios.c_cc[VINTR],"o",3)  << endl;
  os << bl << "    [VKILL] : " << RosPrintf(tios.c_cc[VKILL],"o",3);
  os       << "    [VQUIT] : " << RosPrintf(tios.c_cc[VQUIT],"o",3);
  os       << "    [VSUSP] : " << RosPrintf(tios.c_cc[VSUSP],"o",3);
  os       << "    [VSTART]: " << RosPrintf(tios.c_cc[VSTART],"o",3) << endl;
  os << bl << "    [VSTOP] : " << RosPrintf(tios.c_cc[VSTOP],"o",3);
  os       << "    [VMIN]  : " << RosPrintf(tios.c_cc[VMIN],"o",3);
  os       << "    [VTIME] : " << RosPrintf(tios.c_cc[VTIME],"o",3)  << endl;

  return;
}

//------------------------------------------+-----------------------------------
#if (defined(Retro_NoInline) || defined(Retro_RlinkPortTerm_NoInline))
#define inline
//#include "RlinkPortTerm.ipp"
#undef  inline
#endif
