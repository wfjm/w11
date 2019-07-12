-- $Id: tb_nexys4_cram.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    tb_nexys4_cram - sim
-- Description:    Test bench for nexys4 (base+cram)
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--                 rlink/tbcore/tbcore_rlink
--                 xlib/sfs_gsim_core
--                 tb_nexys4_core
--                 serport/tb/serport_master_tb
--                 nexys4_cram_aif [UUT]
--                 simlib/simbididly
--                 bplib/micron/mt45w8mw16b
--
-- To test:        generic, any nexys4_cram_aif target
--
-- Target Devices: generic
-- Tool versions:  ise 14.5-14.7; viv 2014.4-2018.2; ghdl 0.29-0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-11-03  1064   1.3.2  use sfs_gsim_core
-- 2016-09-02   805   1.3.1  tbcore_rlink without CLK_STOP now
-- 2016-07-20   791   1.3    use simbididly
-- 2016-02-20   734   1.2.3  use s7_cmt_sfs_tb to avoid xsim conflict
-- 2016-02-13   730   1.2.2  direct instantiation of tbcore_rlink
-- 2016-01-03   724   1.2.1  use serport/tb/serport_master_tb
-- 2015-04-12   666   1.2    use serport_master instead of serport_uart_rxtx
-- 2015-02-01   641   1.1    separate I_BTNRST_N
-- 2013-09-28   535   1.0.1  use proper clock manager
-- 2013-09-21   534   1.0    Initial version (derived from tb_nexys3)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.rlinklib.all;
use work.xlib.all;
use work.nexys4lib.all;
use work.simlib.all;
use work.simbus.all;
use work.sys_conf.all;

entity tb_nexys4_cram is
end tb_nexys4_cram;

architecture sim of tb_nexys4_cram is
  
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

  signal TB_MEM_CE_N  : slbit := '1';
  signal TB_MEM_BE_N  : slv2 := (others=>'1');
  signal TB_MEM_WE_N  : slbit := '1';
  signal TB_MEM_OE_N  : slbit := '1';
  signal TB_MEM_ADV_N : slbit := '1';
  signal TB_MEM_CLK   : slbit := '0';
  signal TB_MEM_CRE   : slbit := '0';
  signal TB_MEM_WAIT  : slbit := '0';
  signal TB_MEM_ADDR  : slv23 := (others=>'Z');
  signal TB_MEM_DATA : slv16 := (others=>'0');

  signal MM_MEM_CE_N  : slbit := '1';
  signal MM_MEM_BE_N  : slv2 := (others=>'1');
  signal MM_MEM_WE_N  : slbit := '1';
  signal MM_MEM_OE_N  : slbit := '1';
  signal MM_MEM_ADV_N : slbit := '1';
  signal MM_MEM_CLK   : slbit := '0';
  signal MM_MEM_CRE   : slbit := '0';
  signal MM_MEM_WAIT  : slbit := '0';
  signal MM_MEM_ADDR  : slv23 := (others=>'Z');
  signal MM_MEM_DATA  : slv16 := (others=>'0');

  signal R_PORTSEL_XON : slbit := '0';       -- if 1 use xon/xoff

  constant sbaddr_portsel: slv8 := slv(to_unsigned( 8,8));

  constant clock_period : Delay_length :=  10 ns;
  constant clock_offset : Delay_length := 200 ns;
  constant pcb_delay : Delay_length := 1 ns;

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

  N4CORE : entity work.tb_nexys4_core
    port map (
      I_SWI       => I_SWI,
      I_BTN       => I_BTN,
      I_BTNRST_N  => I_BTNRST_N
    );

  UUT : nexys4_cram_aif
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
      O_SEG_N     => O_SEG_N,
      O_MEM_CE_N  => TB_MEM_CE_N,
      O_MEM_BE_N  => TB_MEM_BE_N,
      O_MEM_WE_N  => TB_MEM_WE_N,
      O_MEM_OE_N  => TB_MEM_OE_N,
      O_MEM_ADV_N => TB_MEM_ADV_N,
      O_MEM_CLK   => TB_MEM_CLK,
      O_MEM_CRE   => TB_MEM_CRE,
      I_MEM_WAIT  => TB_MEM_WAIT,
      O_MEM_ADDR  => TB_MEM_ADDR,
      IO_MEM_DATA => TB_MEM_DATA
    );
  
  MM_MEM_CE_N  <= TB_MEM_CE_N  after pcb_delay;
  MM_MEM_BE_N  <= TB_MEM_BE_N  after pcb_delay;
  MM_MEM_WE_N  <= TB_MEM_WE_N  after pcb_delay;
  MM_MEM_OE_N  <= TB_MEM_OE_N  after pcb_delay;
  MM_MEM_ADV_N <= TB_MEM_ADV_N after pcb_delay;
  MM_MEM_CLK   <= TB_MEM_CLK   after pcb_delay;
  MM_MEM_CRE   <= TB_MEM_CRE   after pcb_delay;
  MM_MEM_ADDR  <= TB_MEM_ADDR  after pcb_delay;
  TB_MEM_WAIT  <= MM_MEM_WAIT  after pcb_delay;

  BUSDLY: simbididly
    generic map (
      DELAY  => pcb_delay,
      DWIDTH => 16)
    port map (
      A => TB_MEM_DATA,
      B => MM_MEM_DATA);

  MEM : entity work.mt45w8mw16b
    port map (
      CLK   => MM_MEM_CLK,
      CE_N  => MM_MEM_CE_N,
      OE_N  => MM_MEM_OE_N,
      WE_N  => MM_MEM_WE_N,
      UB_N  => MM_MEM_BE_N(1),
      LB_N  => MM_MEM_BE_N(0),
      ADV_N => MM_MEM_ADV_N,
      CRE   => MM_MEM_CRE,
      MWAIT => MM_MEM_WAIT,
      ADDR  => MM_MEM_ADDR,
      DATA  => MM_MEM_DATA
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

end sim;
