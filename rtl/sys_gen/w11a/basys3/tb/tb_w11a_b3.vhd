-- $Id: tb_w11a_b3.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_w11a_b3
-- Description:    Configuration for tb_w11a_b3 for tb_basys3
--
-- Dependencies:   sys_w11a_b3
--
-- To test:        sys_w11a_b3
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-21   649   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_w11a_b3 of tb_basys3 is

  for sim
    for all : basys3_aif
      use entity work.sys_w11a_b3;
    end for;
  end for;

end tb_w11a_b3;
