-- $Id: tb_arty_dram_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_arty_dram_dummy
-- Description:    Configuration for tb_arty_dram_dummy for tb_arty_dram
--
-- Dependencies:   arty_dram_dummy [UUT]
--
-- To test:        tb_arty_dram
--
-- Tool versions:  viv 2017.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-10-28  1063   1.0    Initial version (derived from tb_arty_dummy)
------------------------------------------------------------------------------

configuration tb_arty_dram_dummy of tb_arty_dram is

  for sim
    for all : arty_dram_aif
      use entity work.arty_dram_dummy;
    end for;
  end for;

end tb_arty_dram_dummy;
