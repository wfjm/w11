-- $Id: sys_tst_sram_n4d.vhd 1247 2022-07-06 07:04:33Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_tst_sram_n4d - syn
-- Description:    test of nexys4d ddr and its mig controller
--
-- Dependencies:   vlib/xlib/bufg_unisim
--                 bplib/bpgen/s7_cmt_1ce1ce2c
--                 cdclib/cdc_signal_s1_as
--                 bplib/bpgen/bp_rs232_4line_iob
--                 bplib/bpgen/sn_humanio
--                 vlib/rlink/rlink_sp2c
--                 tst_sram
--                 bplib/nexyx4d/sramif_mig_nexys4d
--                 bplib/sysmon/sysmonx_rbus_base
--                 vlib/rbus/rbd_usracc
--                 vlib/rbus/rb_sres_or_3
--
-- Test bench:     tb/tb_tst_sram_n4d
--
-- Target Devices: generic
-- Tool versions:  viv 2017.2-2022.1; ghdl 0.34-2.0.0
--
-- Synthesized:
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2022-07-05  1247 2022.1  xc7a100t-1   4408  4197   608     5  1761
-- 2019-08-10  1201 2019.1  xc7a100t-1   4409  4606   656     5  1875
-- 2019-02-02  1108 2018.3  xc7a100t-1   4408  4606   656     5  1895
-- 2019-02-02  1108 2017.2  xc7a100t-1   4403  4900   657     5  1983
-- 2019-01-02  1101 2017.2  xc7a100t-1   4403  4900   640     5  1983
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2022-07-05  1247   1.1.1  use bufg_unisim
-- 2019-08-10  1201   1.1    use 100 MHz MIG SYS_CLK
-- 2019-01-02  1101   1.0    Initial version
-- 2018-12-30  1099   0.1    First draft (derived from sys_tst_sram_n4/arty)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;
use work.cdclib.all;
use work.serportlib.all;
use work.rblib.all;
use work.rbdlib.all;
use work.rlinklib.all;
use work.bpgenlib.all;
use work.sysmonrbuslib.all;
use work.s3boardlib.all;
use work.miglib.all;
use work.miglib_nexys4d.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_sram_n4d is              -- top level
                                        -- implements nexys4d_mig_aif
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
    DDR2_DQ      : inout slv16;         -- dram: data in/out
    DDR2_DQS_P   : inout slv2;          -- dram: data strobe (diff-p)
    DDR2_DQS_N   : inout slv2;          -- dram: data strobe (diff-n)
    DDR2_ADDR    : out   slv13;         -- dram: address
    DDR2_BA      : out   slv3;          -- dram: bank address
    DDR2_RAS_N   : out   slbit;         -- dram: row addr strobe    (act.low)
    DDR2_CAS_N   : out   slbit;         -- dram: column addr strobe (act.low)
    DDR2_WE_N    : out   slbit;         -- dram: write enable       (act.low)
    DDR2_CK_P    : out   slv1;          -- dram: clock (diff-p)
    DDR2_CK_N    : out   slv1;          -- dram: clock (diff-n)
    DDR2_CKE     : out   slv1;          -- dram: clock enable
    DDR2_CS_N    : out   slv1;          -- dram: chip select        (act.low)
    DDR2_DM      : out   slv2;          -- dram: data input mask
    DDR2_ODT     : out   slv1           -- dram: on-die termination
  );
end sys_tst_sram_n4d;

architecture syn of sys_tst_sram_n4d is
  
  signal CLK100_BUF :   slbit := '0';

  signal CLK :   slbit := '0';
  signal CE_USEC :  slbit := '0';
  signal CE_MSEC :  slbit := '0';

  signal CLKS :  slbit := '0';
  signal CES_MSEC : slbit := '0';

  signal CLKREF : slbit := '0';

  signal LOCKED        : slbit := '0';   -- raw LOCKED
  signal LOCKED_CLKMIG : slbit := '0';   -- sync'ed to CLKMIG

  signal GBL_RESET : slbit := '0';
  signal MEM_RESET : slbit := '0';
  signal MEM_RESET_RRI : slbit := '0';
  
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

  signal MEM_REQ   : slbit := '0';
  signal MEM_WE    : slbit := '0';
  signal MEM_BUSY  : slbit := '0';
  signal MEM_ACK_R : slbit := '0';
  signal MEM_ACK_W : slbit := '0';
  signal MEM_ACT_R : slbit := '0';
  signal MEM_ACT_W : slbit := '0';
  signal MEM_ADDR  : slv20 := (others=>'0');
  signal MEM_BE    : slv4  := (others=>'0');
  signal MEM_DI    : slv32 := (others=>'0');
  signal MEM_DO    : slv32 := (others=>'0');

  signal MIG_MONI : sramif2migui_moni_type := sramif2migui_moni_init;
  signal XADC_TEMP : slv12 := (others=>'0'); -- xadc die temp; on CLK

  constant rbaddr_sysmon: slv16 := x"fb00"; -- fb00/0080: 1111 1011 0xxx xxxx

  constant sysid_proj  : slv16 := x"0104";   -- tst_sram
  constant sysid_board : slv8  := x"08";     -- nexys4d
  constant sysid_vers  : slv8  := x"00";

