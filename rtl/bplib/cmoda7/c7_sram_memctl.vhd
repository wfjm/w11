-- $Id: c7_sram_memctl.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    c7_sram_memctl - syn
-- Description:    Cmod A7 SRAM controller
--
-- Dependencies:   vlib/xlib/iob_reg_o
--                 vlib/xlib/iob_reg_o_gen
--                 vlib/xlib/iob_reg_io_gen
--
-- Test bench:     tb/tb_c7_sram_memctl
--                 fw_gen/tst_sram/cmoda7/tb/tb_tst_sram_c7
--
-- Target Devices: generic
-- Tool versions:  viv 2017.1; ghdl 0.34
--
-- Synthesized (viv):
-- Date         Rev  viv    Target       flop  lutl  lutm  bram    
-- 2017-06-19   914 2017.1  xc7a35t-1     109    81     0     0   syn level
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-07-01   920   1.0.1  shorten ce and oe times
-- 2017-06-19   914   1.0    Initial version
-- 2017-06-11   912   0.5    First draft 
--
-- Timing of some signals:
--
-- single read request:
-- 
-- state       |_idle  |_read0 |_read1 |...._read0 |_read1 |_idle  |
-- 
-- CLK       __|^^^|___|^^^|___|^^^|___|....^^^|___|^^^|___|^^^|___|^^
-- 
-- REQ       _________|^^^^^^^|____________________________________
-- WE        ______________________________________________________
-- 
-- IOB_CE    __________|^^^^^^^^^^^^^^^^....^^^^^^^^^^^^^^^|_________
-- IOB_OE    __________|^^^^^^^^^^^^^^^^....^^^^^^^^^^^^^^^|_________
-- 
-- ADDR[1:0]           |    00 |    00 |....    11 |    11 |---------
-- DATA      ----------|        data-0 |            data-3 |---------
-- BUSY      __________|^^^^^^^^^^^^^^^^....^^^^^^^^^^^^^^^|________
-- ACK_R     ___________________________...._______|^^^^^^^|________
-- 
-- single write request (assume BE="0011")
-- 
-- state       |_idle  |_write0|_write1|_write0|_write1|_idle  |
-- 
-- CLK       __|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|^^
-- 
-- REQ       _________|^^^^^^^|____________________________________
-- WE        _________|^^^^^^^|____________________________________
-- 
-- ADDR[1:0]           |    00 |    00 |....    01 |    01 |---------
-- DATA      ----------| data-0        |....data-1         |---------
-- 
-- IOB_CE    __________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|_________
-- IOB_OE    ________________________________________________________
-- IOB_WE    ______________|^^^^^^^|___________|^^^^^^^|_____________
-- 
-- BUSY      __________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|_________
-- ACK_W     ______________________________________|^^^^^^^|_________
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;

entity c7_sram_memctl is                -- SRAM controller for Cmod A7
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    REQ   : in slbit;                   -- request
    WE    : in slbit;                   -- write enable
    BUSY : out slbit;                   -- controller busy
    ACK_R : out slbit;                  -- acknowledge read
    ACK_W : out slbit;                  -- acknowledge write
    ACT_R : out slbit;                  -- signal active read
    ACT_W : out slbit;                  -- signal active write
    ADDR : in slv17;                    -- address
    BE : in slv4;                       -- byte enable
    DI : in slv32;                      -- data in  (memory view)
    DO : out slv32;                     -- data out (memory view)
    O_MEM_CE_N : out slbit;             -- sram: chip enable   (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv19;            -- sram: address lines
    IO_MEM_DATA : inout slv8            -- sram: data lines
  );
end c7_sram_memctl;


