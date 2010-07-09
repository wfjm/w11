-- $Id: s3_rs232_iob_int_ext.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    s3_rs232_iob_int_ext - syn
-- Description:    iob's for internal + external rs232, with select
--
-- Dependencies:   s3_rs232_iob_int
--                 s3_rs232_iob_ext
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 11.4; ghdl 0.26
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-04-17   278   1.0    Initial version
------------------------------------------------------------------------------
--    

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.s3boardlib.all;

-- ----------------------------------------------------------------------------

entity s3_rs232_iob_int_ext is          -- iob's for int+ext rs232, with select
  port (
    CLK : in slbit;                     -- clock
    SEL : in slbit;                     -- select, '0' for port 0
    RXD : out slbit;                    -- receive data (board view)
    TXD : in slbit;                     -- transmit data (board view)
    CTS_N : out slbit;                  -- clear to send   (act. low)
    RTS_N : in slbit;                   -- request to send (act. low)
    I_RXD0 : in slbit;                  -- pad-i: p0: receive data (board view)
    O_TXD0 : out slbit;                 -- pad-o: p0: transmit data (board view)
    I_RXD1 : in slbit;                  -- pad-i: p1: receive data (board view)
    O_TXD1 : out slbit;                 -- pad-o: p1: transmit data (board view)
    I_CTS1_N : in slbit;                -- pad-i: p1: clear to send   (act. low)
    O_RTS1_N : out slbit                -- pad-o: p1: request to send (act. low)
  );
end s3_rs232_iob_int_ext;

architecture syn of s3_rs232_iob_int_ext is
  signal RXD0 : slbit := '0';
  signal TXD0 : slbit := '0';
  signal RXD1 : slbit := '0';
  signal TXD1 : slbit := '0';
  signal CTS1_N : slbit := '0';
  signal RTS1_N : slbit := '0';
begin

  P0 : s3_rs232_iob_int
    port map (
      CLK   => CLK,
      RXD   => RXD0,
      TXD   => TXD0,
      I_RXD => I_RXD0,
      O_TXD => O_TXD0
    );

  P1 : s3_rs232_iob_ext
    port map (
      CLK     => CLK,
      RXD     => RXD1,
      TXD     => TXD1,
      CTS_N   => CTS1_N,
      RTS_N   => RTS1_N,
      I_RXD   => I_RXD1,
      O_TXD   => O_TXD1,
      I_CTS_N => I_CTS1_N,
      O_RTS_N => O_RTS1_N
    );

  proc_port_mux: process (SEL, RXD0, TXD, RXD1, CTS1_N, RTS_N)
  begin
    if SEL = '0' then                -- use main board rs232, no flow cntl
      RXD      <= RXD0;                   -- get port 0 inputs
      CTS_N    <= '0';
      TXD0     <= TXD;                    -- set port 0 output 
      TXD1     <= '1';                    -- port 1 outputs to idle state
      RTS1_N   <= '0';
    else                                -- otherwise use pmod1 rs232
      RXD      <= RXD1;                   -- get port 1 inputs
      CTS_N    <= CTS1_N;
      TXD1     <= TXD;                    -- set port 1 outputs
      RTS1_N   <= RTS_N;
      TXD0     <= '1';                    -- port 0 output to idle state
    end if;
  end process proc_port_mux;

end syn;
