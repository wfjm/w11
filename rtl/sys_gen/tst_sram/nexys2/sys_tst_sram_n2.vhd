-- $Id: sys_tst_sram_n2.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_tst_sram_n2 - syn
-- Description:    test of nexys2 sram and its controller
--
-- Dependencies:   vlib/xlib/dcm_sfs
--                 vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_2line_iob
--                 bplib/bpgen/sn_humanio
--                 vlib/rlink/rlink_sp1c
--                 tst_sram
--                 bplib/nxcramlib/nx_cram_memctl_as
--
-- Test bench:     tb/tb_tst_sram_n2
--
-- Target Devices: generic
-- Tool versions:  xst 11.4-14.7; ghdl 0.29-0.33
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2014-12-20   614 14.7  131013 xc3s1200e-4  878 1881   96 1428 t 11.7 ns (85M)
-- 2014-08-13   581 14.7  131013 xc3s1200e-4  721 1515   64 1119 t 10.5 ns (95M)
-- 2011-12-21   442 13.1    O40d xc3s1200e-4  721 1510   64 1112 p 10.5 ns (95M)
-- 2010-12-31   352 12.1    M53d xc3s1200e-4  701 1426   36  901 p 10.5 ns (95M)
-- 2010-11-27   341 12.1    M53d xc3s1200e-4  674 1387   36  867 p 10.5 ns (95M)
-- 2010-11-06   336 12.1    M53d xc3s1200e-4  665 1388   36  864 p 18.9 ns
-- 2010-06-03   300 11.4    L68  xc3s1200e-4  667 1378   36  860 p 15.8 ns
-- 2010-06-03   299 11.4    L68  xc3s1200e-4  659 1371   18  848 p 15.8 ns
-- 2010-05-24   294 11.4    L68  xc3s1200e-4  663 1358   18  841 p 15.8 ns
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-07-10   785   1.5.1  SWI(1) now XON
-- 2016-07-09   784   1.5    tst_sram with AWIDTH and 22bit support
-- 2016-03-19   748   1.4.2  define rlink SYSID
-- 2015-04-11   666   1.4.1  rearrange XON handling
-- 2014-08-28   588   1.4    use new rlink v4 iface and 4 bit STAT
-- 2014-08-15   583   1.3    rb_mreq addr now 16 bit
-- 2011-12-23   444   1.2    remove clksys output hack
-- 2011-12-21   442   1.1.6  use rlink_sp1c
-- 2011-11-26   433   1.1.5  use nx_cram_memctl_as now
-- 2011-11-23   432   1.1.4  now numeric_std clean; update O_FLA_CE_N usage
-- 2011-11-17   426   1.1.3  use dcm_sfs now
-- 2011-07-08   390   1.1.2  use now sn_humanio
-- 2011-07-02   387   1.1.1  use bp_rs232_2line_iob now
-- 2010-12-31   352   1.1    port to rbv3
-- 2010-11-27   341   1.0.6  now proper clkdivce handling
-- 2010-11-22   339   1.0.5  use memctl delays from sys_conf constants
-- 2010-11-13   338   1.0.4  add DCM and O_CLKSYS (for DCM derived system clock)
-- 2010-11-06   336   1.0.3  rename input pin CLK -> I_CLK50
-- 2010-10-23   335   1.0.2  rename RRI_LAM->RB_LAM;
-- 2010-06-03   300   1.0.1  use default FAWIDTH for rri_core_serport
-- 2010-05-23   294   1.0    Initial version (derived from sys_tst_sram_s3)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.serportlib.all;
use work.rblib.all;
use work.rlinklib.all;
use work.bpgenlib.all;
use work.s3boardlib.all;
use work.nxcramlib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_sram_n2 is               -- top level
                                        -- implements nexys2_aif
  port (
    I_CLK50 : in slbit;                 -- 50 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- n2 switches
    I_BTN : in slv4;                    -- n2 buttons
    O_LED : out slv8;                   -- n2 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
    O_MEM_CE_N : out slbit;             -- cram: chip enable   (act.low)
    O_MEM_BE_N : out slv2;              -- cram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- cram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- cram: output enable (act.low)
    O_MEM_ADV_N  : out slbit;           -- cram: address valid (act.low)
    O_MEM_CLK : out slbit;              -- cram: clock
    O_MEM_CRE : out slbit;              -- cram: command register enable
    I_MEM_WAIT : in slbit;              -- cram: mem wait
    O_MEM_ADDR  : out slv23;            -- cram: address lines
    IO_MEM_DATA : inout slv16;          -- cram: data lines
    O_FLA_CE_N : out slbit              -- flash ce..          (act.low)
  );
end sys_tst_sram_n2;

architecture syn of sys_tst_sram_n2 is
  
  signal CLK :   slbit := '0';

  signal CE_USEC :  slbit := '0';
  signal CE_MSEC :  slbit := '0';

  signal GBL_RESET : slbit := '0';
  
  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
  signal CTS_N : slbit := '0';
  signal RTS_N : slbit := '0';

  signal SWI     : slv8  := (others=>'0');
  signal BTN     : slv4  := (others=>'0');
  signal LED     : slv8  := (others=>'0');  
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;
  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4 := (others=>'0');
  
  signal SER_MONI : serport_moni_type := serport_moni_init;

  signal RB_SRES_TST : rb_sres_type := rb_sres_init;
  signal RB_LAM_TST  : slbit := '0';

  signal MEM_RESET : slbit := '0';
  signal MEM_REQ   : slbit := '0';
  signal MEM_WE    : slbit := '0';
  signal MEM_BUSY  : slbit := '0';
  signal MEM_ACK_R : slbit := '0';
  signal MEM_ACK_W : slbit := '0';
  signal MEM_ACT_R : slbit := '0';
  signal MEM_ACT_W : slbit := '0';
  signal MEM_ADDR  : slv22 := (others=>'0');
  signal MEM_BE    : slv4  := (others=>'0');
  signal MEM_DI    : slv32 := (others=>'0');
  signal MEM_DO    : slv32 := (others=>'0');

  constant sysid_proj  : slv16 := x"0104";   -- tst_sram
  constant sysid_board : slv8  := x"02";     -- nexys2
  constant sysid_vers  : slv8  := x"00";

