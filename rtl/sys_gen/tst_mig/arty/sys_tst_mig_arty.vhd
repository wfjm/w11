-- $Id: sys_tst_mig_arty.vhd 1247 2022-07-06 07:04:33Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_tst_mig_arty - syn
-- Description:    test of arty ddr and its mig controller
--
-- Dependencies:   vlib/xlib/bufg_unisim
--                 bplib/bpgen/s7_cmt_1ce1ce2c
--                 cdclib/cdc_signal_s1_as
--                 cdclib/cdc_pulse
--                 bplib/bpgen/bp_rs232_2line_iob
--                 rlink/rlink_sp2c
--                 tst_mig
--                 bplib/arty/migui_arty             (generated core)
--                 bplib/sysmon/sysmonx_rbus_arty
--                 rbus/rbd_usracc
--                 rbus/rb_sres_or_3
--
-- Test bench:     tb/tb_tst_mig_arty
--
-- Target Devices: generic
-- Tool versions:  viv 2017.2-2022.1; ghdl 0.34-2.0.0
--
-- Synthesized (viv):
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2022-07-05  1247 2022.1  xc7a35t-1l   4325  4197   415     1  1699
-- 2019-02-02  1108 2018.3  xc7a35t-1l   4323  4537   444     1  1874
-- 2019-02-02  1108 2017.2  xc7a35t-1l   4330  4773   444     1  1774
-- 2019-01-02  1101 2017.2  xc7a35t-1l   4320  4773   462     1  1770
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2022-07-05  1247   1.0.1  use bufg_unisim
-- 2018-12-26  1094   1.0    Initial version
-- 2018-12-23  1092   0.1    First draft
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
use work.miglib_arty.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_mig_arty is              -- top level
                                        -- implements arty_mig_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv4;                    -- arty switches
    I_BTN : in slv4;                    -- arty buttons
    O_LED : out slv4;                   -- arty leds
    O_RGBLED0 : out slv3;               -- arty rgb-led 0
    O_RGBLED1 : out slv3;               -- arty rgb-led 1
    O_RGBLED2 : out slv3;               -- arty rgb-led 2
    O_RGBLED3 : out slv3;               -- arty rgb-led 3
    A_VPWRN : in slv4;                  -- arty pwrmon (neg)
    A_VPWRP : in slv4;                  -- arty pwrmon (pos)
    DDR3_DQ      : inout slv16;         -- dram: data in/out
    DDR3_DQS_P   : inout slv2;          -- dram: data strobe (diff-p)
    DDR3_DQS_N   : inout slv2;          -- dram: data strobe (diff-n)
    DDR3_ADDR    : out   slv14;         -- dram: address
    DDR3_BA      : out   slv3;          -- dram: bank address
    DDR3_RAS_N   : out   slbit;         -- dram: row addr strobe    (act.low)
    DDR3_CAS_N   : out   slbit;         -- dram: column addr strobe (act.low)
    DDR3_WE_N    : out   slbit;         -- dram: write enable       (act.low)
    DDR3_RESET_N : out   slbit;         -- dram: reset              (act.low)
    DDR3_CK_P    : out   slv1;          -- dram: clock (diff-p)
    DDR3_CK_N    : out   slv1;          -- dram: clock (diff-n)
    DDR3_CKE     : out   slv1;          -- dram: clock enable
    DDR3_CS_N    : out   slv1;          -- dram: chip select        (act.low)
    DDR3_DM      : out   slv2;          -- dram: data input mask
    DDR3_ODT     : out   slv1           -- dram: on-die termination
  );
end sys_tst_mig_arty;

