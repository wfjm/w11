-- $Id: tb_tst_mig_arty.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_tst_mig_arty
-- Description:    Configuration for tb_tst_mig_arty for tb_arty_dram
--
-- Dependencies:   sys_tst_mig_arty
--
-- To test:        sys_tst_mig_arty
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-23  1092   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_mig_arty of tb_arty_dram is

  for sim
    for all : arty_dram_aif
      use entity work.sys_tst_mig_arty;
    end for;
  end for;

end tb_tst_mig_arty;
