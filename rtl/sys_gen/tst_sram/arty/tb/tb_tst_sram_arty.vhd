-- $Id: tb_tst_sram_arty.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
