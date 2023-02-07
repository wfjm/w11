-- $Id: tb_cmoda7_sram_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_cmoda7_sram_dummy
-- Description:    Configuration for tb_cmoda7_sram_dummy for tb_cmoda7_sram
--
-- Dependencies:   cmoda7_sram_dummy [UUT]
--
-- To test:        tb_cmoda7_sram
--
-- Tool versions:  viv 2016.4; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-06-04   906   1.0    Initial version (derived from tb_nexys4_cram_dummy)
------------------------------------------------------------------------------

configuration tb_cmoda7_sram_dummy of tb_cmoda7_sram is

  for sim
    for all : cmoda7_sram_aif
      use entity work.cmoda7_sram_dummy;
    end for;
  end for;

end tb_cmoda7_sram_dummy;
