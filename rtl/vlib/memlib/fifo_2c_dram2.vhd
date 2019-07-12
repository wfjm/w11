-- $Id: fifo_2c_dram2.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    fifo_2c_dram2 - syn
-- Description:    FIFO, two clock domain, distributed RAM based, with
--                 enable/busy/valid/hold interface.
--
-- Dependencies:   ram_1swar_1ar_gen
--                 genlib/gray_cnt_n
--                 genlib/gray2bin_gen
--
-- Test bench:     tb/tb_fifo_2c_dram
-- Target Devices: generic
-- Tool versions:  viv 2015.4-2018.3; ghdl 0.33-0.35    !! NOT FOR ISE !!
-- Note:           for usage with ISE use fifo_2c_dram
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-03-24   751   1.0    Initial version (derived from fifo_2c_dram, is
--                             exactly same logic, re-written to allow proper
--                             usage of vivado constraints)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.genlib.all;
use work.memlib.all;

entity fifo_2c_dram2 is                 -- fifo, 2 clock, dram based (v2)
  generic (
    AWIDTH : positive :=  5;            -- address width (sets size)
    DWIDTH : positive := 16);           -- data width
  port (
    CLKW : in slbit;                    -- clock (write side)
    CLKR : in slbit;                    -- clock (read side)
    RESETW : in slbit;                  -- W|reset from write side
    RESETR : in slbit;                  -- R|reset from read side
    DI : in slv(DWIDTH-1 downto 0);     -- W|input data
    ENA : in slbit;                     -- W|write enable
    BUSY : out slbit;                   -- W|write port hold    
    DO : out slv(DWIDTH-1 downto 0);    -- R|output data
    VAL : out slbit;                    -- R|read valid
    HOLD : in slbit;                    -- R|read hold
    SIZEW : out slv(AWIDTH-1 downto 0); -- W|number slots to write
    SIZER : out slv(AWIDTH-1 downto 0)  -- R|number slots to read 
  );
end fifo_2c_dram2;


architecture syn of fifo_2c_dram2 is

  subtype a_range is integer range AWIDTH-1 downto  0;   -- addr value regs

  signal RW_RADDR_S0 :  slv(a_range) := (others=>'0'); -- read addr: CLKR->CLKW
  signal RW_RADDR_S1 :  slv(a_range) := (others=>'0'); -- read addr: CLKW->CLKW
  signal RW_SIZEW :     slv(a_range) := (others=>'0'); -- slots to write
  signal RW_BUSY :      slbit        := '0';           -- busy flag
  signal RW_RSTW :      slbit        := '0';           -- resetw active
  signal RW_RSTW_E_S0 : slbit        := '0';           -- rstw-echo: CLKR->CLKW
  signal RW_RSTW_E_S1 : slbit        := '0';           -- rstw-echo: CLKW->CLKW
  signal RW_RSTR_S0 :   slbit        := '0';           -- resetr: CLKR->CLKW
  signal RW_RSTR_S1 :   slbit        := '0';           -- resetr: CLKW->CLKW
  
  signal NW_SIZEW :     slv(a_range) := (others=>'0'); -- slots to write
  signal NW_BUSY :      slbit        := '0';           -- busy flag
  signal NW_RSTW :      slbit        := '0';           -- resetw active

  signal RR_WADDR_S0 :  slv(a_range) := (others=>'0'); -- write addr: CLKW->CLKR
  signal RR_WADDR_S1 :  slv(a_range) := (others=>'0'); -- write addr: CLKR->CLKR
  signal RR_SIZER :     slv(a_range) := (others=>'0'); -- slots to read
  signal RR_VAL:        slbit        := '0';           -- valid flag
  signal RR_RSTR :      slbit        := '0';           -- resetr active
  signal RR_RSTR_E_S0 : slbit        := '0';           -- rstr-echo: CLKW->CLKR
  signal RR_RSTR_E_S1 : slbit        := '0';           -- rstr-echo: CLKR->CLKR
  signal RR_RSTW_S0 :   slbit        := '0';           -- resetw: CLKW->CLKR
  signal RR_RSTW_S1 :   slbit        := '0';           -- resetw: CLKR->CLKR

  signal NR_SIZER :    slv(a_range) := (others=>'0'); -- slots to read
  signal NR_VAL:       slbit        := '0';           -- valid flag
  signal NR_RSTR :     slbit        := '0';           -- resetr active

  signal WADDR : slv(AWIDTH-1 downto 0) := (others=>'0');
  signal RADDR : slv(AWIDTH-1 downto 0) := (others=>'0');
  signal WADDR_BIN_W : slv(AWIDTH-1 downto 0) := (others=>'0');
  signal RADDR_BIN_R : slv(AWIDTH-1 downto 0) := (others=>'0');
  signal WADDR_BIN_R : slv(AWIDTH-1 downto 0) := (others=>'0');
  signal RADDR_BIN_W : slv(AWIDTH-1 downto 0) := (others=>'0');

  signal GCW_RST : slbit := '0';
  signal GCW_CE  : slbit := '0';
  signal GCR_RST : slbit := '0';
  signal GCR_CE  : slbit := '0';

  attribute ASYNC_REG: string;

  attribute ASYNC_REG of RW_RADDR_S0   : signal is "true";
  attribute ASYNC_REG of RW_RADDR_S1   : signal is "true";
  attribute ASYNC_REG of RW_RSTW_E_S0  : signal is "true";
  attribute ASYNC_REG of RW_RSTW_E_S1  : signal is "true";
  attribute ASYNC_REG of RW_RSTR_S0    : signal is "true";
  attribute ASYNC_REG of RW_RSTR_S1    : signal is "true";

  attribute ASYNC_REG of RR_WADDR_S0   : signal is "true";
  attribute ASYNC_REG of RR_WADDR_S1   : signal is "true";
  attribute ASYNC_REG of RR_RSTR_E_S0  : signal is "true";
  attribute ASYNC_REG of RR_RSTR_E_S1  : signal is "true";
  attribute ASYNC_REG of RR_RSTW_S0    : signal is "true";
  attribute ASYNC_REG of RR_RSTW_S1    : signal is "true";
  
