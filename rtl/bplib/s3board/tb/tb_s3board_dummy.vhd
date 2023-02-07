-- $Id: tb_s3board_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_s3board_dummy
-- Description:    Configuration for tb_s3board_dummy for tb_s3board
--
-- Dependencies:   s3board_dummy [UUT]
--
-- To test:        tb_s3board
--
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
-- 2007-09-23    85   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_s3board_dummy of tb_s3board is

  for sim
    for all : s3board_aif
      use entity work.s3board_dummy;
    end for;
  end for;

end tb_s3board_dummy;
