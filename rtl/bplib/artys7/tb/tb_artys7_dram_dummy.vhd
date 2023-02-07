-- $Id: tb_artys7_dram_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_artys7_dram_dummy
-- Description:    Configuration for tb_artys7_dram_dummy for tb_artys7_dram
--
-- Dependencies:   artys7_dram_dummy [UUT]
--
-- To test:        tb_artys7_dram
--
-- Tool versions:  viv 2017.2; ghdl 0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-01-12  11-5   1.0    Initial version (derived from tb_artys7_dummy)
------------------------------------------------------------------------------

configuration tb_artys7_dram_dummy of tb_artys7_dram is

  for sim
    for all : artys7_dram_aif
      use entity work.artys7_dram_dummy;
    end for;
  end for;

end tb_artys7_dram_dummy;
