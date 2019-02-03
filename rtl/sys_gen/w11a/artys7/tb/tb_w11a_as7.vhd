-- $Id: tb_w11a_as7.vhd 1105 2019-01-12 19:52:45Z mueller $
--
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 3, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    tb_w11a_as7
-- Description:    Configuration for tb_w11a_as7 for tb_artys7_dram
--
-- Dependencies:   sys_w11a_as7
--
-- To test:        sys_w11a_as7
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-01-12  1105   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_w11a_as7  of tb_artys7_dram is

  for sim
    for all : artys7_dram_aif
      use entity work.sys_w11a_as7;
    end for;
  end for;

end tb_w11a_as7;
