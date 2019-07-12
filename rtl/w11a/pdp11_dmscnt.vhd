-- $Id: pdp11_dmscnt.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_dmscnt - syn
-- Description:    pdp11: debug&moni: state counter
--
-- Dependencies:   memlib/ram_2swsr_rfirst_gen
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2014.4-2019.1; ghdl 0.31-0.35
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-06-26   695 14.7  131013 xc6slx16-2    91  107    0   41 s  5.4
--
-- Revision History: -
-- Date         Rev Version  Comment
-- 2019-06-02  1159   1.1.2  use rbaddr_ constants
-- 2016-05-22   767   1.1.1  don't init N_REGS (vivado fix for fsm inference)
-- 2015-12-28   721   1.1    use laddr/waddr; use ena instead of cnt;
-- 2015-07-19   702   1.0    Initial version
-- 2015-06-26   695   0.1    First draft 
------------------------------------------------------------------------------
--
-- rbus registers:
--
--  Addr   Bits  Name        r/w/f  Function
--
--    00         cntl        r/w/-  control
--           01    clr       r/w/-    if 1 starts mem clear
--           00    ena       r/w/-    if 1 enables counting
--    01         addr        r/w/-  memory address
--        10:02    laddr     r/w/-    line address (state number)
--        01:00    waddr     r/-/-    word address (cleared on write)
--    10  15:00  data        r/-/-  memory data
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.rblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_dmscnt is                  -- debug&moni: state counter
  generic (
    RB_ADDR : slv16 := rbaddr_dmscnt_off);
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    DM_STAT_SE : in dm_stat_se_type;    -- debug and monitor status - sequencer
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status - data path
    DM_STAT_CO : in dm_stat_co_type     -- debug and monitor status - core
  );
end pdp11_dmscnt;


