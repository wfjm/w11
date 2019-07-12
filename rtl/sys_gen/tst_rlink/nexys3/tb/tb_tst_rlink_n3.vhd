-- $Id: tb_tst_rlink_n3.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_tst_rlink_n3
-- Description:    Configuration for tb_tst_rlink_n3 for tb_nexys3_fusp
--
-- Dependencies:   sys_tst_rlink_n3
--
-- To test:        sys_tst_rlink_n3
--
-- Verified:
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2011-11-xx   xxx  -     0.29  13.1   O40d  xc6slx16-2 u:???
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-26   433   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_rlink_n3 of tb_nexys3_fusp is

  for sim
    for all : nexys3_fusp_aif
      use entity work.sys_tst_rlink_n3;
    end for;
  end for;

end tb_tst_rlink_n3;
