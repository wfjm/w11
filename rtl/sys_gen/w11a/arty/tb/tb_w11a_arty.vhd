-- $Id: tb_w11a_arty.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_w11a_arty
-- Description:    Configuration for tb_w11a_arty for tb_arty_dram
--
-- Dependencies:   sys_w11a_arty
--
-- To test:        sys_w11a_arty
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-11-17  1071   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_w11a_arty  of tb_arty_dram is

  for sim
    for all : arty_dram_aif
      use entity work.sys_w11a_arty;
    end for;
  end for;

end tb_w11a_arty;
