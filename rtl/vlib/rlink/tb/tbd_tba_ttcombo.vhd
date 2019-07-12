-- $Id: tbd_tba_ttcombo.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tbd_tba_ttcombo - syn
-- Description:    rbtba_aif wrapper for test target
--
-- Dependencies:   rbd_tester
--                 rbd_bram
--                 rbd_rbmon
--                 rb_sres_or_4
--
-- Test bench:     tb/tb_rlink_tba_ttcombo
--
-- Target Devices: generic
--
-- Synthesised (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-12-29   351 12.1    M53d xc3s1000-4   192  538   32  342 s 10.1
-- 2010-12-23   347 12.1    M53d xc3s1000-4    78  204   32  133 s  8.1
--
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-06-02  1159   4.0.1  use rbaddr_ constants
-- 2014-09-13   593   4.0    use new rlink v4 iface and 4 bit STAT; new addr
-- 2014-08-15   583   3.5    rb_mreq addr now 16 bit
-- 2011-11-22   432   3.1.2  now numeric_std clean
-- 2010-12-29   351   3.1.1  moved in from rbus/rbd_ttcombo; port to rbtba_aif
-- 2010-12-26   349   3.1    add rbd_bram and rbd_rbmon
-- 2010-12-23   347   3.0    rename rrirp_ttcombo->rbd_ttcombo; essentially a
--                           rewrite, use rbd_tester;
-- ----------                old V2 and V1 history removed
-- 2007-08-16    74   1.0    Initial version 
------------------------------------------------------------------------------
--
-- address layout:
--
--   rbd_rbmon     ffe8/8  -- default
--   rbd_tester    ffe0/8  -- default
--   rbd_bram      fe00/2
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.rbdlib.all;

entity rbd_tba_ttcombo is               -- rbtba_aif wrapper for test target
                                        -- implements rbtba_aif
  port (
    CLK  : in slbit;                    -- clock
    RESET  : in slbit;                  -- reset
    RB_MREQ_aval : in slbit;            -- rbus: request - aval
    RB_MREQ_re : in slbit;              -- rbus: request - re
    RB_MREQ_we : in slbit;              -- rbus: request - we
    RB_MREQ_initt : in slbit;           -- rbus: request - init; avoid name coll
    RB_MREQ_addr : in slv16;            -- rbus: request - addr
    RB_MREQ_din : in slv16;             -- rbus: request - din
    RB_SRES_ack : out slbit;            -- rbus: response - ack
    RB_SRES_busy : out slbit;           -- rbus: response - busy
    RB_SRES_err : out slbit;            -- rbus: response - err
    RB_SRES_dout : out slv16;           -- rbus: response - dout
    RB_LAM : out slv16;                 -- rbus: look at me
    RB_STAT : out slv4                  -- rbus: status flags
  );
end entity rbd_tba_ttcombo;


architecture syn of rbd_tba_ttcombo is
    
  signal RB_SRES_TEST  : rb_sres_type := rb_sres_init;
  signal RB_SRES_BRAM  : rb_sres_type := rb_sres_init;
  signal RB_SRES_MON   : rb_sres_type := rb_sres_init;

  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;
  
begin
  
  RB_MREQ.aval <= RB_MREQ_aval;
  RB_MREQ.re   <= RB_MREQ_re;
  RB_MREQ.we   <= RB_MREQ_we;
  RB_MREQ.init <= RB_MREQ_initt;
  RB_MREQ.addr <= RB_MREQ_addr;
  RB_MREQ.din  <= RB_MREQ_din;

  RB_SRES_ack  <= RB_SRES.ack;
  RB_SRES_busy <= RB_SRES.busy;
  RB_SRES_err  <= RB_SRES.err;
  RB_SRES_dout <= RB_SRES.dout;

  TEST: rbd_tester
    generic map (
      RB_ADDR => rbaddr_tester)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES_TEST,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT
    );
  
  MON: rbd_rbmon
    generic map (
      RB_ADDR => rbaddr_rbmon,
      AWIDTH  => 9)
    port map (
      CLK         => CLK,
      RESET       => RESET,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_MON,
      RB_SRES_SUM => RB_SRES
    );
  
  BRAM: rbd_bram
    generic map (
      RB_ADDR => x"fe00")
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES_BRAM
    );
  
  RB_SRES_OR : rb_sres_or_4
    port map (
      RB_SRES_1  => RB_SRES_TEST,
      RB_SRES_2  => RB_SRES_BRAM,
      RB_SRES_3  => RB_SRES_MON,
      RB_SRES_4  => rb_sres_init,
      RB_SRES_OR => RB_SRES
    );
  
end syn;
