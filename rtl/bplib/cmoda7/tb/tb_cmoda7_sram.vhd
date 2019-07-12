-- $Id: tb_cmoda7_sram.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    tb_cmoda7_sram - sim
-- Description:    Test bench for cmoda7 (base+sram)
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--                 rlink/tbcore/tbcore_rlink
--                 xlib/sfs_gsim_core
--                 tb_cmoda7_core
--                 serport/tb/serport_master_tb
--                 cmoda7_sram_aif [UUT]
--                 simlib/simbididly
--                 bplib/issi/is61wv5128bll
--
-- To test:        generic, any cmoda7_sram_aif target
--
-- Target Devices: generic
-- Tool versions:  viv 2016.4-2018.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-11-03  1064   1.0.1  use sfs_gsim_core
-- 2017-06-04   906   1.0    Initial version (derived from tb_nexys4_cram)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.rlinklib.all;
use work.xlib.all;
use work.cmoda7lib.all;
use work.simlib.all;
use work.simbus.all;
use work.sys_conf.all;

entity tb_cmoda7_sram is
end tb_cmoda7_sram;

architecture sim of tb_cmoda7_sram is
  
  signal CLKOSC : slbit := '0';         -- board clock (12 Mhz)
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
  signal I_BTN : slv2 := (others=>'0');
  signal O_LED : slv2 := (others=>'0');
  signal O_RGBLED0_N : slv3 := (others=>'0');

  signal TB_MEM_CE_N  : slbit := '1';
  signal TB_MEM_WE_N  : slbit := '1';
  signal TB_MEM_OE_N  : slbit := '1';
  signal TB_MEM_ADDR  : slv19 := (others=>'Z');
  signal TB_MEM_DATA : slv8   := (others=>'0');

  signal MM_MEM_CE_N  : slbit := '1';
  signal MM_MEM_WE_N  : slbit := '1';
  signal MM_MEM_OE_N  : slbit := '1';
  signal MM_MEM_ADDR  : slv19 := (others=>'Z');
  signal MM_MEM_DATA  : slv8  := (others=>'0');

  signal R_PORTSEL_XON : slbit := '0';       -- if 1 use xon/xoff

  constant sbaddr_portsel: slv8 := slv(to_unsigned( 8,8));

  constant clock_period : Delay_length :=  83.333 ns;
  constant clock_offset : Delay_length := 2000 ns;
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

  C7CORE : entity work.tb_cmoda7_core
    port map (
      I_BTN       => I_BTN
    );

  UUT : cmoda7_sram_aif
    port map (
      I_CLK12     => CLKOSC,
      I_RXD       => I_RXD,
      O_TXD       => O_TXD,
      I_BTN       => I_BTN,
      O_LED       => O_LED,
      O_RGBLED0_N => O_RGBLED0_N,
      O_MEM_CE_N  => TB_MEM_CE_N,
      O_MEM_WE_N  => TB_MEM_WE_N,
      O_MEM_OE_N  => TB_MEM_OE_N,
      O_MEM_ADDR  => TB_MEM_ADDR,
      IO_MEM_DATA => TB_MEM_DATA
    );
  
  MM_MEM_CE_N  <= TB_MEM_CE_N  after pcb_delay;
  MM_MEM_WE_N  <= TB_MEM_WE_N  after pcb_delay;
  MM_MEM_OE_N  <= TB_MEM_OE_N  after pcb_delay;
  MM_MEM_ADDR  <= TB_MEM_ADDR  after pcb_delay;

  BUSDLY: simbididly
    generic map (
      DELAY  => pcb_delay,
      DWIDTH => 8)
    port map (
      A => TB_MEM_DATA,
      B => MM_MEM_DATA);

  MEM : entity work.is61wv5128bll
    port map (
      CE_N  => MM_MEM_CE_N,
      OE_N  => MM_MEM_OE_N,
      WE_N  => MM_MEM_WE_N,
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
      RXRTS_N => open,
      TXCTS_N => '0'
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

  --
  -- Notes on portsel and XON control:
  --   - most cmoda7 designs will use hardwired XON=1
  --   - but some (especially basis tests) might not use flow control
  --   - that's why XON flow control must be optional and configurable !
  --
  proc_simbus: process (SB_VAL)
  begin
    if SB_VAL'event and to_x01(SB_VAL)='1' then
      if SB_ADDR = sbaddr_portsel then
        R_PORTSEL_XON <= to_x01(SB_DATA(1));
      end if;
    end if;
  end process proc_simbus;

end sim;
