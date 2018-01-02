-- $Id: tb_tst_rlink_arty.vhd 984 2018-01-02 20:56:27Z mueller $
--
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_tst_rlink_arty
-- Description:    Configuration for tb_tst_rlink_arty for tb_arty
--
-- Dependencies:   sys_tst_rlink_arty
--
-- To test:        sys_tst_rlink_arty
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-02-14   731   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_rlink_arty of tb_arty is

  for sim
    for all : arty_aif
      use entity work.sys_tst_rlink_arty;
    end for;
  end for;

end tb_tst_rlink_arty;
