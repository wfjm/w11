-- $Id: tb_tst_sram_n4d.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_tst_sram_n4d
-- Description:    Configuration for tb_tst_sram_n4d for tb_nexys4d_dram
--
-- Dependencies:   sys_tst_sram_n4d
--
-- To test:        sys_tst_sram_n4d
--
-- Verified:
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2013-??-??   534  -     0.29  13.1   O40d  xc6slx16   ???
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-30  1099   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_sram_n4d of tb_nexys4d_dram is

  for sim
    for all : nexys4d_dram_aif
      use entity work.sys_tst_sram_n4d;
    end for;
  end for;

end tb_tst_sram_n4d;
