-- $Id: rbd_rbmon.vhd 374 2011-03-27 17:02:47Z mueller $
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
-- Module Name:    rbd_rbmon - syn
-- Description:    rbus dev: rbus monitor
--
-- Dependencies:   memlib/ram_1swsr_wfirst_gen
--
-- Test bench:     rlink/tb/tb_rlink_tba_ttcombo
--
-- Target Devices: generic
-- Tool versions:  xst 12.1; ghdl 0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-12-27   349 12.1    M53d xc3s1000-4    95  228    -  154 s 10.4
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-03-27   374   1.0.2  rename ncyc -> nbusy because it counts busy cycles
-- 2010-12-31   352   1.0.1  simplify irb_ack logic
-- 2010-12-27   349   1.0    Initial version 
------------------------------------------------------------------------------
--
-- address layout:
--   bbbbbb00 : cntl
--                 00 : go/halt (writing 1 clears addr)
--   bbbbbb01 : alim: read-write register
--              15:08 : hilim: upper address limit (def: ff)
--               7:00 : lolim: lower address limit (def: 00)
--   bbbbbb10 : addr: read-write register
--                 15 : wrap: line address wrapped (read-only, cleared on write)
--              xx:02 : laddr: line address
--              01:00 : waddr: word address
--   bbbbbb11 : data: read-write register
--
--     data format:
--     word 3     15 : ack
--                14 : busy
--                13 : err
--                12 : nak
--                11 : tout
--                09 : init
--                08 : we
--             07:00 : addr
--     word 2          data
--     word 1  15:00 : delay to prev (lsb's)
--     word 0  15:12 : delay to prev (msb's)
--             11:00 : number of busy cycles
-- 


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.memlib.all;
use work.rblib.all;

entity rbd_rbmon is                     -- rbus dev: rbus monitor
  generic (
    RB_ADDR : slv8 := conv_std_logic_vector(2#11111100#,8);
    AWIDTH : positive := 9);
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_SRES_SUM : in rb_sres_type       -- rbus: response (sum for monitor)
  );
end entity rbd_rbmon;


architecture syn of rbd_rbmon is

  constant rbaddr_cntl : slv2 := "00";   -- cntl address offset
  constant rbaddr_alim : slv2 := "01";   -- alim address offset
  constant rbaddr_addr : slv2 := "10";   -- addr address offset
  constant rbaddr_data : slv2 := "11";   -- data address offset

  constant cntl_rbf_go       : integer :=     0;
  subtype  alim_rbf_hilim   is integer range 15 downto  8;
  subtype  alim_rbf_lolim   is integer range  7 downto  0;
  constant addr_rbf_wrap     : integer :=    15;
  subtype  addr_rbf_laddr   is integer range 2+AWIDTH-1 downto  2;
  subtype  addr_rbf_waddr   is integer range  1 downto  0;

  constant dat3_rbf_ack      : integer :=    15;
  constant dat3_rbf_busy     : integer :=    14;
  constant dat3_rbf_err      : integer :=    13;
  constant dat3_rbf_nak      : integer :=    12;
  constant dat3_rbf_tout     : integer :=    11;
  constant dat3_rbf_init     : integer :=     9;
  constant dat3_rbf_we       : integer :=     8;
  subtype  dat3_rbf_addr    is integer range  7 downto  0;
  subtype  dat0_rbf_ndlymsb is integer range 15 downto 12;
  subtype  dat0_rbf_nbusy   is integer range 11 downto  0;

  type regs_type is record              -- state registers
    rbsel : slbit;                      -- rbus select
    go : slbit;                         -- go flag
    hilim : slv8;                       -- upper address limit
    lolim : slv8;                       -- lower address limit
    wrap : slbit;                       -- laddr wrap flag
    laddr : slv(AWIDTH-1 downto 0);     -- line address
    waddr : slv2;                       -- word address
    rbtake_1 : slbit;                   -- rb capture active in last cycle
    rbaddr  : slv8;                     -- rbus trace: addr
    rbinit  : slbit;                    -- rbus trace: init
    rbwe    : slbit;                    -- rbus trace: we
    rback   : slbit;                    -- rbus trace: ack  seen
    rbbusy  : slbit;                    -- rbus trace: busy seen
    rberr   : slbit;                    -- rbus trace: err  seen
    rbnak   : slbit;                    -- rbus trace: nak  detected
    rbtout  : slbit;                    -- rbus trace: tout detected
    rbdata  : slv16;                    -- rbus trace: data
    rbnbusy : slv12;                    -- rbus number of busy cycles
    rbndly  : slv20;                    -- rbus delay to prev. access
  end record regs_type;

  constant laddrzero : slv(AWIDTH-1 downto 0) := (others=>'0');
  constant laddrlast : slv(AWIDTH-1 downto 0) := (others=>'1');
  
  constant regs_init : regs_type := (
    '0',                                -- rbsel
    '0',                                -- go    (default is off)
    (others=>'1'),                      -- hilim (def: ff)
    (others=>'0'),                      -- lolim (def: 00)
    '0',                                -- wrap
    laddrzero,                          -- laddr
    "00",                               -- waddr
    '0',                                -- rbtake_1
    (others=>'0'),                      -- rbaddr
    '0','0','0','0','0',                -- rbinit,rbwe,rback,rbbusy,rberr
    '0','0',                            -- rbnak,rbtout
    (others=>'0'),                      -- rbdata
    (others=>'0'),                      -- rbnbusy
    (others=>'0')                       -- rbndly
  );

  constant rbnbusylast : slv12 := (others=>'1');
  constant rbndlylast  : slv20 := (others=>'1');

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

  signal BRAM_EN : slbit := '0';
  signal BRAM_WE : slbit := '0';
  signal BRAM0_DI : slv32 := (others=>'0');
  signal BRAM1_DI : slv32 := (others=>'0');
  signal BRAM0_DO : slv32 := (others=>'0');
  signal BRAM1_DO : slv32 := (others=>'0');
  
begin

  assert AWIDTH<=13 
    report "assert(AWIDTH<=13): max address width supported"
    severity failure;

  BRAM1 : ram_1swsr_wfirst_gen
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH => 32)
    port map (
      CLK   => CLK,
      EN    => BRAM_EN,
      WE    => BRAM_WE,
      ADDR  => R_REGS.laddr,
      DI    => BRAM1_DI,
      DO    => BRAM1_DO
    );

  BRAM0 : ram_1swsr_wfirst_gen
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH => 32)
    port map (
      CLK   => CLK,
      EN    => BRAM_EN,
      WE    => BRAM_WE,
      ADDR  => R_REGS.laddr,
      DI    => BRAM0_DI,
      DO    => BRAM0_DO
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

  proc_next : process (R_REGS, RB_MREQ, RB_SRES_SUM, BRAM0_DO, BRAM1_DO)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_err  : slbit := '0';
    variable irb_dout  : slv16 := (others=>'0');
    variable irbena  : slbit := '0';
    variable ibramen : slbit := '0';
    variable ibramwe : slbit := '0';
    variable rbtake : slbit := '0';
    variable laddr_inc : slbit := '0';
    variable idat0 : slv16 := (others=>'0');
    variable idat1 : slv16 := (others=>'0');
    variable idat2 : slv16 := (others=>'0');
    variable idat3 : slv16 := (others=>'0');
  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_busy := '0';
    irb_err  := '0';
    irb_dout := (others=>'0');

    irbena  := RB_MREQ.re or RB_MREQ.we;
        
    ibramen := '0';
    ibramwe := '0';

    laddr_inc := '0';
    
    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' and RB_MREQ.addr(7 downto 2)=RB_ADDR(7 downto 2) then
      n.rbsel := '1';
      ibramen := '1';
    end if;

    -- rbus transactions
    if r.rbsel = '1' then

      irb_ack := irbena;                  -- ack all accesses

      case RB_MREQ.addr(1 downto 0) is

        when rbaddr_cntl =>
          if RB_MREQ.we = '1' then 
            n.go  := RB_MREQ.din(cntl_rbf_go);
            if RB_MREQ.din(cntl_rbf_go)='1' then
              n.wrap  := '0';
              n.laddr := laddrzero;
              n.waddr := "00";
            end if;
          end if;
          
        when rbaddr_alim =>
          if RB_MREQ.we = '1' then
            n.hilim := RB_MREQ.din(alim_rbf_hilim);
            n.lolim := RB_MREQ.din(alim_rbf_lolim);
          end if;
          
        when rbaddr_addr =>
          if RB_MREQ.we = '1' then
            n.go    := '0';
            n.wrap  := '0';
            n.laddr := RB_MREQ.din(addr_rbf_laddr);
            n.waddr := RB_MREQ.din(addr_rbf_waddr);
          end if;

        when rbaddr_data =>
          if r.go='1' or RB_MREQ.we='1' then
            irb_err := '1';
          end if;
          if RB_MREQ.re = '1' then
            n.waddr := unsigned(r.waddr) + 1;
            if r.waddr = "11" then
              laddr_inc := '1';
            end if;
          end if;

        when others => null;
      end case;
    end if;

    -- rbus output driver
    if r.rbsel = '1' then
      case RB_MREQ.addr(1 downto 0) is
        when rbaddr_cntl =>
          irb_dout(cntl_rbf_go)    := r.go;
        when rbaddr_alim =>
          irb_dout(alim_rbf_hilim) := r.hilim;
          irb_dout(alim_rbf_lolim) := r.lolim;
        when rbaddr_addr =>
          irb_dout(addr_rbf_wrap)  := r.wrap;
          irb_dout(addr_rbf_laddr) := r.laddr;
          irb_dout(addr_rbf_waddr) := r.waddr;
        when rbaddr_data =>
          case r.waddr is
            when "11" => irb_dout := BRAM1_DO(31 downto 16);
            when "10" => irb_dout := BRAM1_DO(15 downto  0);
            when "01" => irb_dout := BRAM0_DO(31 downto 16);
            when "00" => irb_dout := BRAM0_DO(15 downto  0);
            when others => null;
          end case;
        when others => null;
      end case;
    end if;

    -- rbus monitor 
    --   a rbus transaction are captured if the address is in alim window
    --   and the access is not refering to rbd_rbmon itself
    
    rbtake := '0';
    if RB_MREQ.aval='1' and irbena='1' then              -- aval and (re or we)
      if unsigned(RB_MREQ.addr)>=unsigned(r.lolim) and   -- and in addr window
         unsigned(RB_MREQ.addr)<=unsigned(r.hilim) and
         r.rbsel='0' then                                -- and not self
        rbtake := '1';
      end if;
    end if;
    if RB_MREQ.init = '1' then                           -- also take init's
      rbtake := '1';
    end if;

    if rbtake = '1' then                -- if capture active
      n.rbaddr := RB_MREQ.addr;           -- keep track of some state
      n.rbinit := RB_MREQ.init;
      n.rbwe   := RB_MREQ.we;
      if RB_MREQ.init='1' or RB_MREQ.we='1' then  -- for write/init of din
        n.rbdata := RB_MREQ.din;
      else                                        -- for read of dout
        n.rbdata := RB_SRES_SUM.dout;
      end if;
      
      if r.rbtake_1 = '0' then            -- if initial cycle of a transaction
        n.rback  := RB_SRES_SUM.ack;
        n.rbbusy := RB_SRES_SUM.busy;
        n.rberr  := RB_SRES_SUM.err;
        n.rbnbusy := (others=>'0');
      else                                -- if non-initial cycles
        if RB_SRES_SUM.err = '1' then       -- keep track of err flags
          n.rberr := '1';
        end if;
        if r.rbnbusy /= rbnbusylast then      -- and count  
          n.rbnbusy := unsigned(r.rbnbusy) + 1;
        end if;
      end if;
      n.rbnak  := not RB_SRES_SUM.ack;
      n.rbtout := RB_SRES_SUM.busy;

    else                                -- if capture not active
      if r.go='1' and r.rbtake_1='1' then -- active and transaction just ended
        ibramen := '1';
        ibramwe := '1';
        laddr_inc := '1';
      end if;
      if r.rbtake_1 = '1' then            -- rbus transaction just ended
        n.rbndly := (others=>'0');          -- clear delay counter
      else                                -- just idle
        if r.rbndly /= rbndlylast then      -- count cycles
          n.rbndly := unsigned(r.rbndly) + 1;
        end if;
      end if;
    end if;

    if laddr_inc = '1' then
      n.laddr := unsigned(r.laddr) + 1;
      if r.go='1' and r.laddr=laddrlast then
        n.wrap := '1';
      end if;
    end if;
    
    idat3 := (others=>'0');
    idat3(dat3_rbf_ack)  := r.rback;
    idat3(dat3_rbf_busy) := r.rbbusy;
    idat3(dat3_rbf_err)  := r.rberr;
    idat3(dat3_rbf_nak)  := r.rbnak;
    idat3(dat3_rbf_tout) := r.rbtout;
    idat3(dat3_rbf_init) := r.rbinit;
    idat3(dat3_rbf_we)   := r.rbwe;
    idat3(dat3_rbf_addr) := r.rbaddr;
    idat2 := r.rbdata;
    idat1 := r.rbndly(15 downto 0);
    idat0(dat0_rbf_ndlymsb) := r.rbndly(19 downto 16);
    idat0(dat0_rbf_nbusy)   := r.rbnbusy;
    
    n.rbtake_1 := rbtake;
    
    N_REGS <= n;

    BRAM_EN <= ibramen;
    BRAM_WE <= ibramwe;

    BRAM1_DI <= idat3 & idat2;
    BRAM0_DI <= idat1 & idat0;
      
    RB_SRES.dout <= irb_dout;
    RB_SRES.ack  <= irb_ack;
    RB_SRES.err  <= irb_err;
    RB_SRES.busy <= irb_busy;

  end process proc_next;

end syn;
