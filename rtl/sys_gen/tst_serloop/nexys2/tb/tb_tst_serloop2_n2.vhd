-- $Id: tb_tst_serloop2_n2.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tb_tst_serloop2_n2 - sim
-- Description:    Test bench for sys_tst_serloop2_n2
--
-- Dependencies:   simlib/simclk
--                 vlib/xlib/dcm_sfs
--                 sys_tst_serloop2_n2 [UUT]
--                 tb/tb_tst_serloop
--
-- To test:        sys_tst_serloop2_n2
--
-- Target Devices: generic
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-09-03   805   1.2    remove CLK_STOP logic (simstop via report)
-- 2011-12-23   444   1.1    use new simclk; remove clksys output hack
-- 2011-11-23   432   1.0.2  update O_FLA_CE_N usage
-- 2011-11-17   426   1.0.1  use dcm_sfs now
-- 2011-11-13   424   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.xlib.all;
use work.simlib.all;

entity tb_tst_serloop2_n2 is
end tb_tst_serloop2_n2;

architecture sim of tb_tst_serloop2_n2 is
  
  signal CLK50 : slbit := '0';

  signal CLKS  : slbit := '0';
  signal CLKH  : slbit := '0';

  signal I_RXD : slbit := '1';
  signal O_TXD : slbit := '1';
  signal I_SWI : slv8 := (others=>'0');
  signal I_BTN : slv4 := (others=>'0');

  signal O_FUSP_RTS_N : slbit := '0';
  signal I_FUSP_CTS_N : slbit := '0';
  signal I_FUSP_RXD : slbit := '1';
  signal O_FUSP_TXD : slbit := '1';

  signal RXD : slbit := '1';
  signal TXD : slbit := '1';
  signal SWI : slv8 := (others=>'0');
  signal BTN : slv4 := (others=>'0');

  signal FUSP_RTS_N : slbit := '0';
  signal FUSP_CTS_N : slbit := '0';
  signal FUSP_RXD : slbit := '1';
  signal FUSP_TXD : slbit := '1';
  
  constant clock_period : Delay_length :=   20 ns;
  constant clock_offset : Delay_length :=  200 ns;
  constant delay_time :   Delay_length :=    2 ns;
  
begin

  SYSCLK : simclk
    generic map (
      PERIOD => clock_period,
      OFFSET => clock_offset)
    port map (
      CLK       => CLK50
    );

  DCM_S : dcm_sfs
    generic map (
      CLKFX_DIVIDE   => 5,
      CLKFX_MULTIPLY => 6,
      CLKIN_PERIOD   => 20.0)
    port map (
      CLKIN   => CLK50,
      CLKFX   => CLKS,
      LOCKED  => open
    );
  
  DCM_H : dcm_sfs
    generic map (
      CLKFX_DIVIDE   => 2,
      CLKFX_MULTIPLY => 4,
      CLKIN_PERIOD   => 20.0)
    port map (
      CLKIN   => CLK50,
      CLKFX   => CLKH,
      LOCKED  => open
    );
      
  UUT : entity work.sys_tst_serloop2_n2
    port map (
      I_CLK50      => CLK50,
      I_RXD        => I_RXD,
      O_TXD        => O_TXD,
      I_SWI        => I_SWI,
      I_BTN        => I_BTN,
      O_LED        => open,
      O_ANO_N      => open,
      O_SEG_N      => open,
      O_MEM_CE_N   => open,
      O_MEM_BE_N   => open,
      O_MEM_WE_N   => open,
      O_MEM_OE_N   => open,
      O_MEM_ADV_N  => open,
      O_MEM_CLK    => open,
      O_MEM_CRE    => open,
      I_MEM_WAIT   => '0',
      O_MEM_ADDR   => open,
      IO_MEM_DATA  => open,
      O_FLA_CE_N   => open,
      O_FUSP_RTS_N => O_FUSP_RTS_N,
      I_FUSP_CTS_N => I_FUSP_CTS_N,
      I_FUSP_RXD   => I_FUSP_RXD,
      O_FUSP_TXD   => O_FUSP_TXD
    );

  GENTB : entity work.tb_tst_serloop
    port map (
      CLKS      => CLKS,
      CLKH      => CLKH,
      P0_RXD    => RXD,
      P0_TXD    => TXD,
      P0_RTS_N  => '0',
      P0_CTS_N  => open,
      P1_RXD    => FUSP_RXD,
      P1_TXD    => FUSP_TXD,
      P1_RTS_N  => FUSP_RTS_N,
      P1_CTS_N  => FUSP_CTS_N,
      SWI       => SWI,
      BTN       => BTN
    );

  I_RXD        <= RXD          after delay_time;
  TXD          <= O_TXD        after delay_time;
  FUSP_RTS_N   <= O_FUSP_RTS_N after delay_time;
  I_FUSP_CTS_N <= FUSP_CTS_N   after delay_time;
  I_FUSP_RXD   <= FUSP_RXD     after delay_time;
  FUSP_TXD     <= O_FUSP_TXD   after delay_time;

  I_SWI <= SWI after delay_time;
  I_BTN <= BTN after delay_time;

end sim;
