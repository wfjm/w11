-- $Id: sys_tst_sram_n4.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_tst_sram_n4 - syn
-- Description:    test of nexys4 sram and its controller
--
-- Dependencies:   bplib/bpgen/s7_cmt_1ce1ce
--                 bplib/bpgen/bp_rs232_4line_iob
--                 bplib/bpgen/sn_humanio
--                 vlib/rlink/rlink_sp2c
--                 tst_sram
--                 bplib/nxcramlib/nx_cram_memctl_as
--                 bplib/sysmon/sysmonx_rbus_base
--                 vlib/rbus/rbd_usracc
--                 vlib/rbus/rb_sres_or_3
--
-- Test bench:     tb/tb_tst_sram_n4
--
-- Target Devices: generic
-- Tool versions:  viv 2014.4-2018.3; ghdl 0.29-0.35    (ise 14.5-14.7 retired)
--
-- Synthesized:
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2019-02-02  1108 2018.3  xc7a100t-1   1042  1550    24     5   530 
-- 2019-02-02  1108 2017.2  xc7a100t-1   1043  1642    24     5   564 
-- 2017-01-14   844 2016.4  xc7a100t-1   1042  1677    24     5   557 +sysmon
-- 2016-03-29   756 2015.4  xc7a100t-1    918  1207    24     5   428  
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-16  1086   1.7    use s7_cmt_1ce1ce
-- 2017-01-14   844   1.6    add sysmon_rbus
-- 2016-07-10   785   1.5.1  SWI(1) now XON
-- 2016-07-09   784   1.5    tst_sram with AWIDTH and 22bit support
-- 2016-04-02   758   1.4.1  add rbd_usracc (bitfile+jtag timestamp access)
-- 2016-03-28   755   1.4    use serport_2clock2
-- 2016-03-19   748   1.3.3  define rlink SYSID
-- 2015-04-11   666   1.3.2  rearrange XON handling
-- 2015-02-01   641   1.3.1  separate I_BTNRST_N
-- 2015-01-31   640   1.3    drop fusp iface; use new sn_hio
-- 2014-08-28   588   1.2    use new rlink v4 ifaceand 4 bit STAT
-- 2014-08-15   583   1.1    rb_mreq addr now 16 bit
-- 2013-09-28   535   1.0.1  use proper clock manager
-- 2013-09-21   534   1.0    Initial version (derived from sys_tst_sram_n3)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.serportlib.all;
use work.rblib.all;
use work.rbdlib.all;
use work.rlinklib.all;
use work.bpgenlib.all;
use work.sysmonrbuslib.all;
use work.s3boardlib.all;
use work.nxcramlib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_sram_n4 is               -- top level
                                        -- implements nexys4_cram_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    O_RTS_N : out slbit;                -- rx rts (board view; act.low)
    I_CTS_N : in slbit;                 -- tx cts (board view; act.low)
    I_SWI : in slv16;                   -- n4 switches
    I_BTN : in slv5;                    -- n4 buttons
    I_BTNRST_N : in slbit;              -- n4 reset button
    O_LED : out slv16;                  -- n4 leds
    O_RGBLED0 : out slv3;               -- n4 rgb-led 0
    O_RGBLED1 : out slv3;               -- n4 rgb-led 1
    O_ANO_N : out slv8;                 -- 7 segment disp: anodes   (act.low)
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
    IO_MEM_DATA : inout slv16           -- cram: data lines
  );
end sys_tst_sram_n4;

architecture syn of sys_tst_sram_n4 is
  
  signal CLK :   slbit := '0';

  signal CE_USEC :  slbit := '0';
  signal CE_MSEC :  slbit := '0';

  signal CLKS :  slbit := '0';
  signal CES_MSEC : slbit := '0';

  signal GBL_RESET : slbit := '0';
  
  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
  signal CTS_N : slbit := '0';
  signal RTS_N : slbit := '0';

  signal SWI     : slv16 := (others=>'0');
  signal BTN     : slv5  := (others=>'0');
  signal LED     : slv16 := (others=>'0');  
  signal DSP_DAT : slv32 := (others=>'0');
  signal DSP_DP  : slv8  := (others=>'0');

  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;
  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4 := (others=>'0');
  
  signal SER_MONI : serport_moni_type := serport_moni_init;

  signal RB_SRES_TST : rb_sres_type := rb_sres_init;
  signal RB_SRES_SYSMON : rb_sres_type := rb_sres_init;
  signal RB_SRES_USRACC : rb_sres_type := rb_sres_init;

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

  constant rbaddr_sysmon: slv16 := x"fb00"; -- fb00/0080: 1111 1011 0xxx xxxx

  constant sysid_proj  : slv16 := x"0104";   -- tst_sram
  constant sysid_board : slv8  := x"05";     -- nexys4
  constant sysid_vers  : slv8  := x"00";

