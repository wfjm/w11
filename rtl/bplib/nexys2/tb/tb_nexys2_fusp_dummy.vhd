-- $Id: tb_nexys2_fusp_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_nexys2_fusp_dummy
-- Description:    Configuration for tb_nexys2_fusp_dummy for tb_nexys2_fusp
--
-- Dependencies:   nexys2_fusp_dummy [UUT]
--
-- To test:        tb_nexys2_fusp
--
-- Tool versions:  xst 11.4, 12.1; ghdl 0.26-0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-05-28   295   1.0    Initial version (derived frm tb_s3board_fusp_dummy)
------------------------------------------------------------------------------

configuration tb_nexys2_fusp_dummy of tb_nexys2_fusp is

  for sim
    for all : nexys2_fusp_aif
      use entity work.nexys2_fusp_dummy;
    end for;
  end for;

end tb_nexys2_fusp_dummy;
