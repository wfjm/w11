-- $Id: serport_2clock2.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    serport_2clock2 - syn
-- Description:    serial port: serial port module, 2 clock domain (v2)
--
-- Dependencies:   cdclib/cdc_pulse
--                 cdclib/cdc_signal_s1
--                 cdclib/cdc_vector_s0
--                 serport_uart_rxtx_ab
--                 serport_xonrx
--                 serport_xontx
--                 memlib/fifo_2c_dram2
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  viv 2015.4; ghdl 0.33
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-04-08   759   1.1    all cdc's via cdc_(pulse|signal|vector)
-- 2016-03-28   755   1.0.1  check assertions only at raising clock
-- 2016-03-25   752   1.0    Initial version (derived from serport_2clock, is
--                             exactly same logic, re-written to allow proper
--                             usage of vivado constraints)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.serportlib.all;
use work.cdclib.all;
use work.memlib.all;

entity serport_2clock2 is               -- serial port module, 2 clock dom. (v2)
  generic (
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15;           -- clk divider initial/reset setting
    RXFAWIDTH : natural :=  5;          -- rx fifo address width
    TXFAWIDTH : natural :=  5);         -- tx fifo address width
  port (
    CLKU : in slbit;                    -- U|clock (backend:user)
    RESET : in slbit;                   -- U|reset
    CLKS : in slbit;                    -- S|clock (frontend:serial)
    CES_MSEC : in slbit;                -- S|1 msec clock enable
    ENAXON : in slbit;                  -- U|enable xon/xoff handling
    ENAESC : in slbit;                  -- U|enable xon/xoff escaping
    RXDATA : out slv8;                  -- U|receiver data out
    RXVAL : out slbit;                  -- U|receiver data valid
    RXHOLD : in slbit;                  -- U|receiver data hold
    TXDATA : in slv8;                   -- U|transmit data in
    TXENA : in slbit;                   -- U|transmit data enable
    TXBUSY : out slbit;                 -- U|transmit busy
    MONI : out serport_moni_type;       -- U|serport monitor port
    RXSD : in slbit;                    -- S|receive serial data (uart view)
    TXSD : out slbit;                   -- S|transmit serial data (uart view)
    RXRTS_N : out slbit;                -- S|receive rts (uart view, act.low)
    TXCTS_N : in slbit                  -- S|transmit cts (uart view, act.low)
  );
end serport_2clock2;


architecture syn of serport_2clock2 is

  subtype cd_range is integer range CDWIDTH-1 downto  0;   -- clk div value regs

  signal RXACT_U  :  slbit           := '0'; -- rxact in CLKU
  signal TXACT_U  :  slbit           := '0'; -- txact in CLKU
  signal ABACT_U  :  slbit           := '0'; -- abact in CLKU
  signal RXOK_U   :  slbit           := '0'; -- rxok  in CLKU
  signal TXOK_U   :  slbit           := '0'; -- txok  in CLKU

  signal ABCLKDIV_U :  slv(cd_range) := (others=>'0'); -- abclkdiv
  signal ABCLKDIV_F_U: slv3          := (others=>'0'); -- abclkdiv_f
  
  signal ENAXON_S : slbit            := '0'; -- enaxon in CLKS
  signal ENAESC_S : slbit            := '0'; -- enaesc in CLKS
  
  signal R_RXOK : slbit := '1';

  signal RESET_INT : slbit := '0';
  signal RESET_CLKS : slbit := '0';

  signal UART_RXDATA : slv8 := (others=>'0');
  signal UART_RXVAL : slbit := '0';
  signal UART_TXDATA : slv8 := (others=>'0');
  signal UART_TXENA : slbit := '0';
  signal UART_TXBUSY : slbit := '0';

  signal XONTX_TXENA : slbit := '0';
  signal XONTX_TXBUSY : slbit := '0';

  signal RXFIFO_DI : slv8 := (others=>'0');
  signal RXFIFO_ENA : slbit := '0';
  signal RXFIFO_BUSY : slbit := '0';
  signal RXFIFO_SIZEW : slv(RXFAWIDTH-1 downto 0) := (others=>'0');
  signal TXFIFO_DO : slv8 := (others=>'0');
  signal TXFIFO_VAL : slbit := '0';
  signal TXFIFO_HOLD : slbit := '0';
  
  signal RXERR  : slbit := '0';
  signal RXOVR  : slbit := '0';
  signal RXACT  : slbit := '0';
  signal ABACT  : slbit := '0';
  signal ABDONE : slbit := '0';
  signal ABCLKDIV   : slv(cd_range) := (others=>'0');
  signal ABCLKDIV_F : slv3 := (others=>'0');

  signal TXOK : slbit := '0';
  signal RXOK : slbit := '0';

  signal RXERR_U  : slbit := '0';
  signal RXOVR_U  : slbit := '0';
  signal ABDONE_U : slbit := '0';

