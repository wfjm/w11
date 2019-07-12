-- $Id: tb_rlink_tba_pdp11core.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_rlink_tba_pdp11core
-- Description:    Configuration for tb_rlink_tba_pdp11core for tb_rlink_tba.
--
-- Dependencies:   tbd_tba_pdp11core
--
-- To test:        pdp11_core_rbus
--                 pdp11_core
--
-- Verified (with tb_rlink_tba_pdp11core_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2010-12-30   351  _ssim 0.29  12.1         xc3s1000   c:ok
-- 2010-12-30   351  -     0.29  -                       c:ok
-- 2007-10-12    88  _ssim 0.26  8.1.03 I27   xc3s1000   c:ok
-- 2007-10-12    88  -     0.26  -            -          c:ok
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-12-30   351   1.1    renamed from tb_rritba_pdp11core 
-- 2007-08-10    72   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_rlink_tba_pdp11core of tb_rlink_tba is

  for sim
    for all : rbtba_aif
      use entity work.tbd_tba_pdp11core;
    end for;
  end for;

end tb_rlink_tba_pdp11core;
