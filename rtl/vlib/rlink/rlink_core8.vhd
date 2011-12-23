-- $Id: rlink_core8.vhd 440 2011-12-18 20:08:09Z mueller $
--
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rlink_core8 - syn
-- Description:    rlink core with 8bit interface (core+b2c/c2b+rlmon+rbmon)
--
-- Dependencies:   rlink_core
--                 comlib/byte2cdata
--                 comlib/cdata2byte
--                 rlink_mon_sb    [sim only]
--                 rbus/rb_mon_sb  [sim only]
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.1; ghdl 0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2011-12-09   437 13.1    O40d xc3s1000-4   184  403    0  244 s  9.1
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-09   437   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.comlib.all;
use work.rblib.all;
use work.rlinklib.all;

entity rlink_core8 is                   -- rlink core with 8bit interface
  generic (
    ATOWIDTH : positive :=  5;          -- access timeout counter width
    ITOWIDTH : positive :=  6;          -- idle timeout counter width
    CPREF : slv4 := c_rlink_cpref;      -- comma prefix
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
    RL_MONI : out rl_moni_type;         -- rlink: monitor port
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3                   -- rbus: status flags
  );
end entity rlink_core8;  


architecture syn of rlink_core8 is

  signal RL_DI   : slv9 := (others=>'0');
  signal RL_ENA  : slbit := '0';
  signal RL_BUSY : slbit := '0';
  signal RL_DO   : slv9 := (others=>'0');
  signal RL_VAL  : slbit := '0';
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

  RB_MREQ <= RB_MREQ_L;

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
      BUSY  => RLB_BUSY,
      DO    => RL_DI,
      VAL   => RL_ENA,
      HOLD  => RL_BUSY
    );

-- RL -> RLB converter (DO handling) -------------
  CD2B : cdata2byte                     -- 9bit comma,data -> byte stream
    generic map (
      CPREF => CPREF,
      NCOMM => c_rlink_ncomm)
    port map (
      CLK   => CLK,
      RESET => RESET,
      DI    => RL_DO,
      ENA   => RL_VAL,
      BUSY  => RL_HOLD,
      DO    => RLB_DO,
      VAL   => RLB_VAL,
      HOLD  => RLB_HOLD
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
