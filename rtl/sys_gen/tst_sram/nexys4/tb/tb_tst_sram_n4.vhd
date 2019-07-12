-- $Id: tb_tst_sram_n4.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_tst_sram_n4
-- Description:    Configuration for tb_tst_sram_n4 for tb_nexys4_cram
--
-- Dependencies:   sys_tst_sram_n4
--
-- To test:        sys_tst_sram_n4
--
-- Verified:
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2013-??-??   534  -     0.29  13.1   O40d  xc6slx16   ???
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-06   643   1.1    use tb_nexys4_cram now
-- 2013-09-21   534   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_sram_n4 of tb_nexys4_cram is

  for sim
    for all : nexys4_cram_aif
      use entity work.sys_tst_sram_n4;
    end for;
  end for;

end tb_tst_sram_n4;