begin

  RAM : ram_1swar_1ar_gen               -- dual ported memory
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH => DWIDTH)
    port map (
      CLK   => CLKW,
      WE    => GCW_CE,
      ADDRA => WADDR,
      ADDRB => RADDR,
      DI    => DI,
      DOA   => open,
      DOB   => DO
    );
  
  GCW : gray_cnt_gen                    -- gray counter for write address
    generic map (
      DWIDTH => AWIDTH)
    port map (
      CLK   => CLKW,
      RESET => GCW_RST,
      CE    => GCW_CE,
      DATA  => WADDR
    );
  
  GCR : gray_cnt_gen                    -- gray counter for read address
    generic map (
      DWIDTH => AWIDTH)
    port map (
      CLK   => CLKR,
      RESET => GCR_RST,
      CE    => GCR_CE,
      DATA  => RADDR
    );
  
  G2B_WW : gray2bin_gen                 -- gray->bin for waddr on write side
    generic map (DWIDTH => AWIDTH)
    port map (DI => WADDR, DO => WADDR_BIN_W);
  G2B_WR : gray2bin_gen                 -- gray->bin for waddr on read  side
    generic map (DWIDTH => AWIDTH)
    port map (DI => RR_WADDR_S1, DO => WADDR_BIN_R);
  G2B_RR : gray2bin_gen                 -- gray->bin for raddr on read  side
    generic map (DWIDTH => AWIDTH)
    port map (DI => RADDR, DO => RADDR_BIN_R);
  G2B_RW : gray2bin_gen                 -- gray->bin for raddr on write side
    generic map (DWIDTH => AWIDTH)
    port map (DI => RW_RADDR_S1, DO => RADDR_BIN_W);

  --
  -- write side --------------------------------------------------------------
  --
  proc_regw: process (CLKW)
  begin
    if rising_edge(CLKW) then
      RW_RADDR_S0  <= RADDR;            -- sync 0: CLKR->CLKW
      RW_RADDR_S1  <= RW_RADDR_S0;      -- sync 1: CLKW
      RW_SIZEW     <= NW_SIZEW;
      RW_BUSY      <= NW_BUSY;
      RW_RSTW      <= NW_RSTW;
      RW_RSTW_E_S0 <= RR_RSTW_S1;       -- sync 0: CLKR->CLKW
      RW_RSTW_E_S1 <= RW_RSTW_E_S0;     -- sync 1: CLKW
      RW_RSTR_S0   <= RR_RSTR;          -- sync 0: CLKR->CLKW
      RW_RSTR_S1   <= RW_RSTR_S0;       -- sync 1: CLKW
  end if;
  end process proc_regw;

  proc_nextw: process (RW_BUSY, RW_SIZEW, RW_RSTW, RW_RSTW_E_S1, RW_RSTR_S1,
                       ENA, RESETW, RADDR_BIN_W, WADDR_BIN_W)

    variable ibusy : slbit := '0';
    variable irstw : slbit := '0';
    variable igcw_ce  : slbit := '0';
    variable igcw_rst : slbit := '0';
    variable isizew : slv(a_range) := (others=>'0');
  begin

    isizew := slv(unsigned(RADDR_BIN_W) + unsigned(not WADDR_BIN_W));
    ibusy  := '0';
    igcw_ce  := '0';
    igcw_rst := '0';

    if unsigned(isizew) = 0 then        -- if no free slots
      ibusy := '1';                       -- next cycle busy=1
    end if;

    if ENA='1' and RW_BUSY='0' then     -- if ena=1 and this cycle busy=0
      igcw_ce := '1';                     -- write this value
      if unsigned(isizew) = 1 then        -- if this last free slot
        ibusy := '1';                       -- next cycle busy=1
      end if;
    end if;

    irstw := RW_RSTW;
    if RESETW = '1' then                -- reset(write side) request
      irstw := '1';                       -- set RSTW flag
    elsif RW_RSTW_E_S1 = '1' then       -- request gone and return seen
      irstw := '0';                       -- clear RSTW flag
    end if;

    if RW_RSTW='1' and RW_RSTW_E_S1='1' then -- RSTW seen on write and read side
      igcw_rst := '1';                     -- clear write address counter
    end if;
    if RW_RSTR_S1 = '1' then            -- RSTR active
      igcw_rst := '1';                    -- clear write address counter
    end if;

    if RESETW='1' or RW_RSTW='1' or RW_RSTW_E_S1='1' or RW_RSTR_S1='1'
    then             -- RESETW or RESETR active
      ibusy  := '1';                      -- signal write side busy
      isizew := (others=>'1');
    end if;

    NW_BUSY  <= ibusy;
    NW_RSTW  <= irstw;
    NW_SIZEW <= isizew;
    
    GCW_CE  <= igcw_ce;
    GCW_RST <= igcw_rst;
    BUSY    <= RW_BUSY;
    SIZEW   <= RW_SIZEW;    

  end process proc_nextw;

  --
  -- read side ---------------------------------------------------------------
  --
  proc_regr: process (CLKR)
  begin
    if rising_edge(CLKR) then
      RR_WADDR_S0  <= WADDR;            -- sync 0: CLKW->CLKR
      RR_WADDR_S1  <= RR_WADDR_S0;      -- sync 1: CLKW
      RR_SIZER     <= NR_SIZER;
      RR_VAL       <= NR_VAL;
      RR_RSTR      <= NR_RSTR;
      RR_RSTR_E_S0 <= RW_RSTR_S1;       -- sync 0: CLKW->CLKR
      RR_RSTR_E_S1 <= RR_RSTR_E_S0;     -- sync 1: CLKW
      RR_RSTW_S0   <= RW_RSTW;          -- sync 0: CLKW->CLKR
      RR_RSTW_S1   <= RR_RSTW_S0;       -- sync 1: CLKW
    end if;
  end process proc_regr;

  proc_nextr: process (RR_VAL, RR_SIZER, RR_RSTR, RR_RSTR_E_S1, RR_RSTW_S1,
                       HOLD, RESETR, RADDR_BIN_R, WADDR_BIN_R)

    variable ival : slbit := '0';
    variable irstr : slbit := '0';
    variable igcr_ce  : slbit := '0';
    variable igcr_rst : slbit := '0';
    variable isizer : slv(a_range) := (others=>'0');
   
  begin

    isizer := slv(unsigned(WADDR_BIN_R) - unsigned(RADDR_BIN_R));
    ival  := '1';
    igcr_ce  := '0';
    igcr_rst := '0';

    if unsigned(isizer) = 0 then        -- if nothing to read
      ival := '0';                        -- next cycle val=0
    end if;

    if RR_VAL='1' and HOLD='0' then     -- this cycle val=1 and no hold
      igcr_ce := '1';                     -- retire this value
      if unsigned(isizer) = 1  then       -- if this is last one
        ival := '0';                        -- next cycle val=0
      end if;
    end if;

    irstr := RR_RSTR;
    if RESETR = '1' then                -- reset(read side) request
      irstr := '1';                       -- set RSTR flag
    elsif RR_RSTR_E_S1 = '1' then       -- request gone and return seen
      irstr := '0';                       -- clear RSTR flag
    end if;

    if RR_RSTR='1' and RR_RSTR_E_S1='1' then -- RSTR seen on read and write side
      igcr_rst := '1';                     -- clear read address counter
    end if;
    if RR_RSTW_S1 = '1' then            -- RSTW active
      igcr_rst := '1';                    -- clear read address counter
    end if;

    if RESETR='1' or RR_RSTR='1' or RR_RSTR_E_S1='1' or RR_RSTW_S1='1'
    then                                -- RESETR or RESETW active 
      ival   := '0';                       -- signal read side empty
      isizer := (others=>'0');
    end if;

    NR_VAL   <= ival;
    NR_RSTR  <= irstr;
    NR_SIZER <= isizer;

    GCR_CE  <= igcr_ce;
    GCR_RST <= igcr_rst;
    VAL     <= RR_VAL;
    SIZER   <= RR_SIZER;

  end process proc_nextr;

end syn;
