-- $Id: tbd_rri_serport.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2007-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
-- 
------------------------------------------------------------------------------
-- Module Name:    tbd_rri_serport - syn
-- Description:    Wrapper for rri_core plus rri_serport with an interface
--                 compatible to the rri_core only module.
--                 NOTE: this implementation is a hack, should be redone
--                 using configurations.
--
-- Dependencies:   tbu_rri_serport [UUT]
--                 serport_uart_tx
--                 serport_uart_rx
--                 byte2cdata
--                 cdata2byte
--
-- To test:        rri_serport
--
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-06-06   301   2.3    use NCOMM=4 (new eop,nak commas)
-- 2010-05-02   287   2.2.2  ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT signal from interfaces
-- 2010-04-24   281   2.2.1  use serport_uart_[tr]x directly again
-- 2010-04-03   274   2.2    add CE_USEC
-- 2009-03-14   197   2.1    remove records in interface to allow _ssim usage
-- 2008-08-24   162   2.0    with new rb_mreq/rb_sres interface
-- 2007-11-25    98   1.1    added RP_IINT support; use entity rather arch
--                           name to switch core/serport;
--                           use serport_uart_[tr]x_tb to allow that UUT is a
--                           [sft]sim model compiled with keep hierarchy
-- 2007-07-02    63   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
-- synthesis translate_off
use ieee.std_logic_textio.all;
use std.textio.all;
-- synthesis translate_on

use work.slvtypes.all;
use work.rrilib.all;
use work.comlib.all;
use work.serport.all;

entity tbd_rri_serport is               -- rri_core+rri_serport tb design
                                        -- implements tbd_rri_gen
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit;                  -- rri ito time unit clock enable
    CE_USEC : in slbit;                 -- 1 usec clock enable
    RESET  : in slbit;                  -- reset
    CP_DI : in slv9;                    -- comm port: data in
    CP_ENA : in slbit;                  -- comm port: data enable
    CP_BUSY : out slbit;                -- comm port: data busy
    CP_DO : out slv9;                   -- comm port: data out
    CP_VAL : out slbit;                 -- comm port: data valid
    CP_HOLD : in slbit;                 -- comm port: data hold
    RB_MREQ_req : out slbit;            -- rbus: request - req
    RB_MREQ_we : out slbit;             -- rbus: request - we
    RB_MREQ_initt : out slbit;          -- rbus: request - init; avoid name coll
    RB_MREQ_addr : out slv8;            -- rbus: request - addr
    RB_MREQ_din : out slv16;            -- rbus: request - din
    RB_SRES_ack : in slbit;             -- rbus: response - ack
    RB_SRES_busy : in slbit;            -- rbus: response - busy
    RB_SRES_err : in slbit;             -- rbus: response - err
    RB_SRES_dout : in slv16;            -- rbus: response - dout
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3;                  -- rbus: status flags
    TXRXACT : out slbit                 -- txrx active flag
  );
end entity tbd_rri_serport;


architecture syn of tbd_rri_serport is

  signal RRI_RXSD : slbit := '0';
  signal RRI_TXSD : slbit := '0';
  signal RXDATA : slv8 := (others=>'0');
  signal RXVAL : slbit := '0';
  signal RXACT : slbit := '0';
  signal TXDATA : slv8 := (others=>'0');
  signal TXENA : slbit := '0';
  signal TXBUSY : slbit := '0';
  signal CLKDIV : slv13 := conv_std_logic_vector(1,13);
                           -- NOTE: change also CDINIT in tbu_rri_serport !!
  
component tbu_rri_serport is            -- rri core+serport combo
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit;                  -- rri ito time unit clock enable
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    RESET  : in slbit;                  -- reset
    RXSD : in slbit;                    -- receive serial data (uart view)
    TXSD : out slbit;                   -- transmit serial data (uart view)
    RB_MREQ_req : out slbit;            -- rbus: request - req
    RB_MREQ_we : out slbit;             -- rbus: request - we
    RB_MREQ_initt : out slbit;          -- rbus: request - init; avoid name coll
    RB_MREQ_addr : out slv8;            -- rbus: request - addr
    RB_MREQ_din : out slv16;            -- rbus: request - din
    RB_SRES_ack : in slbit;             -- rbus: response - ack
    RB_SRES_busy : in slbit;            -- rbus: response - busy
    RB_SRES_err : in slbit;             -- rbus: response - err
    RB_SRES_dout : in slv16;            -- rbus: response - dout
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3                   -- rbus: status flags
  );
