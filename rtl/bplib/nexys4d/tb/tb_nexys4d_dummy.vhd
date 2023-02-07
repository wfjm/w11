-- $Id: tb_nexys4d_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_nexys4d_dummy
-- Description:    Configuration for tb_nexys4d_dummy for tb_nexys4d
--
-- Dependencies:   nexys4d_dummy [UUT]
--
-- To test:        tb_nexys4d
--
-- Tool versions:  viv 2016.2; ghdl 0.33
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-01-04   838   1.0    Initial version (derived from tb_nexys4_dummy)
------------------------------------------------------------------------------

configuration tb_nexys4d_dummy of tb_nexys4d is

  for sim
    for all : nexys4d_aif
      use entity work.nexys4d_dummy;
    end for;
  end for;

end tb_nexys4d_dummy;