begin

  DCM : dcm_sfs
    generic map (
      CLKFX_DIVIDE   => sys_conf_clkfx_divide,
      CLKFX_MULTIPLY => sys_conf_clkfx_multiply,
      CLKIN_PERIOD   => 20.0)
    port map (
      CLKIN   => I_CLK50,
      CLKFX   => CLK,
      LOCKED  => open
    );
    
  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 7,                    -- good for up to 127 MHz !
      USECDIV  => sys_conf_clksys_mhz,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  IOB_RS232 : bp_rs232_2line_iob
    port map (
      CLK   => CLK,
      RXD   => RXD,
      TXD   => TXD,
      I_RXD => I_RXD,
      O_TXD => O_TXD
    );

  HIO : sn_humanio
    port map (
      CLK     => CLK,
      RESET   => '0',
      CE_MSEC => CE_MSEC,
      SWI     => SWI,
      BTN     => BTN,
      LED     => LED,
      DSP_DAT => DSP_DAT,
      DSP_DP  => DSP_DP,
      I_SWI   => I_SWI,
      I_BTN   => I_BTN,
      O_LED   => O_LED,
      O_ANO_N => O_ANO_N,
      O_SEG_N => O_SEG_N
    );

  RLINK : rlink_sp1c
    generic map (
      BTOWIDTH     => 6,                --  64 cycles access timeout
      RTAWIDTH     => 12,
      SYSID        => sysid_proj & sysid_board & sysid_vers,
      IFAWIDTH     => 5,                --  32 word input fifo
      OFAWIDTH     => 5,                --  32 word output fifo
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      CDWIDTH      => 13,
      CDINIT       => sys_conf_ser2rri_cdinit,
      RBMON_AWIDTH => 0,
      RBMON_RBADDR => x"ffe8")
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      CE_INT   => CE_MSEC,
      RESET    => GBL_RESET,
      ENAXON   => SWI(1),
      ESCFILL  => '0',
      RXSD     => RXD,
      TXSD     => TXD,
      CTS_N    => CTS_N,
      RTS_N    => RTS_N,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT,
      RL_MONI  => open,
      SER_MONI => SER_MONI
    );

  TST : entity work.tst_sram
    generic map (
      RB_ADDR => slv(to_unsigned(2#0000000000000000#,16)),
      AWIDTH  => 22)
    port map (
      CLK       => CLK,
      RESET     => GBL_RESET,
      RB_MREQ   => RB_MREQ,
      RB_SRES   => RB_SRES_TST,
      RB_STAT   => RB_STAT,
      RB_LAM    => RB_LAM_TST,
      SWI       => SWI,
      BTN       => BTN,
      LED       => LED,
      DSP_DAT   => DSP_DAT,
      MEM_RESET => MEM_RESET,
      MEM_REQ   => MEM_REQ,
      MEM_WE    => MEM_WE,
      MEM_BUSY  => MEM_BUSY,
      MEM_ACK_R => MEM_ACK_R,
      MEM_ACK_W => MEM_ACK_W,
      MEM_ACT_R => MEM_ACT_R,
      MEM_ACT_W => MEM_ACT_W,
      MEM_ADDR  => MEM_ADDR,
      MEM_BE    => MEM_BE,
      MEM_DI    => MEM_DI,
      MEM_DO    => MEM_DO
    );

  CRAMCTL : nx_cram_memctl_as
    generic map (
      READ0DELAY => sys_conf_memctl_read0delay,   -- was 2 for 50 MHz
      READ1DELAY => sys_conf_memctl_read1delay,   -- was 2 "
      WRITEDELAY => sys_conf_memctl_writedelay)   -- was 3 "
    port map (
      CLK     => CLK,
      RESET   => MEM_RESET,
      REQ     => MEM_REQ,
      WE      => MEM_WE,
      BUSY    => MEM_BUSY,
      ACK_R   => MEM_ACK_R,
      ACK_W   => MEM_ACK_W,
      ACT_R   => MEM_ACT_R,
      ACT_W   => MEM_ACT_W,
      ADDR    => MEM_ADDR,
      BE      => MEM_BE,
      DI      => MEM_DI,
      DO      => MEM_DO,
      O_MEM_CE_N  => O_MEM_CE_N,
      O_MEM_BE_N  => O_MEM_BE_N,
      O_MEM_WE_N  => O_MEM_WE_N,
      O_MEM_OE_N  => O_MEM_OE_N,
      O_MEM_ADV_N => O_MEM_ADV_N,
      O_MEM_CLK   => O_MEM_CLK,
      O_MEM_CRE   => O_MEM_CRE,
      I_MEM_WAIT  => I_MEM_WAIT,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );
  
  O_FLA_CE_N  <= '1';                   -- keep Flash memory disabled

  RB_SRES   <= RB_SRES_TST;             -- can be sres_or later...
  RB_LAM(0) <= RB_LAM_TST;
  
  DSP_DP(3) <= not SER_MONI.txok;
  DSP_DP(2) <= SER_MONI.txact;
  DSP_DP(1) <= not SER_MONI.rxok;
  DSP_DP(0) <= SER_MONI.rxact;
  
end syn;

