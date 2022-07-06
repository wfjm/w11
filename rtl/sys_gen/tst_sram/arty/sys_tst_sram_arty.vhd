-- $Id: sys_tst_sram_arty.vhd 1247 2022-07-06 07:04:33Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_tst_sram_arty - syn
-- Description:    test of arty ddr and its mig controller
--
-- Dependencies:   vlib/xlib/bufg_unisim
--                 bplib/bpgen/s7_cmt_1ce1ce2c
--                 cdclib/cdc_signal_s1_as
--                 bplib/bpgen/bp_rs232_2line_iob
--                 rlink/rlink_sp2c
--                 tst_sram
--                 bplib/arty/sramif_mig_arty
--                 bplib/bpgen/sn_humanio_eum_rbus
--                 bplib/sysmon/sysmonx_rbus_arty
--                 rbus/rbd_usracc
--                 rbus/rb_sres_or_4
--
-- Test bench:     tb/tb_tst_sram_arty
--
-- Target Devices: generic
-- Tool versions:  viv 2017.2-2022.1; ghdl 0.34-2.0.0
--
-- Synthesized (viv):
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2022-07-05  1247 2022.1  xc7a35t-1l   4648  4594   611     5  1849
-- 2019-02-02  1108 2018.3  xc7a35t-1l   4648  4968   644     5  1983 
-- 2019-02-02  1108 2017.2  xc7a35t-1l   4643  5334   644     5  1929 
-- 2019-01-02  1101 2017.2  xc7a35t-1l   4643  5334   644     5  1929 
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2022-07-05  1247   1.0.1  use bufg_unisim
-- 2018-12-20  1090   1.0    Initial version
-- 2018-11-17  1071   0.1    First draft (derived from sys_tst_sram_c7)
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
use work.bpgenrbuslib.all;
use work.sysmonrbuslib.all;
use work.miglib.all;
use work.miglib_arty.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_sram_arty is             -- top level
                                        -- implements arty_sram_aif
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
end sys_tst_sram_arty;

architecture syn of sys_tst_sram_arty is
  
  signal CLK100_BUF :   slbit := '0';

  signal CLK :   slbit := '0';

  signal CE_USEC :  slbit := '0';
  signal CE_MSEC :  slbit := '0';

  signal CLKS :  slbit := '0';
  signal CES_MSEC : slbit := '0';

  signal CLKMIG : slbit := '0';
  signal CLKREF : slbit := '0';
  
  signal LOCKED     : slbit := '0';   -- raw LOCKED
  signal LOCKED_CLK : slbit := '0';   -- sync'ed to CLK

  signal GBL_RESET : slbit := '0';
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
  signal RB_SRES_HIO    : rb_sres_type := rb_sres_init;
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

  signal R_DIMCNT : slv2  := (others=>'0');
  signal R_DIMFLG : slbit := '0';

  constant rbaddr_rbmon : slv16 := x"ffe8"; -- ffe8/0008: 1111 1111 1110 1xxx
  constant rbaddr_sysmon: slv16 := x"fb00"; -- fb00/0080: 1111 1011 0xxx xxxx

  constant sysid_proj  : slv16 := x"0104";   -- tst_sram
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
      CLK0      => CLK,
      CE0_USEC  => CE_USEC,
      CE0_MSEC  => CE_MSEC,
      CLK1      => CLKS,
      CE1_USEC  => open,
      CE1_MSEC  => CES_MSEC,
      CLK2      => CLKMIG,
      CLK3      => CLKREF,
      LOCKED    => LOCKED
    );
    
  CDC_CLK_LOCKED : cdc_signal_s1_as
    port map (
      CLKO  => CLK,
      DI    => LOCKED,
      DO    => LOCKED_CLK
    );
  
  GBL_RESET <= not LOCKED_CLK;

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
      RESET    => GBL_RESET,
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
  
  MEM_RESET <= not LOCKED_CLK or MEM_RESET_RRI;
  
  MEMCTL: sramif_mig_arty               -- SRAM to MIG iface -----------------
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
      CLKMIG       => CLKMIG,
      CLKREF       => CLKREF,
      TEMP         => XADC_TEMP,
      MONI         => MIG_MONI,
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
      DDR3_ODT     => DDR3_ODT
    );

  HIO : sn_humanio_emu_rbus
    generic map (
      SWIDTH   => 16,
      BWIDTH   =>  5,
      LWIDTH   => 16,
      DCWIDTH  =>  3)
    port map (
      CLK     => CLK,
      RESET   => '0',
      RB_MREQ => RB_MREQ,
      RB_SRES => RB_SRES_HIO,
      SWI     => SWI,
      BTN     => BTN,
      LED     => LED,
      DSP_DAT => DSP_DAT,
      DSP_DP  => DSP_DP
    );

  SMRB: sysmonx_rbus_arty
    generic map (                     -- use default INIT_ (LP: Vccint=0.95)
      CLK_MHZ  => sys_conf_clksys_mhz,
      RB_ADDR  => rbaddr_sysmon)
    port map (
      CLK      => CLK,
      RESET    => GBL_RESET,
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

  RB_SRES_OR : rb_sres_or_4             -- rbus or ---------------------------
    port map (
      RB_SRES_1  => RB_SRES_TST,
      RB_SRES_2  => RB_SRES_HIO,
      RB_SRES_3  => RB_SRES_SYSMON,
      RB_SRES_4  => RB_SRES_USRACC,
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

  DSP_DP(3) <= not SER_MONI.txok;
  DSP_DP(2) <= SER_MONI.txact;
  DSP_DP(1) <= not SER_MONI.rxok;
  DSP_DP(0) <= SER_MONI.rxact;

  DSP_DP(7 downto 4) <= "0010";
  DSP_DAT(31 downto 16) <= SER_MONI.abclkdiv(11 downto 0) &
                           '0' & SER_MONI.abclkdiv_f;

  -- red LED for serious error conditions
  O_RGBLED0(0) <= R_DIMFLG and (I_BTN(0) or not LOCKED);
  O_RGBLED1(0) <= R_DIMFLG and (I_BTN(0));
  O_RGBLED2(0) <= R_DIMFLG and (I_BTN(0) or MIG_MONI.miguirst);
  O_RGBLED3(0) <= R_DIMFLG and (I_BTN(0) or MIG_MONI.migcacow);

  -- green LED for activity
  O_RGBLED0(1) <= R_DIMFLG and (I_BTN(1) or  MEM_ACT_R);
  O_RGBLED1(1) <= R_DIMFLG and (I_BTN(1) or  MEM_ACT_W);
  O_RGBLED2(1) <= R_DIMFLG and (I_BTN(1) or (MIG_MONI.migcbusy xor I_BTN(3)));
  O_RGBLED3(1) <= R_DIMFLG and (I_BTN(1) or  MIG_MONI.migwbusy);
  
  -- blue LED currently unused
  O_RGBLED0(2) <= R_DIMFLG and (I_BTN(2));
  O_RGBLED1(2) <= R_DIMFLG and (I_BTN(2));
  O_RGBLED2(2) <= R_DIMFLG and (I_BTN(2));
  O_RGBLED3(2) <= R_DIMFLG and (I_BTN(2));

end syn;

