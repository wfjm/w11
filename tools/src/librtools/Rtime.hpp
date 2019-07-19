// $Id: Rtime.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2017-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2018-12-22  1091   1.0.1  Drop empty dtors for pod-only classes
// 2017-02-19   853   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
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
      explicit      Rtime(clockid_t clkid);
      explicit      Rtime(double dt);

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
