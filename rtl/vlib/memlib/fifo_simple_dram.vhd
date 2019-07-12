-- $Id: fifo_simple_dram.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    fifo_simple_dram - syn
-- Description:    FIFO, CE/WE interface, distributed RAM based
--
-- Dependencies:   ram_1swar_gen
--
-- Test bench:     tb/tb_fifo_simple_dram
-- Target Devices: generic Spartan, Artix
-- Tool versions:  ise 14.7; viv 2017.2-2018.3; ghdl 0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-02-09  1109   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.memlib.all;

entity fifo_simple_dram is              -- fifo, CE/WE interface, dram based
  generic (
    AWIDTH : positive :=  6;            -- address width (sets size)
    DWIDTH : positive := 16);           -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CE : in slbit;                      -- clock enable
    WE : in slbit;                      -- write enable
    DI : in slv(DWIDTH-1 downto 0);     -- input data
    DO : out slv(DWIDTH-1 downto 0);    -- output data
    EMPTY : out slbit;                  -- fifo empty status
    FULL : out slbit;                   -- fifo full status
    SIZE : out slv(AWIDTH-1 downto 0)   -- number of used slots
  );
end fifo_simple_dram;


architecture syn of fifo_simple_dram is

  type regs_type is record
    waddr : slv(AWIDTH-1 downto 0);     -- write address
    raddr : slv(AWIDTH-1 downto 0);     -- read address
    empty : slbit;                      -- empty flag
    full  : slbit;                      -- full flag
  end record regs_type;

  constant memsize : positive := 2**AWIDTH;
  constant regs_init : regs_type := (
    slv(to_unsigned(0,AWIDTH)),         -- waddr
    slv(to_unsigned(0,AWIDTH)),         -- raddr
    '1','0'                             -- empty,full
  );
  
  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  signal RAM_WE   : slbit := '0';
  signal RAM_ADDR : slv(AWIDTH-1 downto 0) := (others=>'0');
  
begin

  RAM : ram_1swar_gen
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH => DWIDTH)
    port map (
      CLK  => CLK,
      WE   => RAM_WE,
      ADDR => RAM_ADDR,
      DI   => DI,
      DO   => DO
    );
  
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

  proc_next: process (R_REGS, RESET, CE, WE)
    
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    
    variable iram_we   : slbit := '0';
    variable iram_addr : slv(AWIDTH-1 downto 0) := (others=>'0');
    variable isize     : slv(AWIDTH-1 downto 0) := (others=>'0');

  begin
    
    r := R_REGS;
    n := R_REGS;
    
    iram_we := '0';
    if WE = '1' then                    -- select RAM address
      iram_addr := r.waddr;               -- for write 
    else
      iram_addr := r.raddr;               -- for read
    end if;
    
    isize := slv(unsigned(r.waddr) - unsigned(r.raddr));

    if CE = '1' then                    -- do read or write
      if WE = '1' then                    -- do write
        if r.full = '0' then                -- only if not full
          iram_we := '1';                     -- assert write enable
          n.waddr := slv(unsigned(r.waddr) + 1); -- advance address
          n.empty := '0';                        -- can't be empty after write
          if unsigned(isize) = memsize-2 then    -- check for full
            n.full := '1';
          end if;
        end if;
        
      else                                -- do read
        if r.empty = '0' then               -- only if not empty
          n.raddr := slv(unsigned(r.raddr) + 1); -- advance address
          n.full  := '0';                        -- can't be full after read
          if unsigned(isize) = 1  then           -- check for empty
            n.empty := '1';
          end if;
        end if;
      end if;
    end if;
    
    N_REGS <= n;
    
    RAM_ADDR <= iram_addr;
    RAM_WE   <= iram_we;

    EMPTY    <= r.empty;
    FULL     <= r.full;
    SIZE     <= isize;

  end process proc_next;

-- synthesis translate_off
  proc_moni: process (CLK)
    variable oline : line;
  begin

    if rising_edge(CLK) then
      if RESET='0' and CE='1' then      -- not in reset and active
        if WE = '0' then
          if R_REGS.empty='1' then      -- read on empty fifo
            write(oline, now, right, 12);
            write(oline, string'(" read on empty fifo - FAIL in "));
            write(oline, fifo_simple_dram'path_name);
            writeline(output, oline);
          end if;
        else
          if R_REGS.full='1' then       -- write on full fifo
            write(oline, now, right, 12);
            write(oline, string'(" write on full fifo - FAIL in "));
            write(oline, fifo_simple_dram'path_name);
            writeline(output, oline);        
          end if;
        end if;
      end if;
    end if;

  end process proc_moni;
-- synthesis translate_on

end syn;