architecture syn of c7_sram_memctl is

  type state_type is (
    s_idle,                             -- s_idle: wait for req
    s_read0,                            -- s_read0: read cycle, 1st half
    s_read1,                            -- s_read1: read cycle, 2nd half
    s_write0,                           -- s_write0: write cycle, 1st half
    s_write1                            -- s_write1: write cycle, 2nd half
  );
  
  type regs_type is record
    state : state_type;                 -- state
    addrb : slv2;                       -- byte address
    be : slv4;                          -- be pending
    memdi : slv32;                      -- MEM_DI buffer
    memdo : slv24;                      -- MEM_DO buffer for byte 0,1,2
    ackr : slbit;                       -- signal ack_r
  end record regs_type;

  constant regs_init : regs_type := (
    s_idle,                             -- state
    "00",                               -- addrb
    "0000",                             -- be
    (others=>'0'),                      -- memdi
    (others=>'0'),                      -- memdo
    '0'                                 -- ackr
  );
    
  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs
  
  signal CLK_180  : slbit := '0';
  signal MEM_CE_N : slbit := '0';
  signal MEM_WE_N : slbit := '0';
  signal MEM_OE_N : slbit := '0';
  signal MEM_DI   : slv8  := "00000000";
  signal MEM_DO   : slv8  := "00000000";
  signal ADDRB    : slv2  := "00";
  signal ADDRW_CE : slbit := '0';
  signal ADDRB_CE : slbit := '0';
  signal DATA_CEI : slbit := '0';
  signal DATA_CEO : slbit := '0';
  signal DATA_OE  : slbit := '0';

