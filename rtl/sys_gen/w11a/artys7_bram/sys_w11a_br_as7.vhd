-- $Id: sys_w11a_br_as7.vhd 1211 2021-08-28 11:20:34Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_w11a_br_as7 - syn
-- Description:    w11a test design for as7
--
-- Dependencies:   bplib/bpgen/s7_cmt_1ce1ce
--                 bplib/bpgen/bp_rs232_2line_iob
--                 vlib/rlink/rlink_sp2c
--                 w11a/pdp11_sys70
--                 ibus/ibdr_maxisys
--                 w11a/pdp11_bram_memctl
--                 vlib/rlink/ioleds_sp1c
--                 pdp11_hio70_artys7
--                 bplib/bpgen/bp_swibtnled
--                 bplib/bpgen/rgbdrv_3x2mux
--                 bplib/sysmon/sysmonx_rbus_base
--                 vlib/rbus/rbd_usracc
--                 vlib/rbus/rb_sres_or_3
--
-- Test bench:     tb/tb_sys_w11a_br_as7
--
-- Target Devices: generic
-- Tool versions:  viv 2017.2-2018.3; ghdl 0.34-0.35
--
-- Synthesized:
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2019-05-19  1150 2017.2  xc7s50       2821  6206   273  68.0  1887 +dz11
-- 2019-02-02  1108 2018.3  xc7s50       2568  5811   170  67.5  1799
-- 2019-02-02  1108 2017.2  xc7s50       2556  5503   170  67.5  1666 +dmpcnt
-- 2018-09-15  1045 2017.2  xc7s50       2333  5156   138  67.5  1592 +KW11P
-- 2018-08-11  1038 2018.2  xc7s50       2279  5369   138  67.5  1598
-- 2018-08-11  1038 2018.1  xc7s50       2279  5381   138  67.5  1597
-- 2018-08-11  1038 2017.4  xc7s50       2274  5137   138  67.5  1549
-- 2018-08-11  1038 2017.2  xc7s50       2271  5083   138  67.5  1560  
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-16  1086   1.2    use s7_cmt_1ce1ce
-- 2018-10-13  1055   1.1    use DM_STAT_EXP; IDEC to maxisys; setup PERFEXT
-- 2018-08-11  1038   1.0    Initial version (derived from sys_w11a_aa7)
------------------------------------------------------------------------------
--
-- w11a test design for artys7 (using BRAM as memory)
--    w11a + rlink + serport
--
-- Usage of Arty S7 switches, Buttons, LEDs
--
--    SWI(3:0):  determine what is displayed in the LEDs and RGBLEDs
--      00xy  LED shows IO
--              y=1 enables CPU activities on RGB_G,RGB_R
--              x=1 enables MEM activities on RGB_B
--      0100  LED+RGB give DR emulation 'light show'
--      1xyy  LED+RGB show low (x=0) or high (x=1) byte of
--              yy = 00:   abclkdiv & abclkdiv_f
--                   01:   PC
--                   10:   DISPREG
--                   11:   DR emulation
--             LED shows bit 7:4, RGB bit 1:0 of the byte selected by x
--      
-- LED and RGB  assignment for SWI=00xy
--   LED     IO activity
--             (3)   not SER_MONI.txok       (shows tx back pressure)
--             (2)   SER_MONI.txact          (shows tx activity)
--             (1)   not SER_MONI.rxok       (shows rx back pressure)
--             (0)   SER_MONI.rxact          (shows rx activity)
--   RGB_G   CPU busy       (active cpugo=1, enabled with SWI(0))
--             (1)   kernel mode, non-wait
--             (0)   user or supervisor mode
--   RGB_R   CPU rust       (active cpugo=0, enabled with SWI(0))
--           (1:0)   cpurust code
--   RGB_B   MEM/cmd busy   (enabled with SWI(1))
--             (1)   cmdbusy (all rlink access, mostly rdma)
--             (0)   not cpugo
--
-- LED and RGB  assignment for SWI=0100 (DR emulation)
--   LED     DR(15:12)
--   RGB_B   DR( 9:08)
--   RGB_G   DR( 5:04)
--   RGB_R   DR( 1:00)
--

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
use work.iblib.all;
use work.ibdlib.all;
use work.pdp11.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_w11a_br_as7 is               -- top level
                                        -- implements artys7_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv4;                    -- artys7 switches
    I_BTN : in slv4;                    -- artys7 buttons
    O_LED : out slv4;                   -- artys7 leds
    O_RGBLED0 : out slv3;               -- artys7 rgb-led 0
    O_RGBLED1 : out slv3                -- artys7 rgb-led 1
  );
end sys_w11a_br_as7;

