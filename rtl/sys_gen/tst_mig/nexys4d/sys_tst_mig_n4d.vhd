-- $Id: sys_tst_mig_n4d.vhd 1247 2022-07-06 07:04:33Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_tst_mig_n4d - syn
-- Description:    test of nexyx4d ddr and its mig controller
--
-- Dependencies:   vlib/xlib/bufg_unisim
--                 bplib/bpgen/s7_cmt_1ce1ce2c
--                 cdclib/cdc_signal_s1_as
--                 cdclib/cdc_pulse
--                 bplib/bpgen/bp_rs232_4line_iob
--                 rlink/rlink_sp2c
--                 tst_mig
--                 bplib/nexyx4d/migui_nexyx4d          (generated core)
--                 bplib/sysmon/sysmonx_rbus_base
--                 rbus/rbd_usracc
--                 rbus/rb_sres_or_3
--
-- Test bench:     tb/tb_tst_mig_n4d
--
-- Target Devices: generic
-- Tool versions:  viv 2017.2-2022.1; ghdl 0.34-2.0.0
--
-- Synthesized (viv):
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2022-07-05  1247 2022.1  xc7a100t-1l  4216  3821   412     1  1726
-- 2019-08-10  1201 2019.1  xc7a100t-1l  4217  4173   440     1  1709 +clkmon
-- 2019-02-02  1108 2018.3  xc7a100t-1l  4106  4145   440     1  1689
-- 2019-02-02  1108 2017.2  xc7a100t-1l  4097  4310   440     1  1767
-- 2019-01-02  1101 2017.2  xc7a100t-1l  4097  4310   457     1  1767
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2022-07-05  1247   1.1.1  use bufg_unisim
-- 2019-08-10  1201   1.1    use 100 MHz MIG SYS_CLK; add clock monitor 
-- 2018-12-30  1099   1.0    Initial version
------------------------------------------------------------------------------
--
-- Usage of Nexys 4 Switches, Buttons, LEDs
--
--    SWI    -- unused --
--
--    BTN
--       (4) ce  -- unused --
--       (3) le  issue MIG_SYS_RST
--       (2) do  light LED(12:15)
--       (1) ri  light LED(8:11)
--       (0) up  light LED(4:7)
--
--    LEDs
--       (15)    I_BTN(2) or R_FLG_UI_CLK  (MIG UI clock monitor  75 MHz)
--       (14)    I_BTN(2) or R_FLG_CLKREF  (CLKREF clock monitor 200 MHz)
--       (13)    I_BTN(2) or R_FLG_CLKSER  (CLKSER clock monitor 120 MHz)
--       (12)    I_BTN(2) or R_FLG_XX_CLK  (sysclk clock monitor  80 MHz)
--       (11)    I_BTN(1) or not APP_WDF_RDY
--       (10)    I_BTN(1) or not APP_RDY
--      (8:9)    I_BTN(1)
--        (7)    I_BTN(0) or not MIG_INIT_CALIB_COMPLETE
--        (6)    I_BTN(0) or MIG_UI_CLK_SYNC_RST
--        (5)    I_BTN(0)
--        (4)    I_BTN(0) or not LOCKED
--        (3)    not SER_MONI.txok       (shows tx back pressure)
--        (2)    SER_MONI.txact          (shows tx activity)
--        (1)    not SER_MONI.rxok       (shows rx back pressure)
--        (0)    SER_MONI.rxact          (shows rx activity)


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
use work.miglib_nexys4d.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_mig_n4d is               -- top level
                                        -- implements nexys4d_mig_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    O_RTS_N : out slbit;                -- rx rts (board view; act.low)
    I_CTS_N : in slbit;                 -- tx cts (board view; act.low)
    I_SWI : in slv16;                   -- n4d switches
    I_BTN : in slv5;                    -- n4d buttons
    I_BTNRST_N : in slbit;              -- n4d reset button
    O_LED : out slv16;                  -- n4d leds
    O_RGBLED0 : out slv3;               -- n4d rgb-led 0
    O_RGBLED1 : out slv3;               -- n4d rgb-led 1
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
end sys_tst_mig_n4d;

