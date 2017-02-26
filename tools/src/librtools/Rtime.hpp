// $Id: Rtime.hpp 853 2017-02-19 18:54:30Z mueller $
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
// 2017-02-19   853   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rtime.hpp 853 2017-02-19 18:54:30Z mueller $
  \brief   Declaration of class Rtime .
*/

#ifndef included_Retro_Rtime
#define included_Retro_Rtime 1

#include <time.h>

#include <ostream>
#include <string>

namespace Retro {
  
  class Rtime {
    public: 
		    Rtime();
     explicit       Rtime(clockid_t clkid);
     explicit       Rtime(double dt);
                   ~Rtime();

      void          GetClock(clockid_t clkid);
      void          SetSec(time_t sec);
      void          SetNSec(long nsec);
      void          Set(const struct timespec& ts);
      void          Set(double dt);
      void          Clear();

      bool          IsZero() const;
      bool          IsPositive() const;
      bool          IsNegative() const;

      time_t        Sec() const;
      long          NSec() const;
      const struct timespec&  Timespec() const;
      int           ToMSec() const;  
      double        ToDouble() const;
      std::string   ToString() const;
      double        Age(clockid_t clkid) const;

      void          Print(std::ostream& os) const;
      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;

      explicit      operator double() const;

      Rtime&        operator+=(const Rtime& rhs);
      Rtime&        operator-=(const Rtime& rhs);

      bool          operator==(const Rtime& rhs);
      bool          operator!=(const Rtime& rhs);
      bool          operator<(const Rtime& rhs);
      bool          operator<=(const Rtime& rhs);
      bool          operator>(const Rtime& rhs);
      bool          operator>=(const Rtime& rhs);

    protected:
      void          Fixup();
      
    private:
      struct timespec fTime;                //!< time
  };

  Rtime             operator+(const Rtime& x, const Rtime& y);
  Rtime             operator-(const Rtime& x, const Rtime& y);

  std::ostream&     operator<<(std::ostream& os, const Rtime& obj);

} // end namespace Retro

#include "Rtime.ipp"

#endif
