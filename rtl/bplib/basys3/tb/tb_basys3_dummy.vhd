-- $Id: tb_basys3_dummy.vhd 1368 2023-02-07 09:18:26Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2023- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_basys3_dummy
-- Description:    Configuration for tb_basys3_dummy for tb_basys3
--
-- Dependencies:   basys3_dummy [UUT]
--
-- To test:        tb_basys3
--
-- Tool versions:  viv 2022.1; ghdl 2.0.0
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2023-02-07  1368   1.0    Initial version (derived from tb_cmoda7_dummy)
------------------------------------------------------------------------------

configuration tb_basys3_dummy of tb_basys3 is

  for sim
    for all : basys3_aif
      use entity work.basys3_dummy;
    end for;
  end for;

end tb_basys3_dummy;
