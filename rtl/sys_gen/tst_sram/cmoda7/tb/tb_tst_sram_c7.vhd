-- $Id: tb_tst_sram_c7.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
