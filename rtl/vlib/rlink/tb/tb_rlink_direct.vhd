-- $Id: tb_rlink_direct.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_rlink_direct
-- Description:    Configuration for tb_rlink_direct for tb_rlink.
--
-- Dependencies:   tbd_rlink_gen
--
-- To test:        rlink_core
--
-- Target Devices: generic
--
-- Verified (with tb_rlink_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2007-11-02    93  _tsim 0.26  8.2.03 I34   xc3s1000   d:ok
-- 2007-10-12    88  _ssim 0.26  8.1.03 I27   xc3s1000   c:ok
-- 2007-10-12    88  -     0.26  -            -          c:ok
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2007-11-25    98   1.0.1  use entity rather arch name to switch core/serport
-- 2007-07-08    65   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_rlink_direct of tb_rlink is

  for sim
    for all : tbd_rlink_gen
      use entity work.tbd_rlink_direct;
    end for;
  end for;

end tb_rlink_direct;
