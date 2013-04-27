-- $Id:  $
--
-- Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rlink_sp1c_fx2 - syn
-- Description:    rlink_core8 + serport_1clock + fx2 combo
--
-- Dependencies:   rlinklib/rlink_core8
--                 serport/serport_1clock
--                 rlinklib/rlink_rlbmux
--                 fx2lib/fx2_2fifoctl_ic
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.1; ghdl 0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri ifa ofa
-- 2013-04-20   509 13.3    O76d xc3s1200e-4  441  903  128  637 s  8.7   -   -
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-04-20   509   1.0    Initial version (derived from rlink_sp1c)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.rlinklib.all;
use work.serportlib.all;
use work.fx2lib.all;

entity rlink_sp1c_fx2 is                -- rlink_core8+serport_1clk+fx2_ic combo
  generic (
    ATOWIDTH : positive :=  5;          -- access timeout counter width
    ITOWIDTH : positive :=  6;          -- idle timeout counter width
    CPREF : slv4 := c_rlink_cpref;      -- comma prefix
    IFAWIDTH : natural :=  5;           -- ser input fifo addr width  (0=none)
    OFAWIDTH : natural :=  5;           -- ser output fifo addr width (0=none)
    PETOWIDTH : positive := 10;         -- fx2 packet end time-out counter width
    CCWIDTH :   positive :=  5;         -- fx2 chunk counter width
    ENAPIN_RLMON : integer := sbcntl_sbf_rlmon;  -- SB_CNTL for rlmon (-1=none)
    ENAPIN_RBMON : integer := sbcntl_sbf_rbmon;  -- SB_CNTL for rbmon (-1=none)
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15);          -- clk divider initial/reset setting
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    CE_INT : in slbit := '0';           -- rri ito time unit clock enable
    RESET  : in slbit;                  -- reset
    ENAXON : in slbit;                  -- enable xon/xoff handling
    ENAESC : in slbit;                  -- enable xon/xoff escaping
    ENAFX2 : in slbit;                  -- enable fx2 usage
    RXSD : in slbit;                    -- receive serial data      (board view)
    TXSD : out slbit;                   -- transmit serial data     (board view)
    CTS_N : in slbit := '0';            -- clear to send   (act.low, board view)
    RTS_N : out slbit;                  -- request to send (act.low, board view)
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3;                  -- rbus: status flags
    RL_MONI : out rl_moni_type;         -- rlink_core: monitor port
    RLB_MONI : out rlb_moni_type;       -- rlink 8b: monitor port
    SER_MONI : out serport_moni_type;   -- ser: monitor port
    FX2_MONI : out fx2ctl_moni_type;    -- fx2: monitor port
    I_FX2_IFCLK : in slbit;             -- fx2: interface clock
    O_FX2_FIFO : out slv2;              -- fx2: fifo address
    I_FX2_FLAG : in slv4;               -- fx2: fifo flags
    O_FX2_SLRD_N : out slbit;           -- fx2: read enable    (act.low)
    O_FX2_SLWR_N : out slbit;           -- fx2: write enable   (act.low)
    O_FX2_SLOE_N : out slbit;           -- fx2: output enable  (act.low)
    O_FX2_PKTEND_N : out slbit;         -- fx2: packet end     (act.low)
    IO_FX2_DATA : inout slv8            -- fx2: data lines
  );
end entity rlink_sp1c_fx2;


