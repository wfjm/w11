-- $Id: tb_tst_sram_s3.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_tst_sram_s3
-- Description:    Configuration for tb_tst_sram_s3 for tb_s3board
--
-- Dependencies:   sys_tst_sram_s3
--
-- To test:        sys_tst_sram_s3
--
-- Verified:
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2007-12-23   105  _ssim 0.26  8.2.03 I34   xc3s1000   u:ok
-- 2007-12-23   105  -     0.26  8.2.03 I34   -          u:ok
-- 2007-12-21   103  _ssim 0.26  8.1.03 I27   xc3s1000   c:ok
-- 2007-12-21   103  -     0.26  8.1.03 I27   -          c:ok
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-05-23   294   1.0.1  renamed to tb_tst_sram_s3
-- 2007-12-21   103   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_sram_s3 of tb_s3board is

  for sim
    for all : s3board_aif
      use entity work.sys_tst_sram_s3;
    end for;
  end for;

end tb_tst_sram_s3;
