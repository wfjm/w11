-- $Id: tb_s3board_fusp_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_s3board_fusp_dummy
-- Description:    Configuration for tb_s3board_fusp_dummy for tb_s3board_fusp
--
-- Dependencies:   s3board_fusp_dummy [UUT]
--
-- To test:        tb_s3board_fusp
--
-- Tool versions:  xst 11.4; ghdl 0.26
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-05-16   291   1.0.1  rename tb_s3board_usp_dummy->tb_s3board_fusp_dummy
-- 2010-05-01   286   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_s3board_fusp_dummy of tb_s3board_fusp is

  for sim
    for all : s3board_fusp_aif
      use entity work.s3board_fusp_dummy;
    end for;
  end for;

end tb_s3board_fusp_dummy;