architecture syn of pdp11_dmscnt is

  constant rbaddr_cntl  : slv2 := "00";  -- cntl  address offset
  constant rbaddr_addr  : slv2 := "01";  -- addr  address offset
  constant rbaddr_data  : slv2 := "10";  -- data  address offset
  
  constant cntl_rbf_clr      : integer :=     1;
  constant cntl_rbf_ena      : integer :=     0;  
  subtype  addr_rbf_mem     is integer range 10 downto  2;
  subtype  addr_rbf_word    is integer range  1 downto  0;

  type state_type is (
    s_idle,                             -- s_idle: rbus access or count
    s_mread                             -- s_mread: memory read
  );
  
  type regs_type is record
    state : state_type;                 -- state
    rbsel : slbit;                      -- rbus select
    clr : slbit;                        -- clr flag
    ena0 : slbit;                       -- ena flag
    ena1 : slbit;                       -- ena flag (delayed)
    snum0 : slv9;                       -- snum stage 0
    snum1 : slv9;                       -- snum stage 1
    same : slbit;                       -- same snum flag
    laddr : slv9;                       -- line addr
    waddr : slv2;                       -- word addr
    scnt : slv(35 downto 0);            -- scnt buffer
    mbuf : slv20;                       -- lsb memory buffer
  end record regs_type;

  constant regs_init : regs_type := (
    s_idle,                             -- state
    '0',                                -- rbsel
    '0','0','0',                        -- clr,ena0,ena1
    (others=>'0'),                      -- snum0
    (others=>'0'),                      -- snum1
    '0',                                -- same
    (others=>'0'),                      -- laddr
    (others=>'0'),                      -- waddr
    (others=>'0'),                      -- scnt
    (others=>'0')                       -- mbuf
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type;            -- don't init (vivado fix for fsm infer)

  signal CMEM_CEA   : slbit := '0';
  signal CMEM_CEB   : slbit := '0';
  signal CMEM_WEA   : slbit := '0';
  signal CMEM_WEB   : slbit := '0';
  signal CMEM_ADDRA : slv9  := (others=>'0');
  signal CMEM_DIB   : slv(35 downto 0) := (others=>'0');
  signal CMEM_DOA   : slv(35 downto 0) := (others=>'0');

  constant cmem_data_zero : slv(35 downto 0) := (others=>'0');
  
  begin

  CMEM : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH =>  9,
      DWIDTH => 36)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => CMEM_CEA,
      ENB   => CMEM_CEB,
      WEA   => CMEM_WEA,
      WEB   => CMEM_WEB,
      ADDRA => CMEM_ADDRA,
      ADDRB => R_REGS.snum1,
      DIA   => cmem_data_zero,
      DIB   => CMEM_DIB,
      DOA   => CMEM_DOA,
      DOB   => open
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

  proc_next: process (R_REGS, RB_MREQ, DM_STAT_SE,
                      DM_STAT_DP, DM_STAT_DP.psw,    -- xst needs sub-records
                      DM_STAT_CO, CMEM_DOA)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_err  : slbit := '0';
    variable irb_dout : slv16 := (others=>'0');
    variable irbena   : slbit := '0';

    variable icea     : slbit := '0';
    variable iwea     : slbit := '0';
    variable iweb     : slbit := '0';
    variable iaddra   : slv9  := (others=>'0');
    variable iscnt0   : slv(35 downto 0) := (others=>'0');
    variable iscnt1   : slv(35 downto 0) := (others=>'0');

  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_busy := '0';
    irb_err  := '0';
    irb_dout := (others=>'0');
    irbena   := RB_MREQ.re or RB_MREQ.we;

    icea     := '0';
    iwea     := '0';
    iweb     := '0';
    iaddra   := r.snum0;
    
    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' then
      if RB_MREQ.addr(15 downto 2)=RB_ADDR(15 downto 2) then
        n.rbsel := '1';
      end if;
    end if;

    case r.state is

      when s_idle =>                    -- s_idle: rbus access or count ------
        -- rbus transactions
        if r.rbsel = '1' then
          irb_ack := irbena;                -- ack all accesses

          case RB_MREQ.addr(1 downto 0) is

            when rbaddr_cntl =>                 -- cntl ------------------
              if RB_MREQ.we = '1' then
                n.clr := RB_MREQ.din(cntl_rbf_clr);
                if RB_MREQ.din(cntl_rbf_clr) = '1' then -- if clr set
                  n.laddr := (others=>'0');               -- reset mem addr
                end if;
                n.ena0 := RB_MREQ.din(cntl_rbf_ena);
              end if;

            when rbaddr_addr =>                 -- addr ------------------
              if RB_MREQ.we = '1' then
                if r.clr = '1' then               -- if clr active 
                  irb_err := '1';                   -- block addr writes
                else                              -- otherwise
                  n.laddr := RB_MREQ.din(addr_rbf_mem);  -- set mem  addr
                  n.waddr := (others=>'0');              -- clr word addr
                end if;
              end if;

            when rbaddr_data =>                 -- data ------------------
              if RB_MREQ.we = '1' then            -- writes not allowed
                irb_err := '1';
              end if;
              if RB_MREQ.re = '1' then
                if r.clr = '1' then               -- if clr active 
                  irb_err := '1';                   -- block data reads
                else                              -- otherwise
                  case r.waddr is                   -- handle word addr
                    when "00" =>                      -- 1st access
                      icea    := '1';                   -- enable mem read
                      iaddra  := r.laddr;               -- of current line
                      irb_busy := '1';
                      n.state := s_mread;
                    when "01" =>                      -- 2nd part
                      n.waddr := "10";                  -- inc word addr
                    when "10" =>                      -- 3rd part
                      n.waddr := "00";                  -- wrap to next line
                      n.laddr := slv(unsigned(r.laddr) + 1);
                    when others => null;
                  end case;
                end if;
              end if;

            when others =>                      -- <> --------------------
              irb_err := '1';
          end case;
        end if;
    
      when s_mread =>                   --s_mread: memory read ---------------
        irb_ack := irbena;                 -- ack access
        n.waddr := "01";                   -- inc word addr
        n.mbuf  := CMEM_DOA(35 downto 16); -- capture msb part 
        n.state := s_idle;
        
      when others => null;
                     
    end case;
    
    -- rbus output driver
    if r.rbsel = '1' then
      case RB_MREQ.addr(1 downto 0) is
        when rbaddr_cntl =>                 -- cntl ------------------
          irb_dout(cntl_rbf_clr)   := r.clr;
          irb_dout(cntl_rbf_ena)   := r.ena0;
        when rbaddr_addr =>                 -- addr ------------------
          irb_dout(addr_rbf_mem)   := r.laddr;
          irb_dout(addr_rbf_word)  := r.waddr;
        when rbaddr_data =>                 -- data ------------------
          case r.waddr is
            when "00" => irb_dout             := CMEM_DOA(15 downto 0);
            when "01" => irb_dout             := r.mbuf(15 downto  0);
            when "10" => irb_dout(3 downto 0) := r.mbuf(19 downto 16);
            when others => null;
          end case;
        when others => null;
      end case;
    end if;

    -- latch state number
    --  1 msb determined from cpu mode: 0 if kernel and 1 when user or super
    --  8 lsb taken from sequencer snum 
    n.snum0(8) := '0';
    if DM_STAT_DP.psw.cmode /= c_psw_kmode then
      n.snum0(8) := '1';      
    end if;
    n.snum0(7 downto 0) := DM_STAT_SE.snum;
    n.snum1 := r.snum0;
    
    -- incrementer pipeline
    n.same := '0';
    if r.snum0=r.snum1 and r.ena1 ='1' then -- in same state ?
      n.same := '1';                          -- don't read mem and remember
    else                                    -- otherwise
      icea := '1';                            -- enable mem read
    end if;

    -- increment state count
    if r.same = '0' then                    -- was mem read ?
      iscnt0 := CMEM_DOA;                     -- take memory value
    else                                    -- otherwise
      iscnt0 := r.scnt;                       -- use scnt reg
    end if;
    iscnt1 := slv(unsigned(iscnt0) + 1);   -- increment
    n.scnt := iscnt1;                      -- and store

    -- finally setup memory access
    n.ena1 := r.ena0;
    if r.clr = '1' then                 -- mem clear action
      icea    := '1';
      iwea    := '1';
      iaddra  := r.laddr;
      n.laddr := slv(unsigned(r.laddr) + 1);
      if r.laddr = "111111111" then
        n.clr := '0';
      end if;
    elsif r.ena1 = '1' then             -- state count action
      iweb := '1';
    end if;
    
    N_REGS <= n;

    CMEM_CEA   <= icea;
    CMEM_CEB   <= iweb;
    CMEM_WEA   <= iwea;
    CMEM_WEB   <= iweb;
    CMEM_ADDRA <= iaddra;
    CMEM_DIB   <= iscnt1;
      
    RB_SRES.ack  <= irb_ack;
    RB_SRES.err  <= irb_err;
    RB_SRES.busy <= irb_busy;
    RB_SRES.dout <= irb_dout;    
    
  end process proc_next;

end syn;
