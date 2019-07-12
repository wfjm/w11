-- $Id: tb_rlink_sp1c.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_rlink_sp1c
-- Description:    Configuration for tb_rlink_sp1c for tb_rlink.
--
-- Dependencies:   tbd_rlink_gen
--
-- To test:        rlink_sp1c
--
-- Target Devices: generic
--
-- Verified (with tb_rlink_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2007-10-12    88  _ssim 0.26  8.1.03 I27   xc3s1000   c:ok (Test 15 fails)
-- 2007-10-12    88  -     0.26  -            -          c:ok (Test 15 fails)
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-22   442   3.2    renamed and retargeted to tbd_rlink_sp1c
-- 2010-12-05   343   3.0    rri->rlink renames
-- 2007-11-25    98   1.0.1  use entity rather arch name to switch core/serport
-- 2007-07-08    65   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_rlink_sp1c of tb_rlink is

  for sim
    for all : tbd_rlink_gen
      use entity work.tbd_rlink_sp1c;
    end for;
  end for;

end tb_rlink_sp1c;
