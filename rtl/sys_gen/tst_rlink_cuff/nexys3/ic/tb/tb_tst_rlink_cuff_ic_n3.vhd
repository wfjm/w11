-- $Id: tb_tst_rlink_cuff_ic_n3.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_tst_rlink_cuff_ic_n3
-- Description:    Configuration for tb_tst_rlink_cuff_ic_n3 for
--                   tb_nexys3_fusp_cuff
--
-- Dependencies:   sys_tst_rlink_cuff_n3   (fx2_type = 'ic2')
--
-- To test:        sys_tst_rlink_cuff_n3   (fx2_type = 'ic2')
--
-- Verified:
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2013-01-xx   xxx  -     0.29  13.3   O76d  xc6slx16-2 u:???
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-04-27   512   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_rlink_cuff_ic_n3 of tb_nexys3_fusp_cuff is

  for sim
    for all : nexys3_fusp_cuff_aif
      use entity work.sys_tst_rlink_cuff_n3;
    end for;
  end for;

end tb_tst_rlink_cuff_ic_n3;
