-- $Id: tb_tst_sram_n2.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_tst_sram_n2
-- Description:    Configuration for tb_tst_sram_s2 for tb_nexys2
--
-- Dependencies:   sys_tst_sram_n2
--
-- To test:        sys_tst_sram_n2
--
-- Verified:
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2010-05-24   294  -     0.26  11.4   L68   xc3s1200e  u:ok
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-05-24   294   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_sram_n2 of tb_nexys2 is

  for sim
    for all : nexys2_aif
      use entity work.sys_tst_sram_n2;
    end for;
  end for;

end tb_tst_sram_n2;