end component;

  constant CPREF : slv4 := "1000";
  constant NCOMM : positive := 4;

begin

  UUT : tbu_rri_serport
    port map (
      CLK          => CLK,
      CE_INT       => CE_INT,
      CE_USEC      => CE_USEC,
      CE_MSEC      => '1',
      RESET        => RESET,
      RXSD         => RRI_RXSD,
      TXSD         => RRI_TXSD,
      RB_MREQ_req  => RB_MREQ_req,
      RB_MREQ_we   => RB_MREQ_we,
      RB_MREQ_initt=> RB_MREQ_initt,
      RB_MREQ_addr => RB_MREQ_addr,
      RB_MREQ_din  => RB_MREQ_din,
      RB_SRES_ack  => RB_SRES_ack,
      RB_SRES_busy => RB_SRES_busy,
      RB_SRES_err  => RB_SRES_err,
      RB_SRES_dout => RB_SRES_dout,
      RB_LAM       => RB_LAM,
      RB_STAT      => RB_STAT
    );

  UARTRX : serport_uart_rx
    generic map (
      CDWIDTH => 13)
    port map (
      CLK    => CLK,
      RESET  => RESET,
      CLKDIV => CLKDIV,
      RXSD   => RRI_TXSD,
      RXDATA => RXDATA,
      RXVAL  => RXVAL,
      RXERR  => open,
      RXACT  => RXACT
    );

  UARTTX : serport_uart_tx
    generic map (
      CDWIDTH => 13)
    port map (
      CLK    => CLK,
      RESET  => RESET,
      CLKDIV => CLKDIV,
      TXSD   => RRI_RXSD,
      TXDATA => TXDATA,
      TXENA  => TXENA,
      TXBUSY => TXBUSY
    );

  TXRXACT <= RXACT or TXBUSY;
  
  B2CD : byte2cdata                     -- byte stream -> 9bit comma,data
    generic map (
      CPREF => CPREF,
      NCOMM => NCOMM)
    port map (
      CLK   => CLK,
      RESET => RESET,
      DI    => RXDATA,
      ENA   => RXVAL,
      BUSY  => open,
      DO    => CP_DO,
      VAL   => CP_VAL,
      HOLD  => CP_HOLD
    );

  CD2B : cdata2byte                     -- 9bit comma,data -> byte stream
    generic map (
      CPREF => CPREF,
      NCOMM => NCOMM)
    port map (
      CLK   => CLK,
      RESET => RESET,
      DI    => CP_DI,
      ENA   => CP_ENA,
      BUSY  => CP_BUSY,
      DO    => TXDATA,
      VAL   => TXENA,
      HOLD  => TXBUSY
    );

-- synthesis translate_off
  proc_moni: process
    variable oline : line;
    constant c2out_time : time := 10 ns;  -- FIXME - this isn't modular !!!

  begin

    loop 
      wait until CLK'event and CLK='1';
      wait for c2out_time;

      if TXENA='1' and TXBUSY='0' then
        write(oline, now, right, 12);
        write(oline, string'("       "));
        write(oline, string'(":   tx  "));
        write(oline, string'("  "));
        write(oline, TXDATA, right, 9);
        writeline(output, oline);
      end if;
      
      if RXVAL = '1' then
        write(oline, now, right, 12);
        write(oline, string'("       "));
        write(oline, string'(":   rx  "));
        write(oline, string'("  "));
        write(oline, RXDATA, right, 9);
        writeline(output, oline);
      end if;
      
    end loop;

  end process proc_moni;
-- synthesis translate_on

  
end syn;
