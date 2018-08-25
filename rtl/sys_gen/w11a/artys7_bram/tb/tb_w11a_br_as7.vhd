-- $Id: tb_w11a_br_as7.vhd 1038 2018-08-11 12:39:52Z mueller $
--
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_w11a_br_as7
-- Description:    Configuration for tb_w11a_br_as7 for tb_artys7
--
-- Dependencies:   sys_w11a_br_as7
--
-- To test:        sys_w11a_br_as7
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-08-11  1038   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_w11a_br_as7  of tb_artys7 is

  for sim
    for all : artys7_aif
      use entity work.sys_w11a_br_as7;
    end for;
  end for;

end tb_w11a_br_as7;
