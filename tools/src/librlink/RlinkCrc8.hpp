// $Id: RlinkCrc8.hpp 486 2013-02-10 22:34:43Z mueller $
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
// 2011-02-27   365   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkCrc8.hpp 486 2013-02-10 22:34:43Z mueller $
  \brief   Declaration of class \c RlinkCrc8.
*/

#ifndef included_Retro_RlinkCrc8
#define included_Retro_RlinkCrc8 1

#include <cstdint>
#include <vector>

namespace Retro {

  class RlinkCrc8 {
    public:
                    RlinkCrc8();
                   ~RlinkCrc8();

      void          Clear();
      void          AddData(uint8_t data);
      uint8_t       Crc() const;    

    protected: 

      uint8_t       fCrc;                   //!< current crc value
      static const uint8_t fCrc8Table[256];   // doxed in cpp
  };
  
} // end namespace Retro

#include "RlinkCrc8.ipp"

#endif
