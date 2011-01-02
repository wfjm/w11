-- $Id: byte2cdata.vhd 348 2010-12-26 15:23:44Z mueller $
--
-- Copyright 2007- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    byte2cdata - syn
-- Description:    Byte stream to 9 bit comma,data converter
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 12.1; ghdl 0.18-0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-08-27    76   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;

entity byte2cdata is                    -- byte stream -> 9bit comma,data
  generic (
    CPREF : slv4 :=  "1000";            -- comma prefix
    NCOMM : positive :=  4);            -- number of comma chars
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    DI : in slv8;                       -- input data
    ENA : in slbit;                     -- write enable
    BUSY : out slbit;                   -- write port hold    
    DO : out slv9;                      -- output data; bit 8 = comma flag
    VAL : out slbit;                    -- read valid
    HOLD : in slbit                     -- read hold
  );
end byte2cdata;


architecture syn of byte2cdata is

  type state_type is (
    s_idle,
    s_data,
    s_escape
  );

  type regs_type is record
    data : slv9;                        -- current data
    state : state_type;                 -- state
  end record regs_type;

  constant regs_init : regs_type := (
    (others=>'0'),
    s_idle
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

begin

  assert NCOMM <= 14
    report "assert(NCOMM <= 14)"
    severity FAILURE;

  proc_regs: process (CLK)
  begin

    if CLK'event and CLK='1' then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;        
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, DI, ENA, HOLD)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable ival : slbit := '0';
    variable ibusy : slbit := '0';
    
  begin

    r := R_REGS;
    n := R_REGS;

    ival := '0';
    ibusy := '1';
    
    case r.state is
      
      when s_idle =>
        ibusy := '0';
        if ENA = '1' then
          n.data := "0" & DI;
          n.state := s_data;
          if DI(7 downto 4) = CPREF then
            if DI(3 downto 0) = "1111" then
              n.state := s_escape;
            elsif unsigned(DI(3 downto 0)) <= NCOMM then
              n.data := "10000" & DI(3 downto 0);
              n.state := s_data;
            end if;
          end if;
        end if;

      when s_data =>
        ival := '1';
        if HOLD = '0' then
          n.state := s_idle;
        end if;

      when s_escape =>
        ibusy := '0';
        if ENA = '1' then
          n.data := "0" & CPREF & DI(3 downto 0);
          n.state := s_data;
        end if;

      when others => null;
    end case;

    N_REGS <= n;

    DO <= r.data;
    VAL <= ival;
    BUSY <= ibusy;
    
  end process proc_next;


end syn;
