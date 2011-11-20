-- $Id: rlink_base.vhd 427 2011-11-19 21:04:11Z mueller $
--
-- Copyright 2010-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rlink_base - syn
-- Description:    rlink base: core+rl2rlb+rlmon+rbmon - w/ buffered 8bit iface
--
-- Dependencies:   rlink_core
--                 rlink_rlb2rl
--                 rlink_mon_sb    [sim only]
--                 rbus/rb_mon_sb  [sim only]
--
-- Test bench:     tb/tb_rlink_serport
--                 tb/tb_rlink_tba_ttcombo
--
-- Target Devices: generic
-- Tool versions:  xst 12.1, 13.1; ghdl 0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri ifa ofa
-- 2010-12-25   348 12.1    M53d xc3s1000-4   206  451   72  304 s 10.5   5   5
-- 2010-12-25   348 12.1    M53d xc3s1000-4   194  407   36  262 s 10.4   5   0
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-19   427   1.0.1  now numeric_std clean
-- 2010-12-25   348   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.rlinklib.all;

entity rlink_base is                    -- rlink base: core+rlb2rl+rlmon+rbmon
                                        -- with buffered 8bit interface
  generic (
    ATOWIDTH : positive :=  5;          -- access timeout counter width
    ITOWIDTH : positive :=  6;          -- idle timeout counter width
    CPREF : slv4 := c_rlink_cpref;      -- comma prefix
    IFAWIDTH : natural :=  5;           -- input fifo address width  (0=none)
    OFAWIDTH : natural :=  5;           -- output fifo address width (0=none)
    ENAPIN_RLMON : integer := sbcntl_sbf_rlmon;  -- SB_CNTL for rlmon (-1=none)
    ENAPIN_RBMON : integer := sbcntl_sbf_rbmon); -- SB_CNTL for rbmon (-1=none)
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit := '0';           -- rlink ito time unit clock enable
    RESET  : in slbit;                  -- reset
    RLB_DI : in slv8;                   -- rlink 8b: data in
    RLB_ENA : in slbit;                 -- rlink 8b: data enable
    RLB_BUSY : out slbit;               -- rlink 8b: data busy
    RLB_DO : out slv8;                  -- rlink 8b: data out
    RLB_VAL : out slbit;                -- rlink 8b: data valid
    RLB_HOLD : in slbit;                -- rlink 8b: data hold
    IFIFO_SIZE : out slv4;              --  input fifo size (4 msb's)
    OFIFO_SIZE : out slv4;              -- output fifo fill (4 msb's)
    RL_MONI : out rl_moni_type;         -- rlink: monitor port
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3                   -- rbus: status flags
  );
end entity rlink_base;  


architecture syn of rlink_base is

  signal RL_DI : slv9 := (others=>'0');
  signal RL_ENA : slbit := '0';
  signal RL_BUSY : slbit := '0';
  signal RL_DO : slv9 := (others=>'0');
  signal RL_VAL : slbit := '0';
  signal RL_HOLD : slbit := '0';
  signal RB_MREQ_L : rb_mreq_type := rb_mreq_init;  -- local, readable RB_MREQ

begin

  RL : rlink_core
    generic map (
      ATOWIDTH => ATOWIDTH,
      ITOWIDTH => ITOWIDTH)
    port map (
      CLK      => CLK,
      CE_INT   => CE_INT,
      RESET    => RESET,
      RL_DI    => RL_DI,
      RL_ENA   => RL_ENA,
      RL_BUSY  => RL_BUSY,
      RL_DO    => RL_DO,
      RL_VAL   => RL_VAL,
      RL_HOLD  => RL_HOLD,
      RL_MONI  => RL_MONI,
      RB_MREQ  => RB_MREQ_L,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT
    );
  -- vhdl'93 unfortunately doesn't allow to read a signal bound to an out port
  -- because RB_MREQ is read by the monitors, an extra internal
  -- signal must be used. This will not be needed with vhdl'2000 anymore
  
  RB_MREQ <= RB_MREQ_L;

  RLB2RL : rlink_rlb2rl
    generic map (
      CPREF    => CPREF,
      IFAWIDTH => IFAWIDTH,
      OFAWIDTH => OFAWIDTH)
    port map (
      CLK        => CLK,
      RESET      => RESET,
      RLB_DI     => RLB_DI,
      RLB_ENA    => RLB_ENA,
      RLB_BUSY   => RLB_BUSY,
      RLB_DO     => RLB_DO,
      RLB_VAL    => RLB_VAL,
      RLB_HOLD   => RLB_HOLD,
      IFIFO_SIZE => IFIFO_SIZE,
      OFIFO_SIZE => OFIFO_SIZE,
      RL_DI      => RL_DI,
      RL_ENA     => RL_ENA,
      RL_BUSY    => RL_BUSY,
      RL_DO      => RL_DO,
      RL_VAL     => RL_VAL,
      RL_HOLD    => RL_HOLD
    );
  
-- synthesis translate_off

  RLMON: if ENAPIN_RLMON >= 0  generate
    MON : rlink_mon_sb
      generic map (
        DWIDTH => RL_DI'length,
        ENAPIN => ENAPIN_RLMON)
      port map (
        CLK     => CLK,
        RL_DI   => RL_DI,
        RL_ENA  => RL_ENA,
        RL_BUSY => RL_BUSY,
        RL_DO   => RL_DO,
        RL_VAL  => RL_VAL,
        RL_HOLD => RL_HOLD
      );
  end generate RLMON;

  RBMON: if ENAPIN_RBMON >= 0  generate
    MON : rb_mon_sb
      generic map (
        DBASE  => 8,
        ENAPIN => ENAPIN_RBMON)
      port map (
        CLK     => CLK,
        RB_MREQ => RB_MREQ_L,
        RB_SRES => RB_SRES,
        RB_LAM  => RB_LAM,
        RB_STAT => RB_STAT
      );
  end generate RBMON;
  
-- synthesis translate_on

end syn;
