-- $Id: tb_tst_rlink_n4d.vhd 984 2018-01-02 20:56:27Z mueller $
--
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_tst_rlink_n4d
-- Description:    Configuration for tb_tst_rlink_n4d for tb_nexys4d
--
-- Dependencies:   sys_tst_rlink_n4d
--
-- To test:        sys_tst_rlink_n4d
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-01-04   838   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_rlink_n4d of tb_nexys4d is

  for sim
    for all : nexys4d_aif
      use entity work.sys_tst_rlink_n4d;
    end for;
  end for;

end tb_tst_rlink_n4d;
