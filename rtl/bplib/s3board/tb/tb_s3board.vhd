-- $Id: tb_s3board.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    tb_s3board - sim
-- Description:    Test bench for s3board (base)
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--                 rlink/tbcore/tbcore_rlink
--                 tb_s3board_core
--                 s3board_aif [UUT]
--                 serport/tb/serport_master_tb
--
-- To test:        generic, any s3board_aif target
--
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-09-02   805   3.2.3  tbcore_rlink without CLK_STOP now
-- 2016-02-13   730   3.2.2  direct instantiation of tbcore_rlink
-- 2016-01-03   724   3.2.1  use serport/tb/serport_master_tb
-- 2015-04-12   666   3.2    use serport_master instead of serport_uart_rxtx
-- 2011-12-23   444   3.1    new system clock scheme, new tbcore_rlink iface
-- 2011-11-21   432   3.0.1  now numeric_std clean
-- 2010-12-30   351   3.0    use rlink/tb now
-- 2010-11-06   336   2.0.3  rename input pin CLK -> I_CLK50
-- 2010-05-28   295   2.0.2  use serport_uart_rxtx
-- 2010-05-01   286   2.0.1  use rritb_core as component again (rriv1 is gone..)
-- 2010-04-25   283   2.0    factor out basic device handling to tb_s3board_core
--                           and_conf/_stim file processing to rri/tb/rritb_core
-- 2010-04-24   281   1.3.2  use serport_uart_[tr]x directly again
-- 2007-12-16   101   1.3.1  use _N for active low, add sram memory model
-- 2007-12-09   100   1.3    add sram memory signals
-- 2007-11-23    97   1.2    use serport_uart_[tr]x_tb to allow that UUT is a
--                           [sft]sim model compiled with keep hierarchy
-- 2007-10-26    92   1.1.1  use DONE timestamp at end of execution
-- 2007-10-19    90   1.1    avoid ieee.std_logic_unsigned, use cast to unsigned
--                           use CLKDIV="00 --> sim with max. serport speed
-- 2007-09-23    85   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.rlinklib.all;
use work.s3boardlib.all;
use work.simlib.all;
use work.simbus.all;

entity tb_s3board is
end tb_s3board;

architecture sim of tb_s3board is
  
  signal CLK : slbit := '0';

  signal CLK_CYCLE : integer := 0;

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
  signal I_SWI : slv8 := (others=>'0');
  signal I_BTN : slv4 := (others=>'0');
  signal O_LED : slv8 := (others=>'0');
  signal O_ANO_N : slv4 := (others=>'0');
  signal O_SEG_N : slv8 := (others=>'0');
  signal O_MEM_CE_N : slv2 := (others=>'1');
  signal O_MEM_BE_N : slv4 := (others=>'1');
  signal O_MEM_WE_N : slbit := '1';
  signal O_MEM_OE_N : slbit := '1';
  signal O_MEM_ADDR  : slv18 := (others=>'Z');
  signal IO_MEM_DATA : slv32 := (others=>'0');

  signal R_PORTSEL_XON : slbit := '0';       -- if 1 use xon/xoff

  constant sbaddr_portsel: slv8 := slv(to_unsigned( 8,8));

  constant clock_period : Delay_length :=  20 ns;
  constant clock_offset : Delay_length := 200 ns;

begin
  
  CLKGEN : simclk
    generic map (
      PERIOD => clock_period,
      OFFSET => clock_offset)
    port map (
      CLK      => CLK
    );
  
  CLKCNT : simclkcnt port map (CLK => CLK, CLK_CYCLE => CLK_CYCLE);

  TBCORE : entity work.tbcore_rlink
    port map (
      CLK      => CLK,
      RX_DATA  => TXDATA,
      RX_VAL   => TXENA,
      RX_HOLD  => TXBUSY,
      TX_DATA  => RXDATA,
      TX_ENA   => RXVAL
    );

  S3CORE : entity work.tb_s3board_core
    port map (
      I_SWI       => I_SWI,
      I_BTN       => I_BTN,
      O_MEM_CE_N  => O_MEM_CE_N,
      O_MEM_BE_N  => O_MEM_BE_N,
      O_MEM_WE_N  => O_MEM_WE_N,
      O_MEM_OE_N  => O_MEM_OE_N,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );

  UUT : s3board_aif
    port map (
      I_CLK50     => CLK,
      I_RXD       => I_RXD,
      O_TXD       => O_TXD,
      I_SWI       => I_SWI,
      I_BTN       => I_BTN,
      O_LED       => O_LED,
      O_ANO_N     => O_ANO_N,
      O_SEG_N     => O_SEG_N,
      O_MEM_CE_N  => O_MEM_CE_N,
      O_MEM_BE_N  => O_MEM_BE_N,
      O_MEM_WE_N  => O_MEM_WE_N,
      O_MEM_OE_N  => O_MEM_OE_N,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );

  SERMSTR : entity work.serport_master_tb
    generic map (
      CDWIDTH => CLKDIV'length)
    port map (
      CLK     => CLK,
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
      wait until rising_edge(CLK);

      if RXERR = '1' then
        writetimestamp(oline, CLK_CYCLE, " : seen RXERR=1");
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
