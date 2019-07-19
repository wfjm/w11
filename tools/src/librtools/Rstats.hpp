// $Id: Rstats.hpp 1186 2019-07-12 17:49:59Z mueller $
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright 2011-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// 
// Revision History: 
// Date         Rev Version  Comment
// 2019-06-07  1160   1.0.3  add Reset(); drop operator-=() and operator*=()
// 2017-02-04   865   1.0.2  add NameMaxLength(); Dump(): add detail arg
// 2017-02-18   851   1.0.1  add IncLogHist; fix + and * operator definition
// 2011-02-06   359   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \brief   Declaration of class Rstats .
*/

#ifndef included_Retro_Rstats
#define included_Retro_Rstats 1

#include <cstddef>
#include <cstdint>
#include <string>
#include <vector>
#include <ostream>

namespace Retro {
  
  class Rstats {
    public: 
		    Rstats();
                    Rstats(const Rstats& rhs);
                   ~Rstats();

      void          Define(size_t ind, const std::string& name, 
                           const std::string& text);

      void          Set(size_t ind, double val);
      void          Inc(size_t ind, double val=1.);

      void          Reset();

      void          IncLogHist(size_t ind, size_t maskfirst,
                               size_t masklast, size_t val);

      void          SetFormat(const char* format, int width=0, int prec=0);
    
      size_t        Size() const;
      double        Value(size_t ind) const;
      const std::string&  Name(size_t ind) const;
      const std::string&  Text(size_t ind) const;
      size_t        NameMaxLength() const;

      void          Print(std::ostream& os, const char* format=0, 
                          int width=0, int prec=0) const;
      void          Dump(std::ostream& os, int ind=0, const char* text=0,
                         int detail=0) const;

      double        operator[](size_t ind) const;

      Rstats&       operator=(const Rstats& rhs);

  private:
      std::vector<double> fValue;           //!< counter value
      std::vector<std::string> fName;       //!< counter name
      std::vector<std::string> fText;       //!< counter text
      std::uint32_t fHash;                  //!< hash value for name+text
      std::string   fFormat;                //!< default format for Print
      int           fWidth;                 //!< default width for Print
      int           fPrec;                  //!< default precision for Print
  };

  std::ostream&	    operator<<(std::ostream& os, const Rstats& obj);

} // end namespace Retro

#include "Rstats.ipp"

#endif
