-- $Id: tb_nexys4_cram_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_nexys4_cram_dummy
-- Description:    Configuration for tb_nexys4_cram_dummy for tb_nexys4_cram
--
-- Dependencies:   nexys4_cram_dummy [UUT]
--
-- To test:        tb_nexys4_cram
--
-- Tool versions:  ise 14.5-14.7; viv 2014.4; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-06   643   1.1    factor out memory
-- 2013-09-21   534   1.0    Initial version (derived from tb_nexys3_fusp_dummy)
------------------------------------------------------------------------------

configuration tb_nexys4_cram_dummy of tb_nexys4_cram is

  for sim
    for all : nexys4_cram_aif
      use entity work.nexys4_cram_dummy;
    end for;
  end for;

end tb_nexys4_cram_dummy;
