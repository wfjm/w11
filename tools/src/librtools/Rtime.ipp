// $Id: Rtime.ipp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-22  1091   1.0.2  Drop empty dtors for pod-only classes
//                           Set(): add time_t cast (-Wfloat-conversion fix)
// 2018-12-21  1090   1.0.1  use list-init
// 2017-02-20   854   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Implemenation (inline) of Rtime.
*/

#include <math.h>

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

inline Rtime::Rtime()
  : fTime{0,0}                              // {0,0} to make some gcc happy
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rtime::Rtime(clockid_t clkid)
{
  GetClock(clkid);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rtime::Rtime(double dt)
{
  Set(dt);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rtime::SetSec(time_t sec)
{
  fTime.tv_sec = sec;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rtime::Set(const struct timespec& ts)
{
  fTime = ts;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rtime::Set(double dt)
{
  double nsec = floor(1.e9*dt);
  double  sec = floor(dt);
  fTime.tv_sec  = time_t(sec);
  fTime.tv_nsec = long(nsec - 1.e9*sec);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rtime::Clear()
{
  fTime.tv_sec  = 0;
  fTime.tv_nsec = 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rtime::IsZero() const
{
  return fTime.tv_sec==0 && fTime.tv_nsec==0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rtime::IsPositive() const
{
  return fTime.tv_sec  > 0 || (fTime.tv_sec == 0 && fTime.tv_nsec > 0);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rtime::IsNegative() const
{
  return fTime.tv_sec  < 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline time_t Rtime::Sec() const
{
  return fTime.tv_sec;  
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline long Rtime::NSec() const
{
  return fTime.tv_nsec;  
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const struct timespec& Rtime::Timespec() const
{
  return fTime;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int Rtime::ToMSec() const
{
  // round up here !!
  return 1000*fTime.tv_sec + (fTime.tv_nsec+999999)/1000000;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline double Rtime::ToDouble() const
{
  return double(fTime.tv_sec) + 1.e-9*double(fTime.tv_nsec);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rtime::operator double() const
{
  return ToDouble();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rtime& Rtime::operator+=(const Rtime& rhs)
{
  fTime.tv_sec  += rhs.fTime.tv_sec;
  fTime.tv_nsec += rhs.fTime.tv_nsec;
  Fixup();
  return *this;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Rtime& Rtime::operator-=(const Rtime& rhs)
{
  fTime.tv_sec  -= rhs.fTime.tv_sec;
  fTime.tv_nsec -= rhs.fTime.tv_nsec;
  Fixup();
  return *this;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rtime::operator==(const Rtime& rhs)
{
  return fTime.tv_sec  == rhs.fTime.tv_sec &&
         fTime.tv_nsec == rhs.fTime.tv_nsec;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rtime::operator!=(const Rtime& rhs)
{
  return ! operator==(rhs);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rtime::operator<(const Rtime& rhs)
{
  return fTime.tv_sec  < rhs.fTime.tv_sec || 
         (fTime.tv_sec == rhs.fTime.tv_sec &&
          fTime.tv_nsec < rhs.fTime.tv_nsec);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rtime::operator<=(const Rtime& rhs)
{
  return fTime.tv_sec  < rhs.fTime.tv_sec || 
         (fTime.tv_sec == rhs.fTime.tv_sec &&
          fTime.tv_nsec <= rhs.fTime.tv_nsec);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rtime::operator>(const Rtime& rhs)
{
  return !operator<=(rhs);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rtime::operator>=(const Rtime& rhs)
{
  return !operator<(rhs);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rtime::Fixup()
{
  if (fTime.tv_nsec >= 1000000000) {
    fTime.tv_nsec -= 1000000000;
    fTime.tv_sec  += 1;
  } else if (fTime.tv_nsec < 0) {
    fTime.tv_nsec += 1000000000;
    fTime.tv_sec  -= 1;
  }
  return;
}

//------------------------------------------+-----------------------------------
/*! 
  \relates Rtime
  \brief operator+: Rtime + Rtime.
*/

inline Rtime operator+(const Rtime& x, const Rtime& y)
{
  Rtime res(x);
  res += y;
  return res;
}

//------------------------------------------+-----------------------------------
/*! 
  \relates Rtime
  \brief operator-: Rtime - Rtime.
*/

inline Rtime operator-(const Rtime& x, const Rtime& y)
{
  Rtime res(x);
  res -= y;
  return res;
}

//------------------------------------------+-----------------------------------
/*! 
  \relates Rtime
  \brief ostream insertion operator.
*/

inline std::ostream& operator<<(std::ostream& os, const Rtime& obj)
{
  obj.Print(os);
  return os;
}

} // end namespace Retro
