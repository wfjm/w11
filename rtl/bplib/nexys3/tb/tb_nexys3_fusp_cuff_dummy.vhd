-- $Id: tb_nexys3_fusp_cuff_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_nexys3_fusp_cuff_dummy
-- Description:    Configuration for tb_nexys3_fusp_dummy for tb_nexys3_fusp
--
-- Dependencies:   nexys3_fusp_dummy [UUT]
--
-- To test:        tb_nexys3_fusp
--
-- Tool versions:  xst 13.1; ghdl 0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-04-21   509   1.0    Initial version (derived frm tb_nexys3_fusp_dummy)
------------------------------------------------------------------------------

configuration tb_nexys3_fusp_cuff_dummy of tb_nexys3_fusp_cuff is

  for sim
    for all : nexys3_fusp_cuff_aif
      use entity work.nexys3_fusp_cuff_dummy;
    end for;
  end for;

end tb_nexys3_fusp_cuff_dummy;
