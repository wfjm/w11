-- $Id: tb_nexys4d_dram_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_nexys4d_dram_dummy
-- Description:    Configuration for tb_nexys4d_dram_dummy for tb_nexys4d_dram
--
-- Dependencies:   nexys4d_dram_dummy [UUT]
--
-- To test:        tb_nexys4d_dram
--
-- Tool versions:  viv 2017.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-30  1099   1.0    Initial version (derived from tb_nexys4_dummy)
------------------------------------------------------------------------------

configuration tb_nexys4d_dram_dummy of tb_nexys4d_dram is

  for sim
    for all : nexys4d_dram_aif
      use entity work.nexys4d_dram_dummy;
    end for;
  end for;

end tb_nexys4d_dram_dummy;
