-- $Id: tb_tst_rlink_n4.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_tst_rlink_n4
-- Description:    Configuration for tb_tst_rlink_n4 for tb_nexys4
--
-- Dependencies:   sys_tst_rlink_n4
--
-- To test:        sys_tst_rlink_n4
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-01   641   1.1    use plain tb_nexys4 now
-- 2013-09-28   535   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_tst_rlink_n4 of tb_nexys4 is

  for sim
    for all : nexys4_aif
      use entity work.sys_tst_rlink_n4;
    end for;
  end for;

end tb_tst_rlink_n4;
