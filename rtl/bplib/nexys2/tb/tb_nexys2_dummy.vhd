-- $Id: tb_nexys2_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_nexys2_dummy
-- Description:    Configuration for tb_nexys2_dummy for tb_nexys2
--
-- Dependencies:   nexys2_dummy [UUT]
--
-- To test:        tb_nexys2
--
-- Tool versions:  xst 11.4, 12.1; ghdl 0.26-0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-05-23   294   1.0    Initial version (derived from tb_s3board_dummy)
------------------------------------------------------------------------------

configuration tb_nexys2_dummy of tb_nexys2 is

  for sim
    for all : nexys2_aif
      use entity work.nexys2_dummy;
    end for;
  end for;

end tb_nexys2_dummy;
