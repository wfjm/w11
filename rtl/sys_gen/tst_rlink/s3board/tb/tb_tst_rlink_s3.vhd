-- $Id: tb_tst_rlink_s3.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_tst_rlink_s3
-- Description:    Configuration for tb_tst_rlink_s3 for tb_s3board_fusp
--
-- Dependencies:   sys_tst_rlink_s3
--
-- To test:        sys_tst_rlink_s3
--
-- Verified:
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2011-12-22   442  -     0.29  13.1   O40d  xc3s1000   u:ok 
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-22   442   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_rlink_s3 of tb_s3board_fusp is

  for sim
    for all : s3board_fusp_aif
      use entity work.sys_tst_rlink_s3;
    end for;
  end for;

end tb_tst_rlink_s3;
