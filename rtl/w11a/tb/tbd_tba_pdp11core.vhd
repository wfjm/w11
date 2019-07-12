-- $Id: tbd_tba_pdp11core.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2008-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tbd_tba_pdp11core - syn
-- Description:    tbd for testing pdp11_core_rbus plus ibdr_minisys
--
-- Dependencies:   genlib/clkdivce
--                 pdp11_core_rbus
--                 pdp11_core
--                 pdp11_bram
--                 ibus/ibdr_minisys
--                 rbus/rb_sres_or_2
--
-- Test bench:     tb_rlink_tba_pdp11core
--
-- Target Devices: generic
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
--
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.35
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-06-02  1159   1.6.2  use rbaddr_ constants
-- 2018-10-07  1054   1.6.1  drop ITIMER from core
-- 2015-05-09   677   1.6    start/stop/suspend overhaul; reset overhaul
-- 2014-08-28   588   1.5.1  use new rlink v4 iface and 4 bit STAT
-- 2014-08-15   583   1.5    rb_mreq addr now 16 bit
-- 2011-11-18   427   1.4.1  now numeric_std clean
-- 2010-12-30   351   1.4    renamed from tbd_pdp11core_rri; rbv3 port;
-- 2010-10-23   335   1.3.2  rename RRI_LAM->RB_LAM;
-- 2010-06-18   306   1.3.1  rename RB_ADDR->RB_ADDR_CORE, add RB_ADDR_IBUS;
--                           remove pdp11_ibdr_rri
-- 2010-06-11   303   1.3    use IB_MREQ.racc instead of RRI_REQ
-- 2010-05-02   287   1.2.1  rename RP_STAT->RB_STAT,AP_LAM->RB_LAM
-- 2010-05-01   285   1.2    port to rri V2 interface
-- 2009-07-12   233   1.1.4  adapt to ibdr_minisys interface changes
-- 2008-08-22   161   1.1.3  use iblib, ibdlib
-- 2008-04-18   136   1.1.2  add RESET for ibdr_minisys
-- 2008-02-23   118   1.1.1  use sys_conf for bram size
-- 2008-02-17   117   1.1    adapt to em_ core interface; use pdp11_bram
-- 2008-01-20   113   1.0    Initial version (factored out from rrirp_pdp11core,
--                           add rri access to ibdr now)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.genlib.all;
use work.iblib.all;
use work.ibdlib.all;
use work.pdp11.all;
use work.sys_conf.all;
use work.rblib.all;

entity tbd_tba_pdp11core is             -- tbd pdp11_core_rbus plus ibdr_minisys
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
end entity tbd_tba_pdp11core;


architecture syn of tbd_tba_pdp11core is

  signal CE_USEC : slbit := '0';

  signal GRESET : slbit := '0';
  signal CP_CNTL : cp_cntl_type := cp_cntl_init;
  signal CP_ADDR : cp_addr_type := cp_addr_init;
  signal CP_DIN : slv16 := (others=>'0');
  signal CP_STAT : cp_stat_type := cp_stat_init;
  signal CP_DOUT : slv16 := (others=>'0');

  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;

  signal RB_SRES_CPU  : rb_sres_type := rb_sres_init;
  signal RB_SRES_IBD  : rb_sres_type := rb_sres_init;

  signal EI_PRI  : slv3 := (others=>'0');
  signal EI_VECT : slv9_2 := (others=>'0');
  signal EI_ACKM : slbit := '0';

  signal EM_MREQ : em_mreq_type := em_mreq_init;
  signal EM_SRES : em_sres_type := em_sres_init;
  
  signal BRESET  : slbit := '0';
  signal IB_MREQ : ib_mreq_type := ib_mreq_init;
  signal IB_SRES : ib_sres_type := ib_sres_init;

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

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH =>    6,
      USECDIV  =>   50,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => open
    );

  RB2CP : pdp11_core_rbus
    generic map (
      RB_ADDR_CORE => rbaddr_cpu0_core,
      RB_ADDR_IBUS => rbaddr_cpu0_ibus)
    port map (
      CLK => CLK,
      RESET     => RESET,
      RB_MREQ   => RB_MREQ,
      RB_SRES   => RB_SRES_CPU,
      RB_STAT   => RB_STAT,
      RB_LAM    => RB_LAM(0),
      GRESET    => GRESET,
      CP_CNTL   => CP_CNTL,
      CP_ADDR   => CP_ADDR,
      CP_DIN    => CP_DIN,
      CP_STAT   => CP_STAT,
      CP_DOUT   => CP_DOUT
    );

  W11A : pdp11_core
    port map (
      CLK        => CLK,
      RESET      => GRESET,
      CP_CNTL    => CP_CNTL,
      CP_ADDR    => CP_ADDR,
      CP_DIN     => CP_DIN,
      CP_STAT    => CP_STAT,
      CP_DOUT    => CP_DOUT,
      ESUSP_O    => open,
      ESUSP_I    => '0',
      HBPT       => '0',
      EI_PRI     => EI_PRI,
      EI_VECT    => EI_VECT,
      EI_ACKM    => EI_ACKM,
      EM_MREQ    => EM_MREQ,
      EM_SRES    => EM_SRES,
      BRESET     => BRESET,
      IB_MREQ_M  => IB_MREQ,
      IB_SRES_M  => IB_SRES,
      DM_STAT_SE => open,
      DM_STAT_DP => open,
      DM_STAT_VM => open,
      DM_STAT_CO => open
    );
  
  MEM : pdp11_bram
    generic map (
      AWIDTH => sys_conf_bram_awidth)
    port map (
      CLK     => CLK,
      GRESET  => GRESET,
      EM_MREQ => EM_MREQ,
      EM_SRES => EM_SRES
    );
  
  IBDR_SYS : ibdr_minisys
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_USEC,              -- !! in test benches msec = usec !!
      RESET    => GRESET,
      BRESET   => BRESET,
      RB_LAM   => RB_LAM(15 downto 1),
      IB_MREQ  => IB_MREQ,
      IB_SRES  => IB_SRES,
      EI_ACKM  => EI_ACKM,
      EI_PRI   => EI_PRI,
      EI_VECT  => EI_VECT,
      DISPREG  => open
    );  

  RB_SRES_OR : rb_sres_or_2
    port map (
      RB_SRES_1  => RB_SRES_CPU,
      RB_SRES_2  => RB_SRES_IBD,
      RB_SRES_OR => RB_SRES
    );

end syn;