architecture syn of sys_tst_mig_n4d is
  
  signal CLK100_BUF :   slbit := '0';

  signal XX_CLK :   slbit := '0';       -- kept to keep clock setup similar
  signal XX_CE_USEC :  slbit := '0';    --   to w11a or other 'normal' systems
  signal XX_CE_MSEC :  slbit := '0';    --

  signal CLK  :  slbit := '0';
  signal CE_USEC :  slbit := '0';
  signal CE_MSEC :  slbit := '0';

  signal CLKS :  slbit := '0';
  signal CES_MSEC : slbit := '0';

  signal CLKREF : slbit := '0';
  
  signal LOCKED        : slbit := '0';   -- raw LOCKED
  signal LOCKED_CLKMIG : slbit := '0';   -- sync'ed to CLKMIG

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
  signal RTS_N : slbit := '0';
  signal CTS_N : slbit := '0';

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

  signal RB_SRES_TST    : rb_sres_type := rb_sres_init;
  signal RB_SRES_SYSMON : rb_sres_type := rb_sres_init;
  signal RB_SRES_USRACC : rb_sres_type := rb_sres_init;

  signal RB_LAM_TST  : slbit := '0';

  signal APP_ADDR          : slv(mig_mawidth-1 downto 0) := (others=>'0');
  signal APP_CMD           : slv3  := (others=>'0');
  signal APP_EN            : slbit := '0';
  signal APP_WDF_DATA      : slv(mig_dwidth-1 downto 0) := (others=>'0'); 
  signal APP_WDF_END       : slbit := '0';
  signal APP_WDF_MASK      : slv(mig_mwidth-1 downto 0) := (others=>'0');
  signal APP_WDF_WREN      : slbit := '0';
  signal APP_RD_DATA       : slv(mig_dwidth-1 downto 0) := (others=>'0');
  signal APP_RD_DATA_END   : slbit := '0';
  signal APP_RD_DATA_VALID : slbit := '0';
  signal APP_RDY           : slbit := '0';
  signal APP_WDF_RDY       : slbit := '0';
  signal APP_SR_REQ        : slbit := '0';
  signal APP_REF_REQ       : slbit := '0';
  signal APP_ZQ_REQ        : slbit := '0';
  signal APP_SR_ACTIVE     : slbit := '0';
  signal APP_REF_ACK       : slbit := '0';
  signal APP_ZQ_ACK        : slbit := '0';
  signal MIG_UI_CLK              : slbit := '0';
  signal MIG_UI_CLK_SYNC_RST     : slbit := '0';
  signal MIG_INIT_CALIB_COMPLETE : slbit := '0';
  signal MIG_SYS_RST             : slbit := '0';
  
  signal XADC_TEMP : slv12 := (others=>'0'); -- xadc die temp; on CLK
  
  signal R_CNT_UI_CLK : slv(25 downto 0) := (others=>'0');
  signal R_CNT_CLKREF : slv(26 downto 0) := (others=>'0');
  signal R_CNT_CLKSER : slv(25 downto 0) := (others=>'0');
  signal R_CNT_XX_CLK : slv(25 downto 0) := (others=>'0');
  signal R_FLG_UI_CLK : slbit := '0';
  signal R_FLG_CLKREF : slbit := '0';
  signal R_FLG_CLKSER : slbit := '0';
  signal R_FLG_XX_CLK : slbit := '0';

  constant rbaddr_rbmon : slv16 := x"ffe8"; -- ffe8/0008: 1111 1111 1110 1xxx
  constant rbaddr_sysmon: slv16 := x"fb00"; -- fb00/0080: 1111 1011 0xxx xxxx

  constant sysid_proj  : slv16 := x"0105";   -- tst_mig
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
      CLK0      => XX_CLK,
      CE0_USEC  => XX_CE_USEC,
      CE0_MSEC  => XX_CE_MSEC,
      CLK1      => CLKS,
      CE1_USEC  => open,
      CE1_MSEC  => CES_MSEC,
      CLK2      => open,
      CLK3      => CLKREF,
      LOCKED    => LOCKED
    );

  -- Note: CLK0 is generated as in 'normal' systems to keep PPL/MMCM setup
  --   as similar as possible. The CE_USEC and CE_MSEC pulses are forwarded
  --   from the 80 MHz CLK0 domain to the 75.000 MHz MIG UI_CLK domain

  CDC_CEUSEC : cdc_pulse                -- provide CLK side CE_USEC
    generic map (
    POUT_SINGLE => true,
    BUSY_WACK   => false)
  port map (
    CLKM     => XX_CLK,
    RESET    => '0',
    CLKS     => CLK,
    PIN      => XX_CE_USEC,
    BUSY     => open,
    POUT     => CE_USEC
    );
  
  CDC_CEMSEC : cdc_pulse                -- provide CLK side CE_MSEC
    generic map (
    POUT_SINGLE => true,
    BUSY_WACK   => false)
  port map (
    CLKM     => XX_CLK,
    RESET    => '0',
    CLKS     => CLK,
    PIN      => XX_CE_MSEC,
    BUSY     => open,
    POUT     => CE_MSEC
  );
  
  CDC_CLKMIG_LOCKED : cdc_signal_s1_as
    port map (
      CLKO  => CLK100_BUF,
      DI    => LOCKED,
      DO    => LOCKED_CLKMIG
    );
  
  IOB_RS232 : bp_rs232_4line_iob         -- serport iob ----------------------
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

  RLINK : rlink_sp2c
    generic map (
      BTOWIDTH     =>  8,               -- 256 cycles, for slow mem iface
      RTAWIDTH     => 12,
      SYSID        => sysid_proj & sysid_board & sysid_vers,
      IFAWIDTH     => 5,                --  32 word input fifo
      OFAWIDTH     => 5,                --  32 word output fifo
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      CDWIDTH      => 12,
      CDINIT       => sys_conf_ser2rri_cdinit,
      RBMON_AWIDTH => 0,
      RBMON_RBADDR => rbaddr_rbmon)
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      CE_INT   => CE_MSEC,
      RESET    => '0',                  -- FIXME: no RESET
      CLKS     => CLKS,
      CES_MSEC => CES_MSEC,
      ENAXON   => '0',
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

  TST : entity work.tst_mig
    generic map (
      RB_ADDR => slv(to_unsigned(2#0000000000000000#,16)),
      MAWIDTH => mig_mawidth,
      MWIDTH  => mig_mwidth)
    port map (
      CLK       => CLK,
      CE_USEC   => CE_USEC,
      RESET     => '0',                 -- FIXME: no RESET
      RB_MREQ   => RB_MREQ,
      RB_SRES   => RB_SRES_TST,
      RB_STAT   => RB_STAT,
      RB_LAM    => RB_LAM_TST,
      APP_ADDR            => APP_ADDR,
      APP_CMD             => APP_CMD,
      APP_EN              => APP_EN,
      APP_WDF_DATA        => APP_WDF_DATA,
      APP_WDF_END         => APP_WDF_END,
      APP_WDF_MASK        => APP_WDF_MASK,
      APP_WDF_WREN        => APP_WDF_WREN,
      APP_RD_DATA         => APP_RD_DATA,
      APP_RD_DATA_END     => APP_RD_DATA_END,
      APP_RD_DATA_VALID   => APP_RD_DATA_VALID,
      APP_RDY             => APP_RDY,
      APP_WDF_RDY         => APP_WDF_RDY,
      APP_SR_REQ          => APP_SR_REQ,
      APP_REF_REQ         => APP_REF_REQ,
      APP_ZQ_REQ          => APP_ZQ_REQ,
      APP_SR_ACTIVE       => APP_SR_ACTIVE,
      APP_REF_ACK         => APP_REF_ACK,
      APP_ZQ_ACK          => APP_ZQ_ACK,
      MIG_UI_CLK_SYNC_RST     => MIG_UI_CLK_SYNC_RST,
      MIG_INIT_CALIB_COMPLETE => MIG_INIT_CALIB_COMPLETE,
      MIG_DEVICE_TEMP_I       => XADC_TEMP
    );
  
  MIG_CTL: migui_nexys4d                -- MIG iface -----------------
    port map (
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
      DDR2_ODT     => DDR2_ODT,
      APP_ADDR            => APP_ADDR,
      APP_CMD             => APP_CMD,
      APP_EN              => APP_EN,
      APP_WDF_DATA        => APP_WDF_DATA,
      APP_WDF_END         => APP_WDF_END,
      APP_WDF_MASK        => APP_WDF_MASK,
      APP_WDF_WREN        => APP_WDF_WREN,
      APP_RD_DATA         => APP_RD_DATA,
      APP_RD_DATA_END     => APP_RD_DATA_END,
      APP_RD_DATA_VALID   => APP_RD_DATA_VALID,
      APP_RDY             => APP_RDY,
      APP_WDF_RDY         => APP_WDF_RDY,
      APP_SR_REQ          => APP_SR_REQ,
      APP_REF_REQ         => APP_REF_REQ,
      APP_ZQ_REQ          => APP_ZQ_REQ,
      APP_SR_ACTIVE       => APP_SR_ACTIVE,
      APP_REF_ACK         => APP_REF_ACK,
      APP_ZQ_ACK          => APP_ZQ_ACK,
      UI_CLK              => CLK,
      UI_CLK_SYNC_RST     => MIG_UI_CLK_SYNC_RST,
      INIT_CALIB_COMPLETE => MIG_INIT_CALIB_COMPLETE,
      SYS_CLK_I           => CLK100_BUF,
      CLK_REF_I           => CLKREF,
      DEVICE_TEMP_I       => XADC_TEMP,
      SYS_RST             => MIG_SYS_RST
    );

  MIG_SYS_RST <= (not LOCKED_CLKMIG) or I_BTN(3); -- provisional !
  
  SMRB: sysmonx_rbus_base
    generic map (                     -- use default INIT_ (Vccint=1.00)
      CLK_MHZ  => sys_conf_clksys_mhz,
      RB_ADDR  => rbaddr_sysmon)
    port map (
      CLK      => CLK,
      RESET    => '0',                  -- FIXME: no RESET
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
  
  proc_mon_ui_clk: process (CLK, I_BTN(3))
  begin

    if I_BTN(3) = '1' then
      R_FLG_UI_CLK <= '1';
      R_CNT_UI_CLK <= (others=>'0');
    end if;
    if rising_edge(CLK) then
      if unsigned(R_CNT_UI_CLK) =  37500000-1 then
        R_FLG_UI_CLK <= not R_FLG_UI_CLK;
        R_CNT_UI_CLK <= (others=>'0');
      else
        R_CNT_UI_CLK <= slv(unsigned(R_CNT_UI_CLK) + 1);
      end if;
    end if;

  end process proc_mon_ui_clk;

  proc_mon_clkref: process (CLKREF, I_BTN(3))
  begin

    if I_BTN(3) = '1' then
      R_FLG_CLKREF <= '1';
      R_CNT_CLKREF <= (others=>'0');
    end if;
    if rising_edge(CLKREF) then
      if unsigned(R_CNT_CLKREF) = 100000000-1 then
        R_FLG_CLKREF <= not R_FLG_CLKREF;
        R_CNT_CLKREF <= (others=>'0');
      else
        R_CNT_CLKREF <= slv(unsigned(R_CNT_CLKREF) + 1);
      end if;
    end if;

  end process proc_mon_clkref;

  proc_mon_clkser: process (CLKS, I_BTN(3))
  begin

    if I_BTN(3) = '1' then
      R_FLG_CLKSER <= '1';
      R_CNT_CLKSER <= (others=>'0');
    end if;
    if rising_edge(CLKS) then
      if unsigned(R_CNT_CLKSER) =  60000000-1 then
        R_FLG_CLKSER <= not R_FLG_CLKSER;
        R_CNT_CLKSER <= (others=>'0');
      else
        R_CNT_CLKSER <= slv(unsigned(R_CNT_CLKSER) + 1);
      end if;
    end if;

  end process proc_mon_clkser;

  proc_mon_xx_clk: process (XX_CLK, I_BTN(3))
  begin

    if I_BTN(3) = '1' then
      R_FLG_XX_CLK <= '1';
      R_CNT_XX_CLK <= (others=>'0');
    end if;
    if rising_edge(XX_CLK) then
      if unsigned(R_CNT_XX_CLK) =  40000000-1 then
        R_FLG_XX_CLK <= not R_FLG_XX_CLK;
        R_CNT_XX_CLK <= (others=>'0');
      else
        R_CNT_XX_CLK <= slv(unsigned(R_CNT_XX_CLK) + 1);
      end if;
    end if;

  end process proc_mon_xx_clk;

  RB_LAM(0) <= RB_LAM_TST;

  -- LED group(0:3): rlink traffic
  O_LED(0)  <= SER_MONI.rxact;
  O_LED(1)  <= not SER_MONI.rxok;
  O_LED(2)  <= SER_MONI.txact;
  O_LED(3)  <= not SER_MONI.txok;

  -- LED group(4:7) serious error conditions
  O_LED(4)  <= I_BTN(0) or not LOCKED;
  O_LED(5)  <= I_BTN(0);
  O_LED(6)  <= I_BTN(0) or MIG_UI_CLK_SYNC_RST;
  O_LED(7)  <= I_BTN(0) or not MIG_INIT_CALIB_COMPLETE;

  -- LED group(8:11) for activity
  O_LED(8)  <= I_BTN(1);
  O_LED(9)  <= I_BTN(1);
  O_LED(10) <= I_BTN(1) or not APP_RDY;
  O_LED(11) <= I_BTN(1) or not APP_WDF_RDY;
  
  -- LED group(12:15) for clock monitoring
  O_LED(12) <= I_BTN(2) or R_FLG_XX_CLK;
  O_LED(13) <= I_BTN(2) or R_FLG_CLKSER;
  O_LED(14) <= I_BTN(2) or R_FLG_CLKREF;
  O_LED(15) <= I_BTN(2) or R_FLG_UI_CLK;

  -- RGB LEDs unused
  O_RGBLED0 <= (others=>'0');
  O_RGBLED1 <= (others=>'0');
  -- 7 segment disp unused
  O_ANO_N <= (others=>'1');
  O_SEG_N <= (others=>'1');

end syn;