begin

  CLK_180 <= not CLK;
  
  IOB_MEM_CE : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => '1',
      DO  => MEM_CE_N,
      PAD => O_MEM_CE_N
    );
  
  IOB_MEM_WE : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK_180,
      CE  => '1',
      DO  => MEM_WE_N,
      PAD => O_MEM_WE_N
    );
  
  IOB_MEM_OE : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => '1',
      DO  => MEM_OE_N,
      PAD => O_MEM_OE_N
    );
  
  IOB_MEM_ADDRW : iob_reg_o_gen
    generic map (
      DWIDTH => 17)
    port map (
      CLK => CLK,
      CE  => ADDRW_CE,
      DO  => ADDR,
      PAD => O_MEM_ADDR(18 downto 2)
    );
  
  IOB_MEM_ADDRB : iob_reg_o_gen
    generic map (
      DWIDTH => 2)
    port map (
      CLK => CLK,
      CE  => ADDRB_CE,
      DO  => ADDRB,
      PAD => O_MEM_ADDR(1 downto 0)
    );
  
  IOB_MEM_DATA : iob_reg_io_gen
    generic map (
      DWIDTH => 8,
      PULL   => "NONE")
    port map (
      CLK => CLK,
      CEI => DATA_CEI,
      CEO => DATA_CEO,
      OE  => DATA_OE,
      DI  => MEM_DO,
      DO  => MEM_DI,
      PAD => IO_MEM_DATA
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

  proc_next: process (R_REGS, REQ, WE, BE, MEM_DO, DI)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable ibusy : slbit := '0';
    variable iackw : slbit := '0';
    variable iactr : slbit := '0';
    variable iactw : slbit := '0';
    variable imem_ce : slbit := '0';
    variable imem_we : slbit := '0';
    variable imem_oe : slbit := '0';
    variable iaddrw_ce : slbit := '0';
    variable iaddrb    : slv2 := "00";
    variable iaddrb_be : slv2 := "00";
    variable iaddrb_ce : slbit := '0';
    variable idata_cei : slbit := '0';
    variable idata_ceo : slbit := '0';
    variable idata_oe  : slbit := '0';
    variable imem_di   : slv8 := "00000000";

  begin

    r := R_REGS;
    n := R_REGS;
    n.ackr := '0';

    ibusy := '0';
    iackw := '0';
    iactr := '0';
    iactw := '0';

    imem_ce := '0';
    imem_we := '0';
    imem_oe := '0';
    iaddrw_ce := '0';
    iaddrb    := "00";
    iaddrb_be := "00";
    iaddrb_ce := '0';
    idata_cei := '0';
    idata_ceo := '0';
    idata_oe  := '0';

    imem_di     := "00000000";
    if    r.be(0) = '1' then
      iaddrb_be := "00";
      imem_di   := r.memdi( 7 downto  0);
    elsif r.be(1) = '1' then
      iaddrb_be := "01";
      imem_di   := r.memdi(15 downto  8);
    elsif r.be(2) = '1' then
      iaddrb_be := "10";
      imem_di   := r.memdi(23 downto 16);
    elsif r.be(3) = '1' then
      iaddrb_be := "11";
      imem_di   := r.memdi(31 downto 24);
    end if;
    
    case r.state is
      when s_idle =>                    -- s_idle: wait for req
        if REQ = '1' then                 -- if IO requested
          if WE = '0' then                  -- if READ requested
            iaddrw_ce := '1';                 -- latch word address
            iaddrb_ce := '1';                 -- latch byte address (use 0)
            imem_ce   := '1';                 -- ce SRAM next cycle
            imem_oe   := '1';                 -- oe SRAM next cycle
            n.state := s_read0;               -- next: read0
          else                              -- if WRITE requested
            iaddrw_ce := '1';                 -- latch word address
            n.be      := BE;                  -- latch pending BEs
            n.memdi   := DI;                  -- latch data
            n.state := s_write1;              -- next: write 2nd part
          end if;
        end if;
        
      when s_read0 =>                   -- s_read0: read cycle, 1st half
        ibusy := '1';                     -- signal busy, unable to handle req
        iactr := '1';                     -- signal mem read
        imem_ce   := '1';                 -- ce SRAM next cycle
        imem_oe   := '1';                 -- oe SRAM next cycle
        case r.addrb is                   -- capture last byte; inc byte count
          when  "00" => n.addrb := "01";
          when  "01" => n.addrb := "10"; n.memdo( 7 downto  0) := MEM_DO;
          when  "10" => n.addrb := "11"; n.memdo(15 downto  8) := MEM_DO;
          when  "11" => n.addrb := "00"; n.memdo(23 downto 16) := MEM_DO;
          when others => null;
        end case;
        n.state := s_read1;               -- next: read1
        
      when s_read1 =>                   -- s_read1: read cycle, 2nd half
        ibusy := '1';                     -- signal busy, unable to handle req
        iactr := '1';                     -- signal mem read
        idata_cei := '1';                 -- latch input data
        if r.addrb = "00" then            -- last byte seen (counter wrapped) ?
          n.ackr := '1';                    -- ACK_R next cycle
          n.state := s_idle;
        else                              -- more bytes to do ?
          imem_ce   := '1';                 -- ce SRAM next cycle
          imem_oe   := '1';                 -- oe SRAM next cycle
          iaddrb    := r.addrb;             -- use addrb counter
          iaddrb_ce := '1';                 -- latch byte address (use r.addrb)
          n.state := s_read0;
        end if;

      when s_write0 =>                  -- s_write0: write cycle, 1st half
        ibusy := '1';                     -- signal busy, unable to handle req
        iactw := '1';                     -- signal mem write
        idata_oe := '1';                  -- oe FPGA next cycle
        imem_ce  := '1';                  -- ce SRAM next cycle
        imem_we  := '1';                  -- we SRAM next shifted cycle
        n.state := s_write1;              -- next: write cycle, 2nd half
        
      when s_write1 =>                  -- s_write1: write cycle, 2nd half
        ibusy := '1';                     -- signal busy, unable to handle req
        iactw := '1';                     -- signal mem write
        if r.be = "0000" then             -- all done ?
          iackw := '1';                     -- signal write acknowledge
          n.state := s_idle;                -- next: idle
        else                              -- more to do ?
          idata_oe  := '1';                 -- oe FPGA next cycle
          imem_ce   := '1';                 -- ce SRAM next cycle
          idata_ceo := '1';                 -- latch output data (to SRAM)
          iaddrb    := iaddrb_be;           -- use addrb from be encode
          iaddrb_ce := '1';                 -- latch byte address (use iaddr_be)
          n.be(to_integer(unsigned(iaddrb_be))) := '0';  -- mark byte done
          n.state := s_write0;              -- next: write 1st half
        end if;
        
      when others => null;
    end case;
    
    N_REGS <= n;

    MEM_CE_N <= not imem_ce;
    MEM_WE_N <= not imem_we;
    MEM_OE_N <= not imem_oe;
    MEM_DI   <= imem_di;
    ADDRW_CE <= iaddrw_ce;
    ADDRB    <= iaddrb;
    ADDRB_CE <= iaddrb_ce;
    DATA_CEI <= idata_cei;
    DATA_CEO <= idata_ceo;
    DATA_OE  <= idata_oe;

    BUSY  <= ibusy;
    ACK_R <= r.ackr;
    ACK_W <= iackw;
    ACT_R <= iactr;
    ACT_W <= iactw;
    DO    <= MEM_DO & r.memdo;
    
  end process proc_next;
  
end syn;
