-- $Id: sys_tst_serloop2_n3.vhd 1369 2023-02-08 18:59:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_tst_serloop2_n3 - syn
-- Description:    Serial link tester design for nexys3 (serport_2clock case)
--
-- Dependencies:   vlib/xlib/dcm_sfs
--                 genlib/clkdivce
--                 bpgen/bp_rs232_2l4l_iob
--                 bpgen/sn_humanio
--                 tst_serloop_hiomap
--                 vlib/serport/serport_2clock
--                 tst_serloop
--                 vlib/nxcramlib/nx_cram_dummy
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.1; ghdl 0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2011-11-27   433 13.1    O40d xc6slx16-2   486  652   59  237 t  6.3
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-11   438   1.0.2  add dcm monitor hack; use with ser=usr=100 MHz
-- 2011-12-09   437   1.0.1  rename serport stat->moni port
-- 2011-11-27   433   1.0    Initial version
------------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.bpgenlib.all;
use work.tst_serlooplib.all;
use work.serportlib.all;
use work.nxcramlib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_serloop2_n3 is           -- top level
                                        -- implements nexys3_fusp_aif
  port (
    I_CLK100 : in slbit;                -- 100 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- n3 switches
    I_BTN : in slv5;                    -- n3 buttons
    O_LED : out slv8;                   -- n3 leds
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
    O_PPCM_CE_N : out slbit;            -- ppcm: ...
    O_PPCM_RST_N : out slbit;           -- ppcm: ...
    O_FUSP_RTS_N : out slbit;           -- fusp: rs232 rts_n
    I_FUSP_CTS_N : in slbit;            -- fusp: rs232 cts_n
    I_FUSP_RXD : in slbit;              -- fusp: rs232 rx
    O_FUSP_TXD : out slbit              -- fusp: rs232 tx
  );
end sys_tst_serloop2_n3;

architecture syn of sys_tst_serloop2_n3 is

  signal CLK :   slbit := '0';
  signal RESET : slbit := '0';

  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal CLKS :   slbit := '0';
  signal CES_MSEC : slbit := '0';

  signal RXD :   slbit := '0';
  signal TXD :   slbit := '0';
  signal CTS_N : slbit := '0';
  signal RTS_N : slbit := '0';
  
  signal SWI     : slv8  := (others=>'0');
  signal BTN     : slv5  := (others=>'0');
  signal LED     : slv8  := (others=>'0');  
  signal LED_OUT : slv8  := (others=>'0');  
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  signal HIO_CNTL : hio_cntl_type := hio_cntl_init;
  signal HIO_STAT : hio_stat_type := hio_stat_init;
  
  signal RXDATA : slv8  := (others=>'0');
  signal RXVAL :  slbit := '0';
  signal RXHOLD : slbit := '0';
  signal TXDATA : slv8  := (others=>'0');
  signal TXENA :  slbit := '0';
  signal TXBUSY : slbit := '0';
  
  signal SER_MONI : serport_moni_type  := serport_moni_init;

  -- some signals for dcm monitor hack
  signal LOCKED_DCMU : slbit := '0';
  signal LOCKED_DCMS : slbit := '0';
  signal R_MSECU_CNT : slv10 := (others=>'0');
  signal R_MSECS_CNT : slv10 := (others=>'0');