begin

  GEN_CLKALL : s7_cmt_1ce1ce            -- clock generator system ------------
    generic map (
      CLKIN_PERIOD   => 10.0,
      CLKIN_JITTER   => 0.01,
      STARTUP_WAIT   => false,
      CLK0_VCODIV    => sys_conf_clksys_vcodivide,
      CLK0_VCOMUL    => sys_conf_clksys_vcomultiply,
      CLK0_OUTDIV    => sys_conf_clksys_outdivide,
      CLK0_GENTYPE   => sys_conf_clksys_gentype,
      CLK0_CDUWIDTH  => 7,
      CLK0_USECDIV   => sys_conf_clksys_mhz,
      CLK0_MSECDIV   => 1000,      
      CLK1_VCODIV    => sys_conf_clkser_vcodivide,
      CLK1_VCOMUL    => sys_conf_clkser_vcomultiply,
      CLK1_OUTDIV    => sys_conf_clkser_outdivide,
      CLK1_GENTYPE   => sys_conf_clkser_gentype,
      CLK1_CDUWIDTH  => 7,
      CLK1_USECDIV   => sys_conf_clkser_mhz,
      CLK1_MSECDIV   => 1000)
    port map (
      CLKIN     => I_CLK100,
      CLK0      => CLK,
      CE0_USEC  => CE_USEC,
      CE0_MSEC  => CE_MSEC,
      CLK1      => CLKS,
      CE1_USEC  => open,
      CE1_MSEC  => CES_MSEC,
      LOCKED    => open
    );

  IOB_RS232 : bp_rs232_4line_iob
    port map (
      CLK     => CLKS,
      RXD     => RXD,
      TXD     => TXD,
      CTS_N   => CTS_N,
      RTS_N   => RTS_N,
      I_RXD   => I_RXD,
      O_TXD   => O_TXD,
      I_CTS_N => I_CTS_N,
      O_RTS_N => O_RTS_N
    );

  HIO : sn_humanio
    generic map (
      SWIDTH   => 16,
      BWIDTH   =>  5,
      LWIDTH   => 16,
      DCWIDTH  =>  3)
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

  RLINK : rlink_sp2c
    generic map (
      BTOWIDTH     => 6,                --  64 cycles access timeout
      RTAWIDTH     => 12,
      SYSID        => sysid_proj & sysid_board & sysid_vers,
      IFAWIDTH     => 5,                --  32 word input fifo
      OFAWIDTH     => 5,                --  32 word output fifo
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      CDWIDTH      => 12,
      CDINIT       => sys_conf_ser2rri_cdinit,
      RBMON_AWIDTH => 0,
      RBMON_RBADDR => x"ffe8")
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      CE_INT   => CE_MSEC,
      RESET    => GBL_RESET,
      CLKS     => CLKS,
      CES_MSEC => CES_MSEC,
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
      SWI       => SWI(7 downto 0),
      BTN       => BTN(3 downto 0),
      LED       => LED(7 downto 0),
      DSP_DAT   => DSP_DAT(15 downto 0),
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
      READ0DELAY => sys_conf_memctl_read0delay,
      READ1DELAY => sys_conf_memctl_read1delay,
      WRITEDELAY => sys_conf_memctl_writedelay) 
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

  SMRB : sysmonx_rbus_base
    generic map (                     -- use default INIT_ (Vccint=1.00)
      CLK_MHZ  => sys_conf_clksys_mhz,
      RB_ADDR  => rbaddr_sysmon)
    port map (
      CLK      => CLK,
      RESET    => GBL_RESET,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES_SYSMON,
      ALM      => open,
      OT       => open,
      TEMP     => open
    );

  UARB : rbd_usracc
    port map (
      CLK     => CLK,
      RB_MREQ => RB_MREQ,
      RB_SRES => RB_SRES_USRACC
    );

  RB_SRES_OR : rb_sres_or_3             -- rbus or ---------------------------
    port map (
      RB_SRES_1  => RB_SRES_TST,
      RB_SRES_2  => RB_SRES_SYSMON,
      RB_SRES_3  => RB_SRES_USRACC,
      RB_SRES_OR => RB_SRES
    );
  
  RB_LAM(0) <= RB_LAM_TST;

  DSP_DP(3) <= not SER_MONI.txok;
  DSP_DP(2) <= SER_MONI.txact;
  DSP_DP(1) <= not SER_MONI.rxok;
  DSP_DP(0) <= SER_MONI.rxact;

  DSP_DP(7 downto 4) <= "0010";
  DSP_DAT(31 downto 16) <= SER_MONI.abclkdiv(11 downto 0) &
                           '0' & SER_MONI.abclkdiv_f;

  -- setup unused outputs in nexys4
  O_RGBLED0 <= (others=>'0');
  O_RGBLED1 <= (others=>not I_BTNRST_N);
  
end syn;

