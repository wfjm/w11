-- $Id: tb_arty_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_arty_dummy
-- Description:    Configuration for tb_arty_dummy for tb_arty
--
-- Dependencies:   arty_dummy [UUT]
--
-- To test:        tb_arty
--
-- Tool versions:  viv 2015.4; ghdl 0.33
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-01-31   726   1.0    Initial version (derived from tb_nexys4_dummy)
------------------------------------------------------------------------------

configuration tb_arty_dummy of tb_arty is

  for sim
    for all : arty_aif
      use entity work.arty_dummy;
    end for;
  end for;

end tb_arty_dummy;
