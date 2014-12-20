-- $Id: rlink_sp1c.vhd 610 2014-12-09 22:44:43Z mueller $
--
-- Copyright 2011-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rlink_sp1c - syn
-- Description:    rlink_core8 + serport_1clock combo
--
-- Dependencies:   rlink_core8
--                 serport/serport_1clock
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri ifa ofa
-- 2011-12-09   437 13.1    O40d xc3s1000-4   337  733   64  469 s  9.8   -   -
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-08-28   588   4.0    use rlink v4 iface, 4 bit STAT
-- 2011-12-09   437   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.rlinklib.all;
use work.serportlib.all;

entity rlink_sp1c is                    -- rlink_core8+serport_1clock combo
  generic (
    BTOWIDTH : positive :=  5;          -- rbus timeout counter width
    RTAWIDTH : positive :=  12;         -- retransmit buffer address width
    SYSID : slv32 := (others=>'0');     -- rlink system id
    IFAWIDTH : natural :=  5;           -- input fifo address width  (0=none)
    OFAWIDTH : natural :=  5;           -- output fifo address width (0=none)
    ENAPIN_RLMON : integer := -1;       -- SB_CNTL for rlmon  (-1=none)
    ENAPIN_RLBMON: integer := -1;       -- SB_CNTL for rlbmon (-1=none)
    ENAPIN_RBMON : integer := -1;       -- SB_CNTL for rbmon  (-1=none)
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15);          -- clk divider initial/reset setting
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    CE_INT : in slbit := '0';           -- rri ato time unit clock enable
    RESET  : in slbit;                  -- reset
    ENAXON : in slbit;                  -- enable xon/xoff handling
    ENAESC : in slbit;                  -- enable xon/xoff escaping
    RXSD : in slbit;                    -- receive serial data      (board view)
    TXSD : out slbit;                   -- transmit serial data     (board view)
    CTS_N : in slbit := '0';            -- clear to send   (act.low, board view)
    RTS_N : out slbit;                  -- request to send (act.low, board view)
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv4;                  -- rbus: status flags
    RL_MONI : out rl_moni_type;         -- rlink_core: monitor port
    SER_MONI : out serport_moni_type    -- serport: monitor port
  );
end entity rlink_sp1c;


architecture syn of rlink_sp1c is

  signal RLB_DI : slv8 := (others=>'0');
  signal RLB_ENA : slbit := '0';
  signal RLB_BUSY : slbit := '0';
  signal RLB_DO : slv8 := (others=>'0');
  signal RLB_VAL : slbit := '0';
  signal RLB_HOLD : slbit := '0';

begin
  
  CORE : rlink_core8
    generic map (
      BTOWIDTH     => BTOWIDTH,
      RTAWIDTH     => RTAWIDTH,
      SYSID        => SYSID,
      ENAPIN_RLMON => ENAPIN_RLMON,
      ENAPIN_RLBMON=> ENAPIN_RLBMON,
      ENAPIN_RBMON => ENAPIN_RBMON)
    port map (
      CLK        => CLK,
      CE_INT     => CE_INT,
      RESET      => RESET,
      RLB_DI     => RLB_DI,
      RLB_ENA    => RLB_ENA,
      RLB_BUSY   => RLB_BUSY,
      RLB_DO     => RLB_DO,
      RLB_VAL    => RLB_VAL,
      RLB_HOLD   => RLB_HOLD,
      RL_MONI    => RL_MONI,
      RB_MREQ    => RB_MREQ,
      RB_SRES    => RB_SRES,
      RB_LAM     => RB_LAM,
      RB_STAT    => RB_STAT
    );
  
  SERPORT : serport_1clock
    generic map (
      CDWIDTH   => CDWIDTH,
      CDINIT    => CDINIT,
      RXFAWIDTH => IFAWIDTH,
      TXFAWIDTH => OFAWIDTH)
    port map (
      CLK      => CLK,
      CE_MSEC  => CE_MSEC,
      RESET    => RESET,
      ENAXON   => ENAXON,
      ENAESC   => ENAESC,
      RXDATA   => RLB_DI,
      RXVAL    => RLB_ENA,
      RXHOLD   => RLB_BUSY,
      TXDATA   => RLB_DO,
      TXENA    => RLB_VAL,
      TXBUSY   => RLB_HOLD,
      MONI     => SER_MONI,
      RXSD     => RXSD,
      TXSD     => TXSD,
      RXRTS_N  => RTS_N,
      TXCTS_N  => CTS_N
    );
  
end syn;
