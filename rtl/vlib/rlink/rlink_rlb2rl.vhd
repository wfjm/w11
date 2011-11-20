-- $Id: rlink_rlb2rl.vhd 427 2011-11-19 21:04:11Z mueller $
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
-- Module Name:    rlink_rlb2rl - syn
-- Description:    rlink 8 bit(rlb) to 9 bit(rl) adapter
--
-- Dependencies:   comlib/byte2cdata
--                 comlib/cdata2byte
--                 memlib/fifo_1c_dram
--
-- Test bench:     tb/rb_rlink_serport
--
-- Target Devices: generic
-- Tool versions:  xst 12.1; ghdl 0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri ifa ofa
-- 2010-12-25   348 12.1    M53d xc3s1000-4    61  121   72  114 s  8.3   5   5
-- 2010-12-25   348 12.1    M53d xc3s1000-4    41   84   36   73 s  8.3   5   0
-- 2010-12-25   348 12.1    M53d xc3s1000-4    22   50    -   30 s  4.5   0   0
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-12-24   348   1.0    Initial version 
------------------------------------------------------------------------------
--
--                  byte2cdata         fifo_1c_dram
--                +--------------+    +--------------+
--                |              |    |              |
--   RLB_DI     ->| DI        DO |--->| DI        DO |-> RL_DI
--                |              |    |              |
--   RLB_ENA    ->| ENA      VAL |--->| ENA      VAL |-> RL_ENA
--                |              |    |              |
--   RLB_BUSY   <-| BUSY    HOLD |<---| BUSY    HOLD |<- RL_BUSY
--                |              |    |              |
--                +--------------+    |              |
--                                    |              |
--                           +---+    |              |
--   IFIFO_FILL <------------|map|<---| SIZE         |
--                           +---+    +--------------+
-- 
-- 
--                  cdata2byte         fifo_1c_dram
--                +--------------+    +--------------+
--                |              |    |              |
--   RLB_DO     <-| DO        DI |<---| DO        DI |<- RL_DO
--                |              |    |              |
--   RLB_VAL    <-| VAL      ENA |<---| VAL      ENA |<- RL_VAL
--                |              |    |              |
--   RLB_HOLD   ->| HOLD    BUSY |--->| HOLD    BUSY |-> RL_HOLD
--                |              |    |              |
--                +--------------+    |              |
--                                    |              |
--                           +---+    |              |
--   OFIFO_FILL <------------|map|<---| SIZE         |
--                           +---+    +--------------+
-- 


library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.comlib.all;
use work.memlib.all;
use work.rlinklib.all;

