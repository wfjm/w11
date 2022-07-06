-- $Id: sys_tst_rlink_arty.vhd 1247 2022-07-06 07:04:33Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_tst_rlink_arty - syn
-- Description:    rlink tester design for arty board
--
-- Dependencies:   vlib/xlib/s7_cmt_sfs
--                 vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_2line_iob
--                 bplib/bpgen/bp_swibtnled
--                 vlib/rlink/rlink_sp1c
--                 rbd_tst_rlink
--                 bplib/bpgen/rgbdrv_master
--                 bplib/bpgen/rgbdrv_analog_rbus
--                 bplib/sysmon/sysmonx_rbus_arty
--                 vlib/rbus/rbd_usracc
--                 vlib/rbus/rb_sres_or_4
--
-- Test bench:     tb/tb_tst_rlink_arty
--
-- Target Devices: generic
-- Tool versions:  viv 2015.4-2022.1; ghdl 0.33-2.0.0
--
-- Synthesized (viv):
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2022-07-05  1247 2022.1  xc7a35t-1L   1033  1528    34   3.0   543
-- 2019-02-02  1108 2018.3  xc7a35t-1L   1034  1613    36   3.0   550
-- 2019-02-02  1108 2017.2  xc7a35t-1L   1036  1678    36   3.0   557
-- 2017-06-05   907 2016.4  xc7a35t-1L   1033  1658    36   3.0   544
-- 2016-03-27   753 2015.4  xc7a35t-1L    980  1396    36   3.0   494 meminf
-- 2016-03-13   743 2015.4  xc7a35t-1L    980  1390    64   4.5   514 +XADC
-- 2016-02-20   734 2015.4  xc7a35t-1L    941  1352    64   4.5   478  
-- 2016-02-14   731 2015.4  xc7a35t-1L    777  1313    64   4.5   399  
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-04-02   758   1.1.5  add rbd_usracc (bitfile+jtag timestamp access)
-- 2016-03-19   748   1.1.4  define rlink SYSID
-- 2016-03-13   743   1.1.3  hardwire XON=1, all SWI now unused
-- 2016-03-12   741   1.1.2  use sysmonx_rbus_arty now
-- 2016-03-06   740   1.1.1  add A_VPWRN/P to baseline config
-- 2016-03-06   738   1.1    add xadc_rbus
-- 2016-02-20   734   1.0.1  add rgbdrv_analog_rbus for four rgb leds
-- 2016-02-14   731   1.0    Initial version (derived from sys_tst_rlink_b3)
------------------------------------------------------------------------------
-- Usage of Arty Switches, Buttons, LEDs:
--
--    SWI(3:2): no function
--    SWI(1):   -unused-
--    SWI(0):   -unused-
--
--    LED(3):   not SER_MONI.txok       (shows tx back pressure)
--    LED(2):   SER_MONI.txact          (shows tx activity)
--    LED(1):   not SER_MONI.rxok       (shows rx back pressure)
--    LED(0):   SER_MONI.rxact          (shows rx activity)
--

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.serportlib.all;
use work.rblib.all;
use work.rbdlib.all;
use work.rlinklib.all;
use work.bpgenlib.all;
use work.bpgenrbuslib.all;
use work.sysmonrbuslib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_rlink_arty is            -- top level
                                        -- implements arty_aif
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
    A_VPWRP : in slv4;                  -- arty pwrmon (pos)
    A_VPWRN : in slv4                   -- arty pwrmon (neg)
  );
end sys_tst_rlink_arty;

