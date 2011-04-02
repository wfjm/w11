// $Id: RlogFile.hpp 357 2011-01-31 08:00:13Z mueller $
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
// 2011-01-30   357   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlogFile.hpp 357 2011-01-31 08:00:13Z mueller $
  \brief   Declaration of class RlogFile.
*/

#ifndef included_Retro_RlogFile
#define included_Retro_RlogFile 1

#include <string>
#include <ostream>
#include <fstream>

namespace Retro {

  class RlogFile {
    public:
                    RlogFile();
      explicit      RlogFile(std::ostream* os);
                    ~RlogFile();

      bool          Open(std::string name);
      void          Close();
      void          UseStream(std::ostream* os);

      std::ostream& operator()();
      std::ostream& operator()(char c);

    protected:
      void          ClearTime();

    protected:
      std::ostream* fpExtStream;            //!< pointer to external stream
      std::ofstream fIntStream;             //!< internal stream
      int           fTagYear;               //!< year of last time tag
      int           fTagMonth;              //!< month of last time tag
      int           fTagDay;                //!< day of last time tag

    // RlogFile is not copy or assignable
    private:
                    RlogFile(const RlogFile& rhs);
      RlogFile&     operator=(const RlogFile& rhs);


  };
  
} // end namespace Retro

#if !(defined(Retro_NoInline) || defined(Retro_RlogFile_NoInline))
#include "RlogFile.ipp"
#endif

#endif