entity rlink_rlb2rl is                  -- rlink 8 bit(rlb) to 9 bit(rl) adapter
  generic (
    CPREF : slv4 :=  "1000";            -- comma prefix
    IFAWIDTH : natural :=  5;           -- input fifo address width  (0=none)
    OFAWIDTH : natural :=  5);          -- output fifo address width (0=none)
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RLB_DI : in slv8;                   -- rlink 8bit: data in
    RLB_ENA : in slbit;                 -- rlink 8bit: data enable
    RLB_BUSY : out slbit;               -- rlink 8bit: data busy
    RLB_DO : out slv8;                  -- rlink 8bit: data out
    RLB_VAL : out slbit;                -- rlink 8bit: data valid
    RLB_HOLD : in slbit;                -- rlink 8bit: data hold
    IFIFO_SIZE : out slv4;              --  input fifo size (4 msb's)
    OFIFO_SIZE : out slv4;              -- output fifo fill (4 msb's)
    RL_DI : out slv9;                   -- rlink 9bit: data in
    RL_ENA : out slbit;                 -- rlink 9bit: data enable
    RL_BUSY : in slbit;                 -- rlink 9bit: data busy
    RL_DO : in slv9;                    -- rlink 9bit: data out
    RL_VAL : in slbit;                  -- rlink 9bit: data valid
    RL_HOLD : out slbit                 -- rlink 9bit: data hold
  );
end rlink_rlb2rl;

architecture syn of rlink_rlb2rl is

  signal RLB_BUSY_L : slbit := '0';
  signal IFIFO_DI : slv9 := (others=>'0');
  signal IFIFO_ENA : slbit := '0';
  signal IFIFO_BUSY : slbit := '0';
  signal OFIFO_DO : slv9 := (others=>'0');
  signal OFIFO_VAL : slbit := '0';
  signal OFIFO_HOLD : slbit := '0';

begin

-- RLB -> RL converter (DI handling) -------------
  
  B2CD : byte2cdata                     -- byte stream -> 9bit comma,data
  generic map (
    CPREF => CPREF,
    NCOMM => c_rlink_ncomm)
  port map (
    CLK   => CLK,
    RESET => RESET,
    DI    => RLB_DI,
    ENA   => RLB_ENA,
    BUSY  => RLB_BUSY_L,
    DO    => IFIFO_DI,
    VAL   => IFIFO_ENA,
    HOLD  => IFIFO_BUSY
  );

  DOIFIFO: if IFAWIDTH > 0 generate
    signal SIZE: slv(IFAWIDTH downto 0) := (others=>'0');
  begin
    IFIFO : fifo_1c_dram                -- input fifo, 1 clock, dram based
    generic map (
      AWIDTH => IFAWIDTH,
      DWIDTH => 9)
    port map (
      CLK   => CLK,
      RESET => RESET,
      DI    => IFIFO_DI,
      ENA   => IFIFO_ENA,
      BUSY  => IFIFO_BUSY,
      DO    => RL_DI,
      VAL   => RL_ENA,
      HOLD  => RL_BUSY,
      SIZE  => SIZE
    );
    IFIFO_SIZE <= SIZE(IFAWIDTH downto IFAWIDTH-3);
  end generate DOIFIFO;

  NOIFIFO: if IFAWIDTH = 0 generate
    RL_DI      <= IFIFO_DI;
    RL_ENA     <= IFIFO_ENA;
    IFIFO_BUSY <= RL_BUSY;
    IFIFO_SIZE <= RLB_BUSY_L & "000";
  end generate NOIFIFO;

  RLB_BUSY <= RLB_BUSY_L;
  
-- RL -> RLB converter (DO handling) -------------

  CD2B : cdata2byte                     -- 9bit comma,data -> byte stream
  generic map (
    CPREF => CPREF,
    NCOMM => c_rlink_ncomm)
  port map (
    CLK   => CLK,
    RESET => RESET,
    DI    => OFIFO_DO,
    ENA   => OFIFO_VAL,
    BUSY  => OFIFO_HOLD,
    DO    => RLB_DO,
    VAL   => RLB_VAL,
    HOLD  => RLB_HOLD
  );

  DOOFIFO: if OFAWIDTH > 0 generate
    signal SIZE : slv(OFAWIDTH downto 0) := (others=>'0');
  begin
    OFIFO : fifo_1c_dram                -- input fifo, 1 clock, dram based
    generic map (
      AWIDTH => OFAWIDTH,
      DWIDTH => 9)
    port map (
      CLK   => CLK,
      RESET => RESET,
      DI    => RL_DO,
      ENA   => RL_VAL,
      BUSY  => RL_HOLD,
      DO    => OFIFO_DO,
      VAL   => OFIFO_VAL,
      HOLD  => OFIFO_HOLD,
      SIZE  => SIZE
    );
    OFIFO_SIZE <= SIZE(OFAWIDTH downto OFAWIDTH-3);
  end generate DOOFIFO;

  NOOFIFO: if OFAWIDTH = 0 generate
    OFIFO_DO   <= RL_DO;
    OFIFO_VAL  <= RL_VAL;
    RL_HOLD    <= OFIFO_HOLD;
    OFIFO_SIZE <= OFIFO_HOLD & "000";
  end generate NOOFIFO;
  
end syn;
