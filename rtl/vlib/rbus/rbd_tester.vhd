-- $Id: rbd_tester.vhd 352 2011-01-02 13:01:37Z mueller $
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
-- Module Name:    rbd_tester - syn
-- Description:    rbus dev: rbus tester
--
-- Dependencies:   memlib/fifo_1c_dram_raw
--
-- Test bench:     rlink/tb/tb_rlink (used as test target)
--
-- Target Devices: generic
-- Tool versions:  xst 12.1; ghdl 0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-12-12   344 12.1    M53d xc3s1000-4    78  204   32  133 s  8.0
-- 2010-12-04   343 12.1    M53d xc3s1000-4    75  214   32  136 s  9.3
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-12-31   352   1.0.3  simplify irb_ack logic
-- 2010-12-29   351   1.0.2  default addr 111101xx->111100xx
-- 2010-12-12   344   1.0.1  send 0101.. on busy or err; fix init and busy logic
-- 2010-12-04   343   1.0    Initial version 
------------------------------------------------------------------------------
--
-- rbus registers:
--
-- Address   Bits Name        r/w/f  Function
-- bbbbbb00       cntl        r/w/-  Control register
--             15   nofifo    r/w/-    a 1 disables fifo, to test delayed aborts
--          14:12   stat      r/w/-    echo'ed on RB_STAT
--          11:00   nbusy     r/w/-    busy cycles (for data and fifo access)
--             00   go        r/w/-    enables monitor
-- bbbbbb01 15:00 data        r/w/-  Data register (just w/r reg, no function)
-- bbbbbb10 15:00 fifo        r/w/-  Fifo interface register
-- bbbbbb11       attn        r/w/-  Attn/Length register
--          15:00                    w: ping RB_LAM lines
--           9:00                    r: return cycle length of last access
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.memlib.all;
use work.rblib.all;