architecture syn of sys_tst_mig_arty is
  
  signal CLK100_BUF :   slbit := '0';

  signal XX_CLK :   slbit := '0';       -- kept to keep clock setup similar
  signal XX_CE_USEC :  slbit := '0';    --   to w11a or other 'normal' systems
  signal XX_CE_MSEC :  slbit := '0';    --

  signal CLK  :  slbit := '0';
  signal CE_USEC :  slbit := '0';
  signal CE_MSEC :  slbit := '0';

  signal CLKS :  slbit := '0';
  signal CES_MSEC : slbit := '0';

  signal CLKMIG : slbit := '0';
  signal CLKREF : slbit := '0';
  
  signal LOCKED        : slbit := '0';   -- raw LOCKED
  signal LOCKED_CLKMIG : slbit := '0';   -- sync'ed to CLKMIG

  signal MEM_RESET : slbit := '0';
  signal MEM_RESET_RRI : slbit := '0';
  
  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';

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

  signal R_DIMCNT : slv2  := (others=>'0');
  signal R_DIMFLG : slbit := '0';

  constant rbaddr_rbmon : slv16 := x"ffe8"; -- ffe8/0008: 1111 1111 1110 1xxx
  constant rbaddr_sysmon: slv16 := x"fb00"; -- fb00/0080: 1111 1011 0xxx xxxx

  constant sysid_proj  : slv16 := x"0105";   -- tst_mig
  constant sysid_board : slv8  := x"07";     -- arty
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
      CLK23_VCOMUL   => 10,             -- vco 1000 MHz
      CLK2_OUTDIV    =>  6,             -- mig sys 166.6 MHz
      CLK3_OUTDIV    =>  5,             -- mig ref 200.0 MHz
      CLK23_GENTYPE  => "PLL")
    port map (
      CLKIN     => CLK100_BUF,
      CLK0      => XX_CLK,
      CE0_USEC  => XX_CE_USEC,
      CE0_MSEC  => XX_CE_MSEC,
      CLK1      => CLKS,
      CE1_USEC  => open,
      CE1_MSEC  => CES_MSEC,
      CLK2      => CLKMIG,
      CLK3      => CLKREF,
      LOCKED    => LOCKED
    );

  -- Note: CLK0 is generated as in 'normal' systems to keep PPL/MMCM setup
  --   as similar as possible. The CE_USEC and CE_MSEC pulses are forwarded
  --   from the 80 MHz CLK0 domain to the 83.333 MHz MIG UI_CLK domain

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
      CLKO  => CLKMIG,
      DI    => LOCKED,
      DO    => LOCKED_CLKMIG
    );
  
  IOB_RS232 : bp_rs232_2line_iob
    port map (
      CLK     => CLKS,
      RXD     => RXD,
      TXD     => TXD,
      I_RXD   => I_RXD,
      O_TXD   => O_TXD
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
      ENAXON   => '1',
      ESCFILL  => '0',
      RXSD     => RXD,
      TXSD     => TXD,
      CTS_N    => '0',
      RTS_N    => open,
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
  
  MIG_CTL: migui_arty                   -- MIG iface -----------------
    port map (
      DDR3_DQ      => DDR3_DQ,
      DDR3_DQS_P   => DDR3_DQS_P,
      DDR3_DQS_N   => DDR3_DQS_N,
      DDR3_ADDR    => DDR3_ADDR,
      DDR3_BA      => DDR3_BA,
      DDR3_RAS_N   => DDR3_RAS_N,
      DDR3_CAS_N   => DDR3_CAS_N,
      DDR3_WE_N    => DDR3_WE_N,
      DDR3_RESET_N => DDR3_RESET_N,
      DDR3_CK_P    => DDR3_CK_P,
      DDR3_CK_N    => DDR3_CK_N,
      DDR3_CKE     => DDR3_CKE,
      DDR3_CS_N    => DDR3_CS_N,
      DDR3_DM      => DDR3_DM,
      DDR3_ODT     => DDR3_ODT,
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
      SYS_CLK_I           => CLKMIG,
      CLK_REF_I           => CLKREF,
      DEVICE_TEMP_I       => XADC_TEMP,
      SYS_RST             => MIG_SYS_RST
    );

  MIG_SYS_RST <= (not LOCKED_CLKMIG) or I_BTN(3); -- provisional !
  
  SMRB: sysmonx_rbus_arty
    generic map (                     -- use default INIT_ (LP: Vccint=0.95)
      CLK_MHZ  => sys_conf_clksys_mhz,
      RB_ADDR  => rbaddr_sysmon)
    port map (
      CLK      => CLK,
      RESET    => '0',                  -- FIXME: no RESET
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES_SYSMON,
      ALM      => open,
      OT       => open,
      TEMP     => XADC_TEMP,
      VPWRN    => A_VPWRN,
      VPWRP    => A_VPWRP
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
  
  proc_dim: process (CLKMIG)
  begin

    if rising_edge(CLKMIG) then
      R_DIMCNT <= slv(unsigned(R_DIMCNT) + 1);
      if unsigned(R_DIMCNT) = 0 then
        R_DIMFLG <= '1';
      else
        R_DIMFLG <= '0';
      end if;
    end if;

  end process proc_dim;

  RB_LAM(0) <= RB_LAM_TST;

  O_LED(1) <= SER_MONI.txact;
  O_LED(0) <= SER_MONI.rxact;

  -- red LED for serious error conditions
  O_RGBLED0(0) <= R_DIMFLG and (I_BTN(0) or not LOCKED);
  O_RGBLED1(0) <= R_DIMFLG and (I_BTN(0));
  O_RGBLED2(0) <= R_DIMFLG and (I_BTN(0) or MIG_UI_CLK_SYNC_RST);
  O_RGBLED3(0) <= R_DIMFLG and (I_BTN(0) or not MIG_INIT_CALIB_COMPLETE);

  -- green LED for activity
  O_RGBLED0(1) <= R_DIMFLG and (I_BTN(1));
  O_RGBLED1(1) <= R_DIMFLG and (I_BTN(1));
  O_RGBLED2(1) <= R_DIMFLG and (I_BTN(1) or not APP_RDY);
  O_RGBLED3(1) <= R_DIMFLG and (I_BTN(1) or not APP_WDF_RDY);
  
  -- blue LED currently unused
  O_RGBLED0(2) <= R_DIMFLG and (I_BTN(2));
  O_RGBLED1(2) <= R_DIMFLG and (I_BTN(2));
  O_RGBLED2(2) <= R_DIMFLG and (I_BTN(2));
  O_RGBLED3(2) <= R_DIMFLG and (I_BTN(2));

end syn;