begin

  DCM_U : dcm_sfs
    generic map (
      CLKFX_DIVIDE   =>  1,             -- was 2
      CLKFX_MULTIPLY =>  1,             -- was 3
      CLKIN_PERIOD   => 10.0)
    port map (
      CLKIN   => I_CLK100,
      CLKFX   => CLK,
      LOCKED  => LOCKED_DCMU
    );

  CLKDIV_U : clkdivce
    generic map (
      CDUWIDTH => 8,
      USECDIV  => sys_conf_clkudiv_usecdiv,  -- syn:  150  sim:  30
      MSECDIV  => sys_conf_clkdiv_msecdiv)   -- syn: 1000  sim:   5
    port map (
      CLK     => CLK,
      CE_USEC => open,
      CE_MSEC => CE_MSEC
    );

  DCM_S : dcm_sfs
    generic map (
      CLKFX_DIVIDE   =>  1,             -- was 5
      CLKFX_MULTIPLY =>  1,             -- was 3
      CLKIN_PERIOD   => 10.0)
    port map (
      CLKIN   => I_CLK100,
      CLKFX   => CLKS,
      LOCKED  => LOCKED_DCMS
    );

  CLKDIV_S : clkdivce
    generic map (
      CDUWIDTH => 7,
      USECDIV  => sys_conf_clksdiv_usecdiv,  -- syn:   60  sim:  12
      MSECDIV  => sys_conf_clkdiv_msecdiv)   -- syn: 1000  sim:   5
    port map (
      CLK     => CLKS,
      CE_USEC => open,
      CE_MSEC => CES_MSEC
    );

  HIO : sn_humanio
    generic map (
      BWIDTH   => 5,
      DEBOUNCE => sys_conf_hio_debounce)
    port map (
      CLK     => CLK,
      RESET   => '0',
      CE_MSEC => CE_MSEC,
      SWI     => SWI,
      BTN     => BTN,
      LED     => LED_OUT,
      DSP_DAT => DSP_DAT,
      DSP_DP  => DSP_DP,
      I_SWI   => I_SWI,
      I_BTN   => I_BTN,
      O_LED   => O_LED,
      O_ANO_N => O_ANO_N,
      O_SEG_N => O_SEG_N
    );

  RESET <= BTN(0);                      -- BTN(0) will reset tester !!
  
  HIOMAP : tst_serloop_hiomap
    port map (
      CLK      => CLK,
      RESET    => RESET,
      HIO_CNTL => HIO_CNTL,
      HIO_STAT => HIO_STAT,
      SER_MONI => SER_MONI,
      SWI      => SWI,
      BTN      => BTN(3 downto 0),
      LED      => LED,
      DSP_DAT  => DSP_DAT,
      DSP_DP   => DSP_DP
    );

  IOB_RS232 : bp_rs232_2l4l_iob
    port map (
      CLK      => CLKS,
      RESET    => '0',
      SEL      => SWI(0),               -- port selection
      RXD      => RXD,
      TXD      => TXD,
      CTS_N    => CTS_N,
      RTS_N    => RTS_N,
      I_RXD0   => I_RXD,
      O_TXD0   => O_TXD,
      I_RXD1   => I_FUSP_RXD,
      O_TXD1   => O_FUSP_TXD,
      I_CTS1_N => I_FUSP_CTS_N,
      O_RTS1_N => O_FUSP_RTS_N
    );
  
  SERPORT : serport_2clock
    generic map (
      CDWIDTH   => 15,
      CDINIT    => sys_conf_uart_cdinit,
      RXFAWIDTH => 5,
      TXFAWIDTH => 5)
    port map (
      CLKU     => CLK,
      RESET    => RESET,
      CLKS     => CLKS,
      CES_MSEC => CES_MSEC,
      ENAXON   => HIO_CNTL.enaxon,
      ENAESC   => HIO_CNTL.enaesc,
      RXDATA   => RXDATA,
      RXVAL    => RXVAL,
      RXHOLD   => RXHOLD,
      TXDATA   => TXDATA,
      TXENA    => TXENA,
      TXBUSY   => TXBUSY,
      MONI     => SER_MONI,
      RXSD     => RXD,
      TXSD     => TXD,
      RXRTS_N  => RTS_N,
      TXCTS_N  => CTS_N
    );

  TESTER : tst_serloop
    port map (
      CLK      => CLK,
      RESET    => RESET,
      CE_MSEC  => CE_MSEC,
      HIO_CNTL => HIO_CNTL,
      HIO_STAT => HIO_STAT,
      SER_MONI => SER_MONI,
      RXDATA   => RXDATA,
      RXVAL    => RXVAL,
      RXHOLD   => RXHOLD,
      TXDATA   => TXDATA,
      TXENA    => TXENA,
      TXBUSY   => TXBUSY
    );

  SRAM_PROT : nx_cram_dummy            -- connect CRAM to protection dummy
    port map (
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
  
  O_PPCM_CE_N  <= '1';                  -- keep parallel PCM memory disabled
  O_PPCM_RST_N <= '1';                  --

  -- this is a hack to monitor the two dcm's

  proc_msecu: process (CLK)
  begin
    if rising_edge(CLK) then
      if CE_MSEC = '1' then
        R_MSECU_CNT <= slv(unsigned(R_MSECU_CNT) + 1);
      end if;
    end if;
  end process proc_msecu;

  proc_msecs: process (CLKS)
  begin
    if rising_edge(CLKS) then
      if CES_MSEC = '1' then
        R_MSECS_CNT <= slv(unsigned(R_MSECS_CNT) + 1);
      end if;
    end if;
  end process proc_msecs;
  
  LED_OUT(7) <= R_MSECU_CNT(9) or (not LOCKED_DCMU);
  LED_OUT(6) <= R_MSECS_CNT(9) or (not LOCKED_DCMS);
  LED_OUT(5 downto 0) <= LED(5 downto 0);
  
end syn;
