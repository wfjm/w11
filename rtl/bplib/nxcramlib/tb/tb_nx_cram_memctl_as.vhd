-- $Id: tb_nx_cram_memctl_as.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_nx_cram_memctl_as
-- Description:    Configuration tb_nx_cram_memctl_as for tb_nx_cram_memctl
--
-- Dependencies:   tbd_nx_cram_memctl_as
-- To test:        nx_cram_memctl_as
--
-- Verified (with tb_nx_cram_memctl_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2010-05-30   297  -     0.26  11.4   L68   xc3s1200e  ok
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-26   433   1.1    renamed from tb_n2_cram_memctl_as
-- 2010-05-30   297   1.0    Initial version 
------------------------------------------------------------------------------

configuration tb_nx_cram_memctl_as of tb_nx_cram_memctl is

  for sim
    for all :tbd_nx_cram_memctl
      use entity work.tbd_nx_cram_memctl_as;
    end for;
  end for;

end tb_nx_cram_memctl_as;
