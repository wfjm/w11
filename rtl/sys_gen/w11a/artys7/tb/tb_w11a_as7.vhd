-- $Id: tb_w11a_as7.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_w11a_as7
-- Description:    Configuration for tb_w11a_as7 for tb_artys7_dram
--
-- Dependencies:   sys_w11a_as7
--
-- To test:        sys_w11a_as7
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-01-12  1105   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_w11a_as7  of tb_artys7_dram is

  for sim
    for all : artys7_dram_aif
      use entity work.sys_w11a_as7;
    end for;
  end for;

end tb_w11a_as7;