begin

  assert CDWIDTH<=16
    report "assert(CDWIDTH<=16): max width of UART clock divider"
    severity failure;

  -- sync CLKU->CLKS
  CDC_RESET : cdc_pulse                 -- provide CLKS side RESET
    generic map (
    POUT_SINGLE => false,
    BUSY_WACK   => false)
  port map (
    CLKM     => CLKU,
    RESET    => '0',
    CLKS     => CLKS,
    PIN      => RESET,
    BUSY     => open,
    POUT     => RESET_CLKS
  );

  CDC_ENAXON: cdc_signal_s1
    port map (CLKO => CLKS, DI => ENAXON, DO => ENAXON_S);
  CDC_ENAESC: cdc_signal_s1
    port map (CLKO => CLKS, DI => ENAESC, DO => ENAESC_S);

  UART : serport_uart_rxtx_ab           -- uart, rx+tx+autobauder combo
  generic map (
    CDWIDTH => CDWIDTH,
    CDINIT  => CDINIT)
  port map (
    CLK        => CLKS,
    CE_MSEC    => CES_MSEC,
    RESET      => RESET_CLKS,
    RXSD       => RXSD,
    RXDATA     => UART_RXDATA,
    RXVAL      => UART_RXVAL,
    RXERR      => RXERR,
    RXACT      => RXACT,
    TXSD       => TXSD,
    TXDATA     => UART_TXDATA,
    TXENA      => UART_TXENA,
    TXBUSY     => UART_TXBUSY,
    ABACT      => ABACT,
    ABDONE     => ABDONE,
    ABCLKDIV   => ABCLKDIV,
    ABCLKDIV_F => ABCLKDIV_F
  );

  RESET_INT <= RESET_CLKS or ABACT;
  
  XONRX : serport_xonrx                 --  xon/xoff logic rx path
  port map (
    CLK         => CLKS,
    RESET       => RESET_INT,
    ENAXON      => ENAXON_S,
    ENAESC      => ENAESC_S,
    UART_RXDATA => UART_RXDATA,
    UART_RXVAL  => UART_RXVAL,
    RXDATA      => RXFIFO_DI,
    RXVAL       => RXFIFO_ENA,
    RXHOLD      => RXFIFO_BUSY,
    RXOVR       => RXOVR,
    TXOK        => TXOK
  );

  XONTX : serport_xontx                 --  xon/xoff logic tx path
  port map (
    CLK         => CLKS,
    RESET       => RESET_INT,
    ENAXON      => ENAXON_S,
    ENAESC      => ENAESC_S,
    UART_TXDATA => UART_TXDATA,
    UART_TXENA  => XONTX_TXENA,
    UART_TXBUSY => XONTX_TXBUSY,
    TXDATA      => TXFIFO_DO,
    TXENA       => TXFIFO_VAL,
    TXBUSY      => TXFIFO_HOLD,
    RXOK        => RXOK,
    TXOK        => TXOK
  );
  
  RXFIFO : fifo_2c_dram2                -- input fifo, 2 clock, dram based
  generic map (
    AWIDTH => RXFAWIDTH,
    DWIDTH => 8)
  port map (
    CLKW   => CLKS,
    CLKR   => CLKU,
    RESETW => ABACT,                    -- clear fifo on abact
    RESETR => RESET,
    DI     => RXFIFO_DI,
    ENA    => RXFIFO_ENA,
    BUSY   => RXFIFO_BUSY,
    DO     => RXDATA,
    VAL    => RXVAL,
    HOLD   => RXHOLD,
    SIZEW  => RXFIFO_SIZEW,
    SIZER  => open
  );

  TXFIFO : fifo_2c_dram2                -- output fifo, 2 clock, dram based
  generic map (
    AWIDTH => TXFAWIDTH,
    DWIDTH => 8)
  port map (
    CLKW   => CLKU,
    CLKR   => CLKS,
    RESETW => RESET,
    RESETR => ABACT,                    -- clear fifo on abact
    DI     => TXDATA,
    ENA    => TXENA,
    BUSY   => TXBUSY,
    DO     => TXFIFO_DO,
    VAL    => TXFIFO_VAL,
    HOLD   => TXFIFO_HOLD,
    SIZEW  => open,
    SIZER  => open
  );

  -- receive back pressure
  --    on if fifo more than 3/4 full (less than 1/4 free)
  --   off if fifo less than 1/2 full (more than 1/2 free)
  proc_rxok: process (CLKS)
    constant rxsize_rxok_off : slv2 := "01";
    constant rxsize_rxok_on  : slv2 := "10";
    variable rxsize_msb : slv2 := "00";
  begin
    if rising_edge(CLKS) then
      if RESET_INT = '1' then
        R_RXOK <= '1';
      else
        rxsize_msb := RXFIFO_SIZEW(RXFAWIDTH-1 downto RXFAWIDTH-2);
        if unsigned(rxsize_msb) <  unsigned(rxsize_rxok_off) then
          R_RXOK <= '0';
        elsif unsigned(RXSIZE_MSB) >=  unsigned(rxsize_rxok_on) then
          R_RXOK <= '1';
        end if;
      end if;
    end if;
  end process proc_rxok;

  RXOK    <= R_RXOK;
  RXRTS_N <= not R_RXOK;

  proc_cts: process (TXCTS_N, XONTX_TXENA, UART_TXBUSY)
  begin
    if TXCTS_N = '0' then               -- transmit cts asserted
      UART_TXENA   <= XONTX_TXENA;
      XONTX_TXBUSY <= UART_TXBUSY;
    else                                -- transmit cts not asserted
      UART_TXENA   <= '0';
      XONTX_TXBUSY <= '1';
    end if;
  end process proc_cts;

  -- sync CLKS->CLKU
  CDC_RXACT : cdc_signal_s1
    port map (CLKO => CLKU, DI => RXACT,       DO => RXACT_U);
  CDC_TXACT : cdc_signal_s1
    port map (CLKO => CLKU, DI => UART_TXBUSY, DO => TXACT_U);
  CDC_ABACT : cdc_signal_s1
    port map (CLKO => CLKU, DI => ABACT,       DO => ABACT_U);
  CDC_RXOK  : cdc_signal_s1
    port map (CLKO => CLKU, DI => RXOK,        DO => RXOK_U);
  CDC_TXOK  : cdc_signal_s1
    port map (CLKO => CLKU, DI => TXOK,        DO => TXOK_U);

  CDC_CDIV : cdc_vector_s0
    generic map (
      DWIDTH => CDWIDTH)
    port map (
      CLKO => CLKU,
      DI   => ABCLKDIV,
      DO   => ABCLKDIV_U
    );

  CDC_CDIVF  : cdc_vector_s0
    generic map (
      DWIDTH => 3)
    port map (
      CLKO => CLKU,
      DI   => ABCLKDIV_F,
      DO   => ABCLKDIV_F_U
    );
  
  CDC_RXERR : cdc_pulse
  generic map (
    POUT_SINGLE => true,
    BUSY_WACK   => false)
  port map (
    CLKM     => CLKS,
    RESET    => '0',
    CLKS     => CLKU,
    PIN      => RXERR,
    BUSY     => open,
    POUT     => RXERR_U
  );

  CDC_RXOVR : cdc_pulse
  generic map (
    POUT_SINGLE => true,
    BUSY_WACK   => false)
  port map (
    CLKM     => CLKS,
    RESET    => '0',
    CLKS     => CLKU,
    PIN      => RXOVR,
    BUSY     => open,
    POUT     => RXOVR_U
  );

  CDC_ABDONE : cdc_pulse
  generic map (
    POUT_SINGLE => true,
    BUSY_WACK   => false)
  port map (
    CLKM     => CLKS,
    RESET    => '0',
    CLKS     => CLKU,
    PIN      => ABDONE,
    BUSY     => open,
    POUT     => ABDONE_U
  );
  
  MONI.rxerr  <= RXERR_U;
  MONI.rxovr  <= RXOVR_U;
  MONI.rxact  <= RXACT_U;
  MONI.txact  <= TXACT_U;
  MONI.abact  <= ABACT_U;
  MONI.abdone <= ABDONE_U;
  MONI.rxok   <= RXOK_U;
  MONI.txok   <= TXOK_U;
  
  proc_abclkdiv: process (ABCLKDIV_U, ABCLKDIV_F_U)
  begin
    MONI.abclkdiv <= (others=>'0');
    MONI.abclkdiv(ABCLKDIV_U'range) <= ABCLKDIV_U;
    MONI.abclkdiv_f <= ABCLKDIV_F_U;
  end process proc_abclkdiv; 

-- synthesis translate_off

  proc_check: process (CLKS)
  begin
    if rising_edge(CLKS) then
      assert RXOVR = '0'
        report "serport_2clock2-W: RXOVR = " & slbit'image(RXOVR) &
                 "; data loss in receive fifo"
        severity warning;
      assert RXERR = '0'
        report "serport_2clock2-W: RXERR = " & slbit'image(RXERR) &
                 "; spurious receive error"
        severity warning;
    end if;
  end process proc_check;

-- synthesis translate_on
  
end syn;
