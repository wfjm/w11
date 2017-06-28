-- $Id: tb_w11a_c7.vhd 914 2017-06-25 06:17:18Z mueller $
--
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    tb_w11a_c7
-- Description:    Configuration for tb_w11a_c7 for tb_crama7_sram
--
-- Dependencies:   sys_w11a_c7
--
-- To test:        sys_w11a_c7
--
-- Verified (with (#1) ../../tb/tb_rritba_pdp11core_stim.dat
--                (#2) ../../tb/tb_pdp11_core_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2017-06-24   914  -     -.--  -            -          -:-- 
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-06-24   914   1.0    Initial version (cloned from _n4)
------------------------------------------------------------------------------

configuration tb_w11a_c7 of tb_cmoda7_sram is

  for sim
    for all : cmoda7_sram_aif
      use entity work.sys_w11a_c7;
    end for;
  end for;

end tb_w11a_c7;
