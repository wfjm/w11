-- $Id: tb_w11a_br_n4d.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_w11a_br_n4d
-- Description:    Configuration for tb_w11a_br_n4d for tb_nexys4d
--
-- Dependencies:   sys_w11a_br_n4d
--
-- To test:        sys_w11a_br_n4d
--
-- Verified (with (#1) ../../tb/tb_rritba_pdp11core_stim.dat
--                (#2) ../../tb/tb_pdp11_core_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2011-11-25   295  -     -.--  -            -          -:-- 
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-01-04   838   1.0    Initial version (cloned from _br_n4)
------------------------------------------------------------------------------

configuration tb_w11a_br_n4d of tb_nexys4d is

  for sim
    for all : nexys4d_aif
      use entity work.sys_w11a_br_n4d;
    end for;
  end for;

end tb_w11a_br_n4d;
