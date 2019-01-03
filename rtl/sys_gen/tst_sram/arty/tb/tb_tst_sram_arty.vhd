-- $Id: tb_tst_sram_arty.vhd 1071 2018-11-17 20:53:26Z mueller $
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
-- Module Name:    tb_tst_sram_arty
-- Description:    Configuration for tb_tst_sram_arty for tb_arty_dram
--
-- Dependencies:   sys_tst_sram_arty
--
-- To test:        sys_tst_sram_arty
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-11-17  1071   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_sram_arty of tb_arty_dram is

  for sim
    for all : arty_dram_aif
      use entity work.sys_tst_sram_arty;
    end for;
  end for;

end tb_tst_sram_arty;
