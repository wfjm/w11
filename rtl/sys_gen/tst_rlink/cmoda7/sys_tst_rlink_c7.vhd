-- $Id: sys_tst_rlink_c7.vhd 1247 2022-07-06 07:04:33Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_tst_rlink_c7 - syn
-- Description:    rlink tester design for CmodA7 board
--
-- Dependencies:   vlib/xlib/s7_cmt_sfs
--                 vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_2line_iob
--                 vlib/rlink/rlink_sp1c
--                 rbd_tst_rlink
--                 bplib/bpgen/rgbdrv_master
--                 bplib/bpgen/rgbdrv_analog_rbus
--                 bplib/sysmon/sysmonx_rbus_base
--                 vlib/rbus/rbd_usracc
--                 vlib/rbus/rb_sres_or_4
--                 vlib/xlib/iob_reg_o_gen
--
-- Test bench:     tb/tb_tst_rlink_c7
--
-- Target Devices: generic
-- Tool versions:  viv 2016.4-2022.1; ghdl 0.34-2.0.0
--
-- Synthesized (viv):
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic
-- 2022-07-05  1247 2022.1  xc7a35t-1     913  1402    34   3.0   494
-- 2019-02-02  1108 2018.3  xc7a35t-1     913  1494    36   3.0   496 
-- 2019-02-02  1108 2017.2  xc7a35t-1     914  1581    36   3.0   510 
-- 2017-06-05   907 2016.4  xc7a35t-1     913  1556    36   3.0   513 
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-06-04   906   1.0    Initial version (derived from sys_tst_rlink_arty)
------------------------------------------------------------------------------
-- Usage of CmodA7 Buttons, LEDs, RGBLEDs:
-- 
--    LED(1):   SER_MONI.txact          (shows tx activity)
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

entity sys_tst_rlink_c7 is            -- top level
                                        -- implements cmoda7_aif
  port (
    I_CLK12 : in slbit;                 -- 12 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_BTN : in slv2;                    -- c7 buttons
    O_LED : out slv2;                   -- c7 leds
    O_RGBLED0_N : out slv3              -- c7 rgb-led 0
  );
end sys_tst_rlink_c7;

architecture syn of sys_tst_rlink_c7 is

  signal CLK :   slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
    
  signal LED     : slv2  := (others=>'0');

  signal RESET   : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;
  signal RB_SRES_TST    : rb_sres_type := rb_sres_init;
  signal RB_SRES_RGB0   : rb_sres_type := rb_sres_init;
  signal RB_SRES_SYSMON : rb_sres_type := rb_sres_init;
  signal RB_SRES_USRACC : rb_sres_type := rb_sres_init;

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4  := (others=>'0');
  
  signal SER_MONI : serport_moni_type := serport_moni_init;
  signal STAT    : slv8  := (others=>'0');

  signal RGBCNTL : slv3  := (others=>'0');
  signal DIMCNTL : slv12 := (others=>'0');
  
  constant rbaddr_rgb0  : slv16 := x"fc00"; -- fe00/0004: 1111 1100 0000 00xx
  constant rbaddr_sysmon: slv16 := x"fb00"; -- fb00/0080: 1111 1011 0xxx xxxx

  constant sysid_proj  : slv16 := x"0101";   -- tst_rlink
  constant sysid_board : slv8  := x"09";     -- cmoda7
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
      CLKIN_PERIOD   => 83.3,
      CLKIN_JITTER   => 0.01,
      STARTUP_WAIT   => false,
      GEN_TYPE       => sys_conf_clksys_gentype)
    port map (
      CLKIN   => I_CLK12,
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
      ACTLOW   => '1',                  -- CmodA7 has active low RGBLED
      RB_ADDR  => rbaddr_rgb0)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES_RGB0,
      RGBCNTL  => RGBCNTL,
      DIMCNTL  => DIMCNTL,
      O_RGBLED => O_RGBLED0_N
    );

  SMRB : if sys_conf_rbd_sysmon  generate    
    I0: sysmonx_rbus_base
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
        TEMP     => open
      );
  end generate SMRB;

  UARB : rbd_usracc
    port map (
      CLK     => CLK,
      RB_MREQ => RB_MREQ,
      RB_SRES => RB_SRES_USRACC
    );

  RB_SRES_OR1 : rb_sres_or_4
    port map (
      RB_SRES_1  => RB_SRES_TST,
      RB_SRES_2  => RB_SRES_RGB0,
      RB_SRES_3  => RB_SRES_SYSMON,
      RB_SRES_4  => RB_SRES_USRACC,
      RB_SRES_OR => RB_SRES
    );

  IOB_LED : iob_reg_o_gen
    generic map (DWIDTH => O_LED'length)
    port map (CLK => CLK, CE => '1', DO => LED,    PAD => O_LED);

  LED(1) <= SER_MONI.txact;
  LED(0) <= SER_MONI.rxact;
  
end syn;
