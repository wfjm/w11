-- $Id: tb_nexys4d.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    tb_nexys4d - sim
-- Description:    Test bench for nexys4d (base)
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--                 rlink/tbcore/tbcore_rlink
--                 xlib/sfs_gsim_core
--                 tb_nexys4d_core
--                 serport/tb/serport_master_tb
--                 nexys4d_aif [UUT]
--
-- To test:        generic, any nexys4d_aif target
--
-- Target Devices: generic
-- Tool versions:  viv 2016.2-2018.2; ghdl 0.33-0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-11-03  1064   1.0.1  use sfs_gsim_core
-- 2017-01-04   838   1.0    Initial version (derived from tb_nexys4)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.rlinklib.all;
use work.xlib.all;
use work.nexys4dlib.all;
use work.simlib.all;
use work.simbus.all;
use work.sys_conf.all;

entity tb_nexys4d is
end tb_nexys4d;

architecture sim of tb_nexys4d is
  
  signal CLKOSC : slbit := '0';         -- board clock (100 Mhz)
  signal CLKCOM : slbit := '0';         -- communication clock

  signal CLKCOM_CYCLE : integer := 0;

  signal RESET : slbit := '0';
  signal CLKDIV : slv2 := "00";         -- run with 1 clocks / bit !!
  signal RXDATA : slv8 := (others=>'0');
  signal RXVAL : slbit := '0';
  signal RXERR : slbit := '0';
  signal RXACT : slbit := '0';
  signal TXDATA : slv8 := (others=>'0');
  signal TXENA : slbit := '0';
  signal TXBUSY : slbit := '0';

  signal I_RXD : slbit := '1';
  signal O_TXD : slbit := '1';
  signal O_RTS_N : slbit := '0';
  signal I_CTS_N : slbit := '0';
  signal I_SWI : slv16 := (others=>'0');
  signal I_BTN : slv5 := (others=>'0');
  signal I_BTNRST_N : slbit := '1';
  signal O_LED : slv16 := (others=>'0');
  signal O_RGBLED0 : slv3 := (others=>'0');
  signal O_RGBLED1 : slv3 := (others=>'0');
  signal O_ANO_N : slv8 := (others=>'0');
  signal O_SEG_N : slv8 := (others=>'0');

  signal R_PORTSEL_XON : slbit := '0';       -- if 1 use xon/xoff

  constant sbaddr_portsel: slv8 := slv(to_unsigned( 8,8));

  constant clock_period : Delay_length :=  10 ns;
  constant clock_offset : Delay_length := 200 ns;

begin
  
  CLKGEN : simclk
    generic map (
      PERIOD => clock_period,
      OFFSET => clock_offset)
    port map (
      CLK      => CLKOSC
    );
  
  CLKGEN_COM : sfs_gsim_core
    generic map (
      VCO_DIVIDE   => sys_conf_clkser_vcodivide,
      VCO_MULTIPLY => sys_conf_clkser_vcomultiply,
      OUT_DIVIDE   => sys_conf_clkser_outdivide)
    port map (
      CLKIN   => CLKOSC,
      CLKFX   => CLKCOM,
      LOCKED  => open
    );

  CLKCNT : simclkcnt port map (CLK => CLKCOM, CLK_CYCLE => CLKCOM_CYCLE);

  TBCORE : entity work.tbcore_rlink
    port map (
      CLK      => CLKCOM,
      RX_DATA  => TXDATA,
      RX_VAL   => TXENA,
      RX_HOLD  => TXBUSY,
      TX_DATA  => RXDATA,
      TX_ENA   => RXVAL
    );

  N4CORE : entity work.tb_nexys4d_core
    port map (
      I_SWI       => I_SWI,
      I_BTN       => I_BTN,
      I_BTNRST_N  => I_BTNRST_N
    );

  UUT : nexys4d_aif
    port map (
      I_CLK100    => CLKOSC,
      I_RXD       => I_RXD,
      O_TXD       => O_TXD,
      O_RTS_N     => O_RTS_N,
      I_CTS_N     => I_CTS_N,
      I_SWI       => I_SWI,
      I_BTN       => I_BTN,
      I_BTNRST_N  => I_BTNRST_N,
      O_LED       => O_LED,
      O_RGBLED0   => O_RGBLED0,
      O_RGBLED1   => O_RGBLED1,
      O_ANO_N     => O_ANO_N,
      O_SEG_N     => O_SEG_N
    );
  
  SERMSTR : entity work.serport_master_tb
    generic map (
      CDWIDTH => CLKDIV'length)
    port map (
      CLK     => CLKCOM,
      RESET   => RESET,
      CLKDIV  => CLKDIV,
      ENAXON  => R_PORTSEL_XON,
      ENAESC  => '0',
      RXDATA  => RXDATA,
      RXVAL   => RXVAL,
      RXERR   => RXERR,
      RXOK    => '1',
      TXDATA  => TXDATA,
      TXENA   => TXENA,
      TXBUSY  => TXBUSY,
      RXSD    => O_TXD,
      TXSD    => I_RXD,
      RXRTS_N => I_CTS_N,
      TXCTS_N => O_RTS_N
    );

  proc_moni: process
    variable oline : line;
  begin
    
    loop
      wait until rising_edge(CLKCOM);

      if RXERR = '1' then
        writetimestamp(oline, CLKCOM_CYCLE, " : seen RXERR=1");
        writeline(output, oline);
      end if;
      
    end loop;
    
  end process proc_moni;

  proc_simbus: process (SB_VAL)
  begin
    if SB_VAL'event and to_x01(SB_VAL)='1' then
      if SB_ADDR = sbaddr_portsel then
        R_PORTSEL_XON <= to_x01(SB_DATA(1));
      end if;
    end if;
  end process proc_simbus;

end sim;