entity rbd_tester is                    -- rbus dev: rbus tester
                                        -- complete rrirp_aif interface
  generic (
    RB_ADDR : slv8 := conv_std_logic_vector(2#11110000#,8));
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_LAM : out slv16;                 -- rbus: look at me
    RB_STAT : out slv3                  -- rbus: status flags
  );
end entity rbd_tester;


architecture syn of rbd_tester is

  constant awidth : positive := 4;      -- fifo address width

  constant rbaddr_cntl : slv2 := "00";  -- cntl address offset
  constant rbaddr_data : slv2 := "01";  -- data address offset
  constant rbaddr_fifo : slv2 := "10";  -- fifo address offset
  constant rbaddr_attn : slv2 := "11";  -- attn address offset

  constant cntl_rbf_nofifo  : integer := 15;
  subtype  cntl_rbf_stat    is integer range 14 downto 12;
  subtype  cntl_rbf_nbusy   is integer range  9 downto  0;

  constant init_rbf_cntl  : integer :=  0;
  constant init_rbf_data  : integer :=  1;
  constant init_rbf_fifo  : integer :=  2;
  
  type regs_type is record              -- state registers
    rbsel : slbit;                      -- rbus select
    nofifo : slbit;                     -- disable fifo flag
    stat : slv3;                        -- stat setting
    nbusy : slv10;                      -- nbusy setting
    data : slv16;                       -- data register
    act_1 : slbit;                      -- rbsel and (re or we) in last cycle
    ncyc : slv10;                       -- cycle length of last access
    cntbusy : slv10;                    -- busy timer
    cntcyc : slv10;                     -- cycle length counter
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- rbsel
    '0',                                -- nofifo
    (others=>'0'),                      -- stat
    (others=>'0'),                      -- nbusy
    (others=>'0'),                      -- data
    '0',                                -- act_1
    (others=>'0'),                      -- ncyc
    (others=>'0'),                      -- cntbusy
    (others=>'0')                       -- cntcyc
  );

  constant cntcyc_max : slv(regs_init.cntcyc'range) := (others=>'1');

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;
   
  signal FIFO_RESET : slbit := '0';
  signal FIFO_RE : slbit := '0';
  signal FIFO_WE : slbit := '0';
  signal FIFO_EMPTY : slbit := '0';
  signal FIFO_FULL : slbit := '0';
  signal FIFO_SIZE : slv(awidth-1 downto 0) := (others=>'0');
  signal FIFO_DO : slv16 := (others=>'0');
  
begin

  FIFO : fifo_1c_dram_raw
    generic map (
      AWIDTH => awidth,
      DWIDTH => 16)
    port map (
      CLK   => CLK,
      RESET => FIFO_RESET,
      RE    => FIFO_RE,
      WE    => FIFO_WE,
      DI    => RB_MREQ.din,
      DO    => FIFO_DO,
      SIZE  => FIFO_SIZE,      
      EMPTY => FIFO_EMPTY,
      FULL  => FIFO_FULL
    );

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

  proc_next : process (R_REGS, RB_MREQ, FIFO_EMPTY, FIFO_FULL, FIFO_DO)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_err  : slbit := '0';
    variable irb_dout : slv16 := (others=>'0');
    variable irbena : slbit := '0';
    variable irblam : slv16 := (others=>'0');
    variable ififo_re : slbit := '0';
    variable ififo_we : slbit := '0';
    variable ififo_reset : slbit := '0';
    variable isbusy : slbit := '0';
  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_busy := '0';
    irb_err  := '0';
    irb_dout := (others=>'0');
    irblam   := (others=>'0');

    irbena  := RB_MREQ.re or RB_MREQ.we;
        
    ififo_re := '0';
    ififo_we := '0';
    ififo_reset := '0';

    isbusy := '0';
    if unsigned(r.cntbusy) /= 0 then
      isbusy := '1';
    end if;

    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' and RB_MREQ.addr(7 downto 2)=RB_ADDR(7 downto 2) then

      n.rbsel := '1';

      if irbena = '0' then              -- addr valid and selected, but no req
        n.cntbusy := r.nbusy;             -- preset busy timer
        n.cntcyc  := (others=>'0');       -- clear cycle length counter
      end if;

    end if;

    -- rbus transactions
    if r.rbsel = '1' then
      
      if irbena = '1' then              -- if request active
        if unsigned(r.cntbusy) /= 0 then  -- if busy timer > 0
          n.cntbusy := unsigned(r.cntbusy) - 1; -- decrement busy timer
        end if;
        if r.cntcyc /= cntcyc_max then    -- if cycle counter < max
          n.cntcyc  := unsigned(r.cntcyc) + 1;  -- increment cycle counter
        end if;
      end if;
      
      irb_ack := irbena;                  -- ack all (some rejects later)

      case RB_MREQ.addr(1 downto 0) is

        when rbaddr_cntl =>
          if RB_MREQ.we='1' then 
            n.nofifo := RB_MREQ.din(cntl_rbf_nofifo);
            n.stat   := RB_MREQ.din(cntl_rbf_stat);
            n.nbusy  := RB_MREQ.din(cntl_rbf_nbusy);
            if r.nofifo='1' and RB_MREQ.din(cntl_rbf_nofifo)='0' then
              ififo_reset := '1';
            end if;
          end if;
          
        when rbaddr_data =>
          irb_busy := irbena and isbusy;
          if RB_MREQ.we='1' and isbusy='0' then
            n.data := RB_MREQ.din;
          end if;
          
        when rbaddr_fifo =>
          if r.nofifo = '0' then            -- if fifo enabled
            irb_busy := irbena and isbusy;
            if RB_MREQ.re='1' and isbusy='0' then
              if FIFO_EMPTY = '1' then
                irb_err := '1';
              else
                ififo_re := '1';
              end if;
            end if;
            if RB_MREQ.we='1' and isbusy='0' then
              if FIFO_FULL = '1' then
                irb_err := '1';
              else
                ififo_we := '1';
              end if;
            end if;

          else                              -- else: if fifo disabled
            irb_ack := '0';                   -- nak it
            if isbusy = '1' then              -- or do a delayed nak
              irb_ack  := irbena;
              irb_busy := irbena;
            end if;
          end if;

        when rbaddr_attn =>
          if RB_MREQ.we = '1' then
            irblam := RB_MREQ.din;
          end if;
          
        when others => null;
      end case;
    end if;

    -- rbus output driver
    --   send a '0101...' pattern when selected and busy or err
    --   send data only when busy=0 and err=0
    --   this extra logic allows to debug rlink state machine
    if r.rbsel = '1' then
      if RB_MREQ.re='1' and irb_busy='0' and irb_err='0' then
        case RB_MREQ.addr(1 downto 0) is
          when rbaddr_cntl =>
            irb_dout(cntl_rbf_stat)   := r.stat;
            irb_dout(cntl_rbf_nofifo) := r.nofifo;
            irb_dout(cntl_rbf_nbusy)  := r.nbusy;
          when rbaddr_data =>
            irb_dout := r.data;
          when rbaddr_fifo =>
            if r.nofifo='0' and FIFO_EMPTY = '0' then
              irb_dout := FIFO_DO;
            end if;
          when rbaddr_attn =>
            irb_dout(r.cntcyc'range) := r.ncyc;
          when others => null;
        end case;
      else
        irb_dout := "0101010101010101";
      end if;
    end if;

    -- init transactions
    if RB_MREQ.init='1' and RB_MREQ.we='1' and RB_MREQ.addr=RB_ADDR then
      if RB_MREQ.din(init_rbf_cntl) = '1' then
        n.nofifo := '0';
        n.stat   := (others=>'0');
        n.nbusy  := (others=>'0');
      end if;
      if RB_MREQ.din(init_rbf_data) = '1' then
        n.data   := (others=>'0');
      end if;
      if RB_MREQ.din(init_rbf_fifo) = '1' then
        ififo_reset := '1';
      end if;
    end if;
    
    -- other transactions
    if irbena='0' and r.act_1='1' then
      n.ncyc := r.cntcyc;
    end if;
    n.act_1 := irbena;
    
    N_REGS <= n;

    FIFO_RE    <= ififo_re;
    FIFO_WE    <= ififo_we;
    FIFO_RESET <= ififo_reset;
      
    RB_SRES.dout <= irb_dout;
    RB_SRES.ack  <= irb_ack;
    RB_SRES.err  <= irb_err;
    RB_SRES.busy <= irb_busy;

    RB_LAM  <= irblam;
    RB_STAT <= r.stat;
      
  end process proc_next;

end syn;