begin

  CLK100_BUFG: bufg_unisim
    port map (
      I => I_CLK100,
      O => CLK100_BUF
    );
  
  GEN_CLKALL : s7_cmt_1ce1ce2c          -- clock generator system ------------
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
      CLK1_MSECDIV   => 1000,
      CLK23_VCODIV   =>  1,
      CLK23_VCOMUL   => 12,             -- vco 1200 MHz
      CLK2_OUTDIV    => 12,             -- mig sys 100.0 MHz (unused)
      CLK3_OUTDIV    =>  6,             -- mig ref 200.0 MHz
      CLK23_GENTYPE  => "PLL")
    port map (
      CLKIN     => CLK100_BUF,
      CLK0      => CLK,
      CE0_USEC  => CE_USEC,
      CE0_MSEC  => CE_MSEC,
      CLK1      => CLKS,
      CE1_USEC  => open,
      CE1_MSEC  => CES_MSEC,
      CLK2      => open,
      CLK3      => CLKREF,
      LOCKED    => LOCKED
    );

  CDC_CLKMIG_LOCKED : cdc_signal_s1_as
    port map (
      CLKO  => CLK100_BUF,
      DI    => LOCKED,
      DO    => LOCKED_CLKMIG
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
      AWIDTH  => 18)
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
      MEM_RESET => MEM_RESET_RRI,
      MEM_REQ   => MEM_REQ,
      MEM_WE    => MEM_WE,
      MEM_BUSY  => MEM_BUSY,
      MEM_ACK_R => MEM_ACK_R,
      MEM_ACK_W => MEM_ACK_W,
      MEM_ACT_R => MEM_ACT_R,
      MEM_ACT_W => MEM_ACT_W,
      MEM_ADDR  => MEM_ADDR(17 downto 0), -- ?? FIXME ?? allow AWIDTH=20
      MEM_BE    => MEM_BE,
      MEM_DI    => MEM_DI,
      MEM_DO    => MEM_DO
      );
  
  MEM_ADDR(19 downto 18) <= (others=>'0'); --?? FIXME ?? allow AWIDTH=20
  
  MEM_RESET <= not LOCKED_CLKMIG or MEM_RESET_RRI;

  MEMCTL: sramif_mig_nexys4d            -- SRAM to MIG iface -----------------
    port map (
      CLK          => CLK,
      RESET        => MEM_RESET,
      REQ          => MEM_REQ,
      WE           => MEM_WE,
      BUSY         => MEM_BUSY,
      ACK_R        => MEM_ACK_R,
      ACK_W        => MEM_ACK_W,
      ACT_R        => MEM_ACT_R,
      ACT_W        => MEM_ACT_W,
      ADDR         => MEM_ADDR,
      BE           => MEM_BE,
      DI           => MEM_DI,
      DO           => MEM_DO,
      CLKMIG       => CLK100_BUF,
      CLKREF       => CLKREF,
      TEMP         => XADC_TEMP,
      MONI         => MIG_MONI,
      DDR2_DQ      => DDR2_DQ,
      DDR2_DQS_P   => DDR2_DQS_P,
      DDR2_DQS_N   => DDR2_DQS_N,
      DDR2_ADDR    => DDR2_ADDR,
      DDR2_BA      => DDR2_BA,
      DDR2_RAS_N   => DDR2_RAS_N,
      DDR2_CAS_N   => DDR2_CAS_N,
      DDR2_WE_N    => DDR2_WE_N,
      DDR2_CK_P    => DDR2_CK_P,
      DDR2_CK_N    => DDR2_CK_N,
      DDR2_CKE     => DDR2_CKE,
      DDR2_CS_N    => DDR2_CS_N,
      DDR2_DM      => DDR2_DM,
      DDR2_ODT     => DDR2_ODT
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
      TEMP     => XADC_TEMP
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

