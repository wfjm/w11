-- $Id: cdata2byte.vhd 427 2011-11-19 21:04:11Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    cdata2byte - syn
-- Description:    9 bit comma,data to Byte stream converter
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.2, 9.1, 9.2, 12.1, 13.1; ghdl 0.18-0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-19   427   1.0.2  now numeric_std clean
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-06-30    62   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity cdata2byte is                    -- 9bit comma,data -> byte stream
  generic (
    CPREF : slv4 :=  "1000";            -- comma prefix
    NCOMM : positive :=  4);            -- number of comma chars
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    DI : in slv9;                       -- input data; bit 8 = comma flag
    ENA : in slbit;                     -- write enable
    BUSY : out slbit;                   -- write port hold    
    DO : out slv8;                      -- output data
    VAL : out slbit;                    -- read valid
    HOLD : in slbit                     -- read hold
  );
end cdata2byte;


architecture syn of cdata2byte is

  type state_type is (
    s_idle,
    s_data,
    s_comma,
    s_escape,
    s_edata
  );

  type regs_type is record
    data : slv8;                        -- current data
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

    if rising_edge(CLK) then
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

    variable ido : slv8 := (others=>'0');
    variable ival : slbit := '0';
    variable ibusy : slbit := '0';
    
  begin

    r := R_REGS;
    n := R_REGS;

    ido := r.data;
    ival := '0';
    ibusy := '1';
    
    case r.state is
      
      when s_idle =>
        ibusy := '0';
        if ENA = '1' then
          n.data := DI(7 downto 0);
          n.state := s_data;
          if DI(8) = '1' then
            n.state := s_comma;
          else
            if DI(7 downto 4)=CPREF  and
              (DI(3 downto 0)="1111"  or
               unsigned(DI(3 downto 0))<=NCOMM) then
              n.state := s_escape;
            end if;
          end if;
        end if;

      when s_data =>
        ival := '1';
        if HOLD = '0' then
          n.state := s_idle;
        end if;

      when s_comma =>
        ido := CPREF & r.data(3 downto 0);
        ival := '1';
        if HOLD = '0' then
          n.state := s_idle;
        end if;

      when s_escape =>
        ido := CPREF & "1111";
        ival := '1';
        if HOLD = '0' then
          n.state := s_edata;
        end if;

      when s_edata =>
        ido := (not CPREF) & r.data(3 downto 0);
        ival := '1';
        if HOLD = '0' then
          n.state := s_idle;
        end if;

      when others => null;
    end case;

    N_REGS <= n;

    DO   <= ido;
    VAL  <= ival;
    BUSY <= ibusy;
    
  end process proc_next;


end syn;
