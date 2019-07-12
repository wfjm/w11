-- $Id: tb_w11a_n4d.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_w11a_n4d
-- Description:    Configuration for tb_w11a_n4d for tb_nexys4d_dram
--
-- Dependencies:   sys_w11a_n4d
--
-- To test:        sys_w11a_n4d
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-01-02  1101   1.0    Initial version (cloned from _n4)
------------------------------------------------------------------------------

configuration tb_w11a_n4d of tb_nexys4d_dram is

  for sim
    for all : nexys4d_dram_aif
      use entity work.sys_w11a_n4d;
    end for;
  end for;

end tb_w11a_n4d;