architecture syn of sys_w11a_br_as7 is

  signal CLK :   slbit := '0';

  signal RESET   : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal CLKS :  slbit := '0';
  signal CES_MSEC : slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
    
  signal RB_MREQ        : rb_mreq_type := rb_mreq_init;
  signal RB_SRES        : rb_sres_type := rb_sres_init;
  signal RB_SRES_CPU    : rb_sres_type := rb_sres_init;
  signal RB_SRES_SYSMON : rb_sres_type := rb_sres_init;
  signal RB_SRES_USRACC : rb_sres_type := rb_sres_init;

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4  := (others=>'0');
  
  signal SER_MONI : serport_moni_type := serport_moni_init;

  signal GRESET  : slbit := '0';        -- general reset (from rbus)
  signal CRESET  : slbit := '0';        -- cpu reset     (from cp)
  signal BRESET  : slbit := '0';        -- bus reset     (from cp or cpu)
  signal PERFEXT : slv8  := (others=>'0');

  signal EI_PRI  : slv3   := (others=>'0');
  signal EI_VECT : slv9_2 := (others=>'0');
  signal EI_ACKM : slbit  := '0';
  signal CP_STAT : cp_stat_type := cp_stat_init;
  signal DM_STAT_EXP : dm_stat_exp_type := dm_stat_exp_init;
  
  signal MEM_REQ   : slbit := '0';
  signal MEM_WE    : slbit := '0';
  signal MEM_BUSY  : slbit := '0';
  signal MEM_ACK_R : slbit := '0';
  signal MEM_ACT_R : slbit := '0';
  signal MEM_ACT_W : slbit := '0';
  signal MEM_ADDR  : slv20 := (others=>'0');
  signal MEM_BE    : slv4  := (others=>'0');
  signal MEM_DI    : slv32 := (others=>'0');
  signal MEM_DO    : slv32 := (others=>'0');

  signal IB_MREQ : ib_mreq_type := ib_mreq_init;
  signal IB_SRES_IBDR  : ib_sres_type := ib_sres_init;

  signal DISPREG  : slv16 := (others=>'0');
  signal ABCLKDIV : slv16 := (others=>'0');
  signal IOLEDS   : slv4  := (others=>'0');

  signal SWI     : slv4 := (others=>'0');
  signal BTN     : slv4 := (others=>'0');
  signal LED     : slv4 := (others=>'0');
  signal RGB_R   : slv2 := (others=>'0');
  signal RGB_G   : slv2 := (others=>'0');
  signal RGB_B   : slv2 := (others=>'0');

  constant rbaddr_rbmon : slv16 := x"ffe8"; -- ffe8/0008: 1111 1111 1110 1xxx
  constant rbaddr_sysmon: slv16 := x"fb00"; -- fb00/0080: 1111 1011 0xxx xxxx

  constant sysid_proj  : slv16 := x"0201";   -- w11a
  constant sysid_board : slv8  := x"0a";     -- artys7
  constant sysid_vers  : slv8  := x"00";

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;
  
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

  IOB_RS232 : bp_rs232_2line_iob         -- serport iob ----------------------
    port map (
      CLK      => CLKS,
      RXD      => RXD,
      TXD      => TXD,
      I_RXD    => I_RXD,
      O_TXD    => O_TXD
    );

  RLINK : rlink_sp2c                    -- rlink for serport -----------------
    generic map (
      BTOWIDTH     => 7,                -- 128 cycles access timeout
      RTAWIDTH     => 12,
      SYSID        => sysid_proj & sysid_board & sysid_vers,
      IFAWIDTH     => 5,                --  32 word input fifo
      OFAWIDTH     => 5,                --  32 word output fifo
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      CDWIDTH      => 12,
      CDINIT       => sys_conf_ser2rri_cdinit,
      RBMON_AWIDTH => sys_conf_rbmon_awidth,
      RBMON_RBADDR => rbaddr_rbmon)
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      CE_INT   => CE_MSEC,
      RESET    => RESET,
      CLKS     => CLKS,
      CES_MSEC => CES_MSEC,
      ENAXON   => '1',                  -- XON statically enabled !
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

  PERFEXT(0) <= '0';                    -- unused (ext_rdrhit)
  PERFEXT(1) <= '0';                    -- unused (ext_wrrhit)
  PERFEXT(2) <= '0';                    -- unused (ext_wrflush)
  PERFEXT(3) <= SER_MONI.rxact;         -- ext_rlrxact
  PERFEXT(4) <= not SER_MONI.rxok;      -- ext_rlrxback
  PERFEXT(5) <= SER_MONI.txact;         -- ext_rltxact
  PERFEXT(6) <= not SER_MONI.txok;      -- ext_rltxback
  PERFEXT(7) <= CE_USEC;                -- ext_usec
  
  SYS70 : pdp11_sys70                   -- 1 cpu system ----------------------
    port map (
      CLK         => CLK,
      RESET       => RESET,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_CPU,
      RB_STAT     => RB_STAT,
      RB_LAM_CPU  => RB_LAM(0),
      GRESET      => GRESET,
      CRESET      => CRESET,
      BRESET      => BRESET,
      CP_STAT     => CP_STAT,
      EI_PRI      => EI_PRI,
      EI_VECT     => EI_VECT,
      EI_ACKM     => EI_ACKM,
      PERFEXT     => PERFEXT,
      IB_MREQ     => IB_MREQ,
      IB_SRES     => IB_SRES_IBDR,
      MEM_REQ     => MEM_REQ,
      MEM_WE      => MEM_WE,
      MEM_BUSY    => MEM_BUSY,
      MEM_ACK_R   => MEM_ACK_R,
      MEM_ADDR    => MEM_ADDR,
      MEM_BE      => MEM_BE,
      MEM_DI      => MEM_DI,
      MEM_DO      => MEM_DO,
      DM_STAT_EXP => DM_STAT_EXP
    );


  IBDR_SYS : ibdr_maxisys               -- IO system -------------------------
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      RESET    => GRESET,
      BRESET   => BRESET,
      ITIMER   => DM_STAT_EXP.se_itimer,
      IDEC     => DM_STAT_EXP.se_idec,
      CPUSUSP  => CP_STAT.cpususp,
      RB_LAM   => RB_LAM(15 downto 1),
      IB_MREQ  => IB_MREQ,
      IB_SRES  => IB_SRES_IBDR,
      EI_ACKM  => EI_ACKM,
      EI_PRI   => EI_PRI,
      EI_VECT  => EI_VECT,
      DISPREG  => DISPREG
    );
  
  BRAM_CTL: pdp11_bram_memctl           -- memory controller -----------------
    generic map (
      MAWIDTH => sys_conf_memctl_mawidth,
      NBLOCK  => sys_conf_memctl_nblock)
    port map (
      CLK         => CLK,
      RESET       => GRESET,
      REQ         => MEM_REQ,
      WE          => MEM_WE,
      BUSY        => MEM_BUSY,
      ACK_R       => MEM_ACK_R,
      ACK_W       => open,
      ACT_R       => MEM_ACT_R,
      ACT_W       => MEM_ACT_W,
      ADDR        => MEM_ADDR,
      BE          => MEM_BE,
      DI          => MEM_DI,
      DO          => MEM_DO
    );

  LED_IO : ioleds_sp1c                  -- hio leds from serport -------------
    port map (
      SER_MONI => SER_MONI,
      IOLEDS   => IOLEDS
    );

  ABCLKDIV <= SER_MONI.abclkdiv(11 downto 0) & '0' & SER_MONI.abclkdiv_f;

  HIO70 : entity work.pdp11_hio70_artys7 -- hio from sys70 --------------------
    port map (
      CLK         => CLK,
      MODE        => SWI,
      MEM_ACT_R   => MEM_ACT_R,
      MEM_ACT_W   => MEM_ACT_W,
      CP_STAT     => CP_STAT,
      DM_STAT_EXP => DM_STAT_EXP,
      DISPREG     => DISPREG,
      IOLEDS      => IOLEDS,
      ABCLKDIV    => ABCLKDIV,
      LED         => LED,
      RGB_R       => RGB_R,
      RGB_G       => RGB_G,
      RGB_B       => RGB_B
    );

  HIO : bp_swibtnled
    generic map (
      SWIDTH   => I_SWI'length,
      BWIDTH   => I_BTN'length,
      LWIDTH   => O_LED'length,
      DEBOUNCE => sys_conf_hio_debounce)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      SWI     => SWI,                   
      BTN     => BTN,                   
      LED     => LED,                   
      I_SWI   => I_SWI,                 
      I_BTN   => I_BTN,
      O_LED   => O_LED
    );

  HIORGB : rgbdrv_3x2mux
    port map (
      CLK       => CLK,
      RESET     => RESET,
      CE_USEC   => CE_USEC,
      DATR      => RGB_R,
      DATG      => RGB_G,
      DATB      => RGB_B,
      O_RGBLED0 => O_RGBLED0,
      O_RGBLED1 => O_RGBLED1
    );

  SMRB : if sys_conf_rbd_sysmon  generate    
    I0: sysmonx_rbus_base
      generic map (                     -- use default INIT_ (Vccint=1.00)
        CLK_MHZ  => sys_conf_clksys_mhz,
        RB_ADDR  => rbaddr_sysmon)
      port map (
        CLK      => CLK,
        RESET    => RESET,
        RB_MREQ  => RB_MREQ,
        RB_SRES  => RB_SRES_SYSMON,
        ALM      => open,
        OT       => open,
        TEMP     => open
      );
  end generate SMRB;

  UARB : rbd_usracc
    port map (
      CLK     => CLK,
      RB_MREQ => RB_MREQ,
      RB_SRES => RB_SRES_USRACC
    );

  RB_SRES_OR : rb_sres_or_3             -- rbus or ---------------------------
    port map (
      RB_SRES_1  => RB_SRES_CPU,
      RB_SRES_2  => RB_SRES_SYSMON,
      RB_SRES_3  => RB_SRES_USRACC,
      RB_SRES_OR => RB_SRES
    );
  
end syn;
