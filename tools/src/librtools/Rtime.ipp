// $Id: Rtime.ipp 887 2017-04-28 19:32:52Z mueller $
//
// Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2017-02-20   854   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \brief   Implemenation (inline) of Rtime.
*/

#include <math.h>

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

inline Rtime::Rtime()
{
  fTime.tv_sec  = 0;
  fTime.tv_nsec = 0;
}

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
//! Destructor

inline Rtime::~Rtime()
{}

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
  fTime.tv_sec  = sec;
  fTime.tv_nsec = nsec - 1.e9*sec;
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
