-- $Id: tb_artys7_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_artys7_dummy
-- Description:    Configuration for tb_artys7_dummy for tb_artys7
--
-- Dependencies:   artys7_dummy [UUT]
--
-- To test:        tb_artys7
--
-- Tool versions:  viv 2017.2-2018.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-08-05  1039   1.0    Initial version (derived from tb_artya7_dummy)
------------------------------------------------------------------------------

configuration tb_artys7_dummy of tb_artys7 is

  for sim
    for all : artys7_aif
      use entity work.artys7_dummy;
    end for;
  end for;

end tb_artys7_dummy;