architecture syn of sys_tst_rlink_arty is

  signal CLK :   slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
    
  signal SWI     : slv4  := (others=>'0');
  signal BTN     : slv4  := (others=>'0');
  signal LED     : slv4  := (others=>'0');

  signal RESET   : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;
  signal RB_SRES_TST    : rb_sres_type := rb_sres_init;
  signal RB_SRES_RGB    : rb_sres_type := rb_sres_init;
  signal RB_SRES_RGB0   : rb_sres_type := rb_sres_init;
  signal RB_SRES_RGB1   : rb_sres_type := rb_sres_init;
  signal RB_SRES_RGB2   : rb_sres_type := rb_sres_init;
  signal RB_SRES_RGB3   : rb_sres_type := rb_sres_init;
  signal RB_SRES_SYSMON : rb_sres_type := rb_sres_init;
  signal RB_SRES_USRACC : rb_sres_type := rb_sres_init;

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4  := (others=>'0');
  
  signal SER_MONI : serport_moni_type := serport_moni_init;
  signal STAT    : slv8  := (others=>'0');

  signal RGBCNTL : slv3  := (others=>'0');
  signal DIMCNTL : slv12 := (others=>'0');
  
  constant rbaddr_rgb0  : slv16 := x"fc00"; -- fe00/0004: 1111 1100 0000 00xx
  constant rbaddr_rgb1  : slv16 := x"fc04"; -- fe04/0004: 1111 1100 0000 01xx
  constant rbaddr_rgb2  : slv16 := x"fc08"; -- fe08/0004: 1111 1100 0000 10xx
  constant rbaddr_rgb3  : slv16 := x"fc0c"; -- fe0c/0004: 1111 1100 0000 11xx
  constant rbaddr_sysmon: slv16 := x"fb00"; -- fb00/0080: 1111 1011 0xxx xxxx

  constant sysid_proj  : slv16 := x"0101";   -- tst_rlink
  constant sysid_board : slv8  := x"07";     -- arty
  constant sysid_vers  : slv8  := x"00";

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;

  RESET <= '0';                         -- so far not used
  
  GEN_CLKSYS : s7_cmt_sfs
    generic map (
      VCO_DIVIDE     => sys_conf_clksys_vcodivide,
      VCO_MULTIPLY   => sys_conf_clksys_vcomultiply,
      OUT_DIVIDE     => sys_conf_clksys_outdivide,
      CLKIN_PERIOD   => 10.0,
      CLKIN_JITTER   => 0.01,
      STARTUP_WAIT   => false,
      GEN_TYPE       => sys_conf_clksys_gentype)
    port map (
      CLKIN   => I_CLK100,
      CLKFX   => CLK,
      LOCKED  => open
    );

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 7,
      USECDIV  => sys_conf_clksys_mhz,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  IOB_RS232 : bp_rs232_2line_iob
    port map (
      CLK      => CLK,
      RXD      => RXD,
      TXD      => TXD,
      I_RXD    => I_RXD,
      O_TXD    => O_TXD
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

  RLINK : rlink_sp1c
    generic map (
      BTOWIDTH     => 6,
      RTAWIDTH     => 12,
      SYSID        => sysid_proj & sysid_board & sysid_vers,
      IFAWIDTH     => 5,
      OFAWIDTH     => 5,
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      CDWIDTH      => 12,
      CDINIT       => sys_conf_ser2rri_cdinit,
      RBMON_AWIDTH => 0,                -- must be 0, rbmon in rbd_tst_rlink
      RBMON_RBADDR => (others=>'0'))
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      CE_INT   => CE_MSEC,
      RESET    => RESET,
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

  RBDTST : entity work.rbd_tst_rlink
    port map (
      CLK         => CLK,
      RESET       => RESET,
      CE_USEC     => CE_USEC,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_TST,
      RB_LAM      => RB_LAM,
      RB_STAT     => RB_STAT,
      RB_SRES_TOP => RB_SRES,
      RXSD        => RXD,
      RXACT       => SER_MONI.rxact,
      STAT        => STAT
    );

  RGBMSTR : rgbdrv_master
    generic map (
      DWIDTH => DIMCNTL'length)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      CE_USEC  => CE_USEC,
      RGBCNTL  => RGBCNTL,
      DIMCNTL  => DIMCNTL
    );

  RGB0 : rgbdrv_analog_rbus
    generic map (
      DWIDTH   => DIMCNTL'length,
      RB_ADDR  => rbaddr_rgb0)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES_RGB0,
      RGBCNTL  => RGBCNTL,
      DIMCNTL  => DIMCNTL,
      O_RGBLED => O_RGBLED0
    );

  RGB1 : rgbdrv_analog_rbus
    generic map (
      DWIDTH   => DIMCNTL'length,
      RB_ADDR  => rbaddr_rgb1)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES_RGB1,
      RGBCNTL  => RGBCNTL,
      DIMCNTL  => DIMCNTL,
      O_RGBLED => O_RGBLED1
    );

  RGB2 : rgbdrv_analog_rbus
    generic map (
      DWIDTH   => DIMCNTL'length,
      RB_ADDR  => rbaddr_rgb2)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES_RGB2,
      RGBCNTL  => RGBCNTL,
      DIMCNTL  => DIMCNTL,
      O_RGBLED => O_RGBLED2
    );

  RGB3 : rgbdrv_analog_rbus
    generic map (
      DWIDTH   => DIMCNTL'length,
      RB_ADDR  => rbaddr_rgb3)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES_RGB3,
      RGBCNTL  => RGBCNTL,
      DIMCNTL  => DIMCNTL,
      O_RGBLED => O_RGBLED3
    );

  SMRB : if sys_conf_rbd_sysmon  generate    
    I0: sysmonx_rbus_arty
      generic map (                     -- use default INIT_ (LP: Vccint=0.95)
        CLK_MHZ  => sys_conf_clksys_mhz,
        RB_ADDR  => rbaddr_sysmon)
      port map (
        CLK      => CLK,
        RESET    => RESET,
        RB_MREQ  => RB_MREQ,
        RB_SRES  => RB_SRES_SYSMON,
        ALM      => open,
        OT       => open,
        TEMP     => open,
        VPWRN    => A_VPWRN,
        VPWRP    => A_VPWRP
      );
  end generate SMRB;

  RB_SRES_ORRGB : rb_sres_or_4
    port map (
      RB_SRES_1  => RB_SRES_RGB0,
      RB_SRES_2  => RB_SRES_RGB1,
      RB_SRES_3  => RB_SRES_RGB2,
      RB_SRES_4  => RB_SRES_RGB3,
      RB_SRES_OR => RB_SRES_RGB
    );

  UARB : rbd_usracc
    port map (
      CLK     => CLK,
      RB_MREQ => RB_MREQ,
      RB_SRES => RB_SRES_USRACC
    );

  RB_SRES_OR1 : rb_sres_or_4
    port map (
      RB_SRES_1  => RB_SRES_TST,
      RB_SRES_2  => RB_SRES_RGB,
      RB_SRES_3  => RB_SRES_SYSMON,
      RB_SRES_4  => RB_SRES_USRACC,
      RB_SRES_OR => RB_SRES
    );

  LED(3) <= not SER_MONI.txok;
  LED(2) <= SER_MONI.txact;
  LED(1) <= not SER_MONI.rxok;
  LED(0) <= SER_MONI.rxact;
    
end syn;