architecture syn of rlink_sp1c_fx2 is

  signal RLB_DI : slv8 := (others=>'0');
  signal RLB_ENA : slbit := '0';
  signal RLB_BUSY : slbit := '0';
  signal RLB_DO : slv8 := (others=>'0');
  signal RLB_VAL : slbit := '0';
  signal RLB_HOLD : slbit := '0';

  signal SER_RXDATA : slv8 := (others=>'0');
  signal SER_RXVAL  : slbit := '0';
  signal SER_RXHOLD : slbit := '0';
  signal SER_TXDATA : slv8 := (others=>'0');
  signal SER_TXENA  : slbit := '0';
  signal SER_TXBUSY : slbit := '0';

  signal FX2_RXDATA   : slv8 := (others=>'0');
  signal FX2_RXVAL    : slbit := '0';
  signal FX2_RXHOLD   : slbit := '0';
  signal FX2_RXAEMPTY : slbit := '0';
  signal FX2_TXDATA   : slv8 := (others=>'0');
  signal FX2_TXENA    : slbit := '0';
  signal FX2_TXBUSY   : slbit := '0';
  signal FX2_TXAFULL  : slbit := '0';

begin
  
  CORE : rlink_core8
    generic map (
      ATOWIDTH     => ATOWIDTH,
      ITOWIDTH     => ITOWIDTH,
      CPREF        => CPREF,
      ENAPIN_RLMON => ENAPIN_RLMON,
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
      RXDATA   => SER_RXDATA,
      RXVAL    => SER_RXVAL,
      RXHOLD   => SER_RXHOLD,
      TXDATA   => SER_TXDATA,
      TXENA    => SER_TXENA,
      TXBUSY   => SER_TXBUSY,
      MONI     => SER_MONI,
      RXSD     => RXSD,
      TXSD     => TXSD,
      RXRTS_N  => RTS_N,
      TXCTS_N  => CTS_N
    );
  
  RLBMUX : rlink_rlbmux
    port map (
      SEL       => ENAFX2,
      RLB_DI    => RLB_DI,
      RLB_ENA   => RLB_ENA,
      RLB_BUSY  => RLB_BUSY,
      RLB_DO    => RLB_DO,
      RLB_VAL   => RLB_VAL,
      RLB_HOLD  => RLB_HOLD,
      P0_RXDATA => SER_RXDATA,
      P0_RXVAL  => SER_RXVAL,
      P0_RXHOLD => SER_RXHOLD,
      P0_TXDATA => SER_TXDATA,
      P0_TXENA  => SER_TXENA,
      P0_TXBUSY => SER_TXBUSY,
      P1_RXDATA => FX2_RXDATA,
      P1_RXVAL  => FX2_RXVAL,
      P1_RXHOLD => FX2_RXHOLD,
      P1_TXDATA => FX2_TXDATA,
      P1_TXENA  => FX2_TXENA,
      P1_TXBUSY => FX2_TXBUSY
    );

  FX2CNTL : fx2_2fifoctl_ic
    generic map (
      RXFAWIDTH  => 5,
      TXFAWIDTH  => 5,
      PETOWIDTH  => PETOWIDTH,
      CCWIDTH    => CCWIDTH,
      RXAEMPTY_THRES => 1,
      TXAFULL_THRES  => 1)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RXDATA   => FX2_RXDATA,
      RXVAL    => FX2_RXVAL,
      RXHOLD   => FX2_RXHOLD,
      RXAEMPTY => FX2_RXAEMPTY,
      TXDATA   => FX2_TXDATA,
      TXENA    => FX2_TXENA,
      TXBUSY   => FX2_TXBUSY,
      TXAFULL  => FX2_TXAFULL,
      MONI           => FX2_MONI,
      I_FX2_IFCLK    => I_FX2_IFCLK,
      O_FX2_FIFO     => O_FX2_FIFO,
      I_FX2_FLAG     => I_FX2_FLAG,
      O_FX2_SLRD_N   => O_FX2_SLRD_N,
      O_FX2_SLWR_N   => O_FX2_SLWR_N,
      O_FX2_SLOE_N   => O_FX2_SLOE_N,
      O_FX2_PKTEND_N => O_FX2_PKTEND_N,
      IO_FX2_DATA    => IO_FX2_DATA
    );

  RLB_MONI.rxval  <= RLB_VAL;
  RLB_MONI.rxhold <= RLB_HOLD;
  RLB_MONI.txena  <= RLB_ENA;
  RLB_MONI.txbusy <= RLB_BUSY;
  
end syn;
