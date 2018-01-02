-- $Id: tb_tst_sram_c7.vhd 984 2018-01-02 20:56:27Z mueller $
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
-- Module Name:    tb_tst_sram_c7
-- Description:    Configuration for tb_tst_sram_c7 for tb_cmoda7_sram
--
-- Dependencies:   sys_tst_sram_c7
--
-- To test:        sys_tst_sram_c7
--
-- Verified:
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2013-??-??   534  -     0.29  13.1   O40d  xc6slx16   ???
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-06-11   912   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_sram_c7 of tb_cmoda7_sram is

  for sim
    for all : cmoda7_sram_aif
      use entity work.sys_tst_sram_c7;
    end for;
  end for;

end tb_tst_sram_c7;
