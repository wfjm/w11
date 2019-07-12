-- $Id: rbd_rbmon.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Tool versions:  xst 12.1-14.7; viv 2014.4-2018.3; ghdl 0.29-0.35
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2017-04-14   873 14.7  131013 xc6slx16-2   124  187    -   67 s  5.9
-- 2017-04-08   758 14.7  131013 xc6slx16-2   112  200    -   73 s  5.7
-- 2014-12-22   619 14.7  131013 xc6slx16-2   114  209    -   72 s  5.6
-- 2014-12-21   593 14.7  131013 xc6slx16-2    99  207    -   77 s  7.0
-- 2010-12-27   349 12.1    M53d xc3s1000-4    95  228    -  154 s 10.4
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-06-02  1159   6.0.2  use rbaddr_ constants
-- 2019-03-02  1116   6.0.1  more robust ack,err trace when busy
-- 2017-04-16   879   6.0    revised interface, add suspend and repeat collapse
-- 2015-05-02   672   5.0.1  use natural for AWIDTH to work around a ghdl issue
-- 2014-12-22   619   5.0    reorganized, supports now 16 bit addresses
-- 2014-09-13   593   4.1    change default address -> ffe8
-- 2014-08-15   583   4.0    rb_mreq addr now 16 bit (but only 8 bit recorded)
-- 2011-11-19   427   1.0.3  now numeric_std clean
-- 2011-03-27   374   1.0.2  rename ncyc -> nbusy because it counts busy cycles
-- 2010-12-31   352   1.0.1  simplify irb_ack logic
-- 2010-12-27   349   1.0    Initial version 
------------------------------------------------------------------------------
--
-- Addr   Bits  Name        r/w/f  Function
--  000         cntl        r/w/f  Control register
--          05    rcolw     r/w/-    repeat collapse writes
--          04    rcolr     r/w/-    repeat collapse reads
--          03    wstop     r/w/-    stop on wrap
--       02:00    func      0/-/f    change run status if != noop
--                                     0xx  noop
--                                     100  sto  stop
--                                     101  sta  start and latch all options
--                                     110  sus  suspend  (noop if not started)
--                                     111  res  resume   (noop if not started)
--  001         stat        r/w/-  Status register
--       15:13    bsize     r/-/-    buffer size (AWIDTH-9)
--          02    wrap      r/-/-    line address wrapped (cleared on start)
--          01    susp      r/-/-    suspended
--          00    run       r/-/-    running (can be suspended)
--  010         hilim       r/w/-  upper address limit, inclusive (def: 0xfffb)
--  011         lolim       r/w/-  lower address limit, inclusive (def: 0x0000)
--  100         addr        r/w/-  Address register
--        *:02    laddr     r/w/-    line address
--       01:00    waddr     r/w/-    word address
--  101         data        r/w/-  Data register
--
--     data format:
--     word 3     15 : burst      (2nd re/we in a aval sequence)
--                14 : tout       (busy in last re-we cycle)
--                13 : nak        (no ack in last non-busy cycle)
--                12 : ack        (ack  seen)
--                11 : busy       (busy seen)
--                10 : err        (err  seen)
--                09 : we         (write cycle)
--                08 : init       (init  cycle)
--             07:00 : delay to prev (msb's)
--     word 2  15:10 : delay to prev (lsb's)
--             09:00 : number of busy cycles
--     word 1        : data
--     word 0        : addr
-- 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.rblib.all;
use work.rbdlib.all;

-- Note: AWIDTH has type natural to allow AWIDTH=0 can be used in if generates
--       to control the instantiation. ghdl checks even for not instantiated
--       entities the validity of generics, that's why natural needed here ....

entity rbd_rbmon is                     -- rbus dev: rbus monitor
  generic (
    RB_ADDR : slv16 := rbaddr_rbmon;
    AWIDTH  : natural := 9);
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_SRES_SUM : in rb_sres_type       -- rbus: response (sum for monitor)
  );
end entity rbd_rbmon;


architecture syn of rbd_rbmon is

  constant rbaddr_cntl  : slv3 := "000";   -- cntl  address offset
  constant rbaddr_stat  : slv3 := "001";   -- stat  address offset
  constant rbaddr_hilim : slv3 := "010";   -- hilim address offset
  constant rbaddr_lolim : slv3 := "011";   -- lolim address offset
  constant rbaddr_addr  : slv3 := "100";   -- addr  address offset
  constant rbaddr_data  : slv3 := "101";   -- data  address offset

  constant cntl_rbf_rcolw    : integer :=     5;
  constant cntl_rbf_rcolr    : integer :=     4;
  constant cntl_rbf_wstop    : integer :=     3;
  subtype  cntl_rbf_func    is integer range  2 downto  0;
  
  subtype  stat_rbf_bsize   is integer range 15 downto 13;
  constant stat_rbf_wrap     : integer :=     2;
  constant stat_rbf_susp     : integer :=     1;
  constant stat_rbf_run      : integer :=     0;
  
  subtype  addr_rbf_laddr   is integer range 2+AWIDTH-1 downto  2;
  subtype  addr_rbf_waddr   is integer range  1 downto  0;

  constant dat3_rbf_burst    : integer :=    15;
  constant dat3_rbf_tout     : integer :=    14;
  constant dat3_rbf_nak      : integer :=    13;
  constant dat3_rbf_ack      : integer :=    12;
  constant dat3_rbf_busy     : integer :=    11;
  constant dat3_rbf_err      : integer :=    10;
  constant dat3_rbf_we       : integer :=     9;
  constant dat3_rbf_init     : integer :=     8;
  subtype  dat3_rbf_ndlymsb is integer range  7 downto  0;
  subtype  dat2_rbf_ndlylsb is integer range 15 downto 10;
  subtype  dat2_rbf_nbusy   is integer range  9 downto  0;

  constant func_sto : slv3 := "100";    -- func: stop
  constant func_sta : slv3 := "101";    -- func: start
  constant func_sus : slv3 := "110";    -- func: suspend
  constant func_res : slv3 := "111";    -- func: resume

  type regs_type is record              -- state registers
    rbsel : slbit;                      -- rbus select
    rcolw  : slbit;                     -- rcolw flag (repeat collect writes)
    rcolr  : slbit;                     -- rcolr flag (repeat collect reads)
    wstop  : slbit;                     -- wstop flag (stop on wrap)
    susp   : slbit;                     -- suspended flag
    go : slbit;                         -- go flag
    hilim : slv16;                      -- upper address limit
    lolim : slv16;                      -- lower address limit
    wrap : slbit;                       -- laddr wrap flag
    laddr : slv(AWIDTH-1 downto 0);     -- line address
    waddr : slv2;                       -- word address
    addrsame: slbit;                    -- curr rb addr equal last rb addr
    addrwind: slbit;                    -- curr rb addr in [lolim,hilim] window
    aval_1  : slbit;                    -- last cycle aval
    arm1r   : slbit;                    -- 1st level arm for read
    arm2r   : slbit;                    -- 2nd level arm for read
    arm1w   : slbit;                    -- 1st level arm for write
    arm2w   : slbit;                    -- 2nd level arm for write
    rcol    : slbit;                    -- repeat collaps
    rbtake_1 : slbit;                   -- rb capture active in last cycle
    rbaddr  : slv16;                    -- rbus trace: addr
    rbinit  : slbit;                    -- rbus trace: init
    rbwe    : slbit;                    -- rbus trace: we
    rback   : slbit;                    -- rbus trace: ack  seen
    rbbusy  : slbit;                    -- rbus trace: busy seen
    rberr   : slbit;                    -- rbus trace: err  seen
    rbnak   : slbit;                    -- rbus trace: nak  detected
    rbtout  : slbit;                    -- rbus trace: tout detected
    rbburst : slbit;                    -- rbus trace: burst detected
    rbdata  : slv16;                    -- rbus trace: data
    rbnbusy : slv10;                    -- rbus number of busy cycles
    rbndly  : slv14;                    -- rbus delay to prev. access
  end record regs_type;

  constant laddrzero : slv(AWIDTH-1 downto 0) := (others=>'0');
  constant laddrlast : slv(AWIDTH-1 downto 0) := (others=>'1');
  
  constant regs_init : regs_type := (
    '0',                                -- rbsel
    '0','0','0',                        -- rcolw,rcolr,wstop
    '0','1',                            -- susp,go
    x"fffb",                            -- hilim (def: fffb)
    x"0000",                            -- lolim (def: 0000)
    '0',                                -- wrap
    laddrzero,                          -- laddr
    "00",                               -- waddr
    '0','0','0',                        -- addrsame,addrwind,aval_1
    '0','0','0','0','0',                -- arm1r,arm2r,arm1w,arm2w,rcol
    '0',                                -- rbtake_1
    x"ffff",                            -- rbaddr (startup: ffff)
    '0','0','0','0','0',                -- rbinit,rbwe,rback,rbbusy,rberr
    '0','0','0',                        -- rbnak,rbtout,rbburst
    (others=>'0'),                      -- rbdata
    (others=>'0'),                      -- rbnbusy
    (others=>'0')                       -- rbndly
  );

  constant rbnbusylast : slv10 := (others=>'1');
  constant rbndlylast  : slv14 := (others=>'1');

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

  signal BRAM_EN : slbit := '0';
  signal BRAM_WE : slbit := '0';
  signal BRAM0_DI : slv32 := (others=>'0');
  signal BRAM1_DI : slv32 := (others=>'0');
  signal BRAM0_DO : slv32 := (others=>'0');
  signal BRAM1_DO : slv32 := (others=>'0');
  signal BRAM_ADDR : slv(AWIDTH-1 downto 0) := (others=>'0');

begin

  assert AWIDTH>=9 and AWIDTH<=14 
    report "assert(AWIDTH>=9 and AWIDTH<=14): unsupported AWIDTH"
    severity failure;

  BRAM1 : ram_1swsr_wfirst_gen
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH => 32)
    port map (
      CLK   => CLK,
      EN    => BRAM_EN,
      WE    => BRAM_WE,
      ADDR  => BRAM_ADDR,
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
      ADDR  => BRAM_ADDR,
      DI    => BRAM0_DI,
      DO    => BRAM0_DO
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

  proc_next : process (R_REGS, RB_MREQ, RB_SRES_SUM, BRAM0_DO, BRAM1_DO)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_err  : slbit := '0';
    variable irb_dout  : slv16 := (others=>'0');
    variable irbena  : slbit := '0';
    variable ibramen : slbit := '0';    -- BRAM enable
    variable ibramwe : slbit := '0';    -- BRAN we
    variable rbtake : slbit := '0';
    variable laddr_inc : slbit := '0';
    variable idat0 : slv16 := (others=>'0');
    variable idat1 : slv16 := (others=>'0');
    variable idat2 : slv16 := (others=>'0');
    variable idat3 : slv16 := (others=>'0');
    variable iaddrinc : slv(AWIDTH-1 downto 0) := (others=>'0');
    variable iaddroff : slv(AWIDTH-1 downto 0) := (others=>'0');
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
    if RB_MREQ.aval='1' and RB_MREQ.addr(15 downto 3)=RB_ADDR(15 downto 3) then
      n.rbsel := '1';
      ibramen := '1';
    end if;

    -- rbus transactions
    if r.rbsel = '1' then

      irb_ack := irbena;                -- ack all accesses

      case RB_MREQ.addr(2 downto 0) is

        when rbaddr_cntl =>                 -- cntl ------------------
          if RB_MREQ.we = '1' then 
            case RB_MREQ.din(cntl_rbf_func) is
              when func_sto =>                -- func: stop ------------
                n.go    := '0';
                n.susp  := '0';
              when func_sta =>                -- func: start -----------
                n.rcolw  := RB_MREQ.din(cntl_rbf_rcolw);
                n.rcolr  := RB_MREQ.din(cntl_rbf_rcolr);
                n.wstop  := RB_MREQ.din(cntl_rbf_wstop);
                n.go     := '1';
                n.susp   := '0';
                n.wrap   := '0';
                n.laddr  := laddrzero;
                n.waddr  := "00";
              when func_sus =>                -- func: susp ------------
                if r.go = '1' then              -- noop unless running
                  n.go     := '0';
                  n.susp   := r.go;
                end if;
              when func_res =>                -- func: resu ------------
                n.go     := r.susp;
                n.susp   := '0';
              when others => null;            -- <> --------------------
            end case;
          end if;
          
        when rbaddr_stat => null;           -- stat ------------------

        when rbaddr_hilim =>                -- hilim -----------------
          if RB_MREQ.we = '1' then
            n.hilim := RB_MREQ.din;
          end if;
          
        when rbaddr_lolim =>                -- lolim -----------------
          if RB_MREQ.we = '1' then
            n.lolim := RB_MREQ.din;
          end if;
          
        when rbaddr_addr =>                 -- addr ------------------
          if RB_MREQ.we = '1' then
            if r.go = '0' then                -- if not active OK
              n.laddr := RB_MREQ.din(addr_rbf_laddr);
              n.waddr := RB_MREQ.din(addr_rbf_waddr);
            else
              irb_err := '1';                 -- otherwise error
            end if;
          end if;

        when rbaddr_data =>                 -- data ------------------
          -- write to data is an error
          if RB_MREQ.we='1' then
            irb_err := '1';
          end if;
          -- read to data always allowed, addr only incremented when not active
          if RB_MREQ.re = '1' and r.go = '0' then
            n.waddr := slv(unsigned(r.waddr) + 1);
            if r.waddr = "11" then
              laddr_inc := '1';
            end if;
          end if;

        when others =>                      -- <> --------------------
          irb_err := '1';
          
      end case;
    end if;

    -- rbus output driver
    if r.rbsel = '1' then
      case RB_MREQ.addr(2 downto 0) is
        when rbaddr_cntl =>                 -- cntl ------------------
          irb_dout(cntl_rbf_rcolw)  := r.rcolw;
          irb_dout(cntl_rbf_rcolr)  := r.rcolr;
          irb_dout(cntl_rbf_wstop)  := r.wstop;
        when rbaddr_stat =>                 -- stat ------------------
          irb_dout(stat_rbf_bsize) := slv(to_unsigned(AWIDTH-9,3));
          irb_dout(stat_rbf_wrap)  := r.wrap;
          irb_dout(stat_rbf_susp)  := r.susp;         -- started and suspended
          irb_dout(stat_rbf_run)   := r.go or r.susp; -- started
        when rbaddr_hilim =>                -- hilim -----------------
          irb_dout                 := r.hilim;
        when rbaddr_lolim =>                -- lolim -----------------
          irb_dout                 := r.lolim;
        when rbaddr_addr =>                 -- addr ------------------
          irb_dout(addr_rbf_laddr) := r.laddr;
          irb_dout(addr_rbf_waddr) := r.waddr;
        when rbaddr_data =>                 -- data ------------------
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
    --   Note: rbus init cycles come with aval=0 but addr is valid and checked !
    
    -- rbus address monitor
    if (RB_MREQ.aval='1' and r.aval_1='0') or RB_MREQ.init='1' then
      n.rbaddr := RB_MREQ.addr;
      n.addrsame := '0';
      if RB_MREQ.addr = r.rbaddr then
        n.addrsame := '1';
      end if;
      n.addrwind := '0';
      if unsigned(RB_MREQ.addr)>=unsigned(r.lolim) and   -- and in addr window
         unsigned(RB_MREQ.addr)<=unsigned(r.hilim) then
        n.addrwind := '1';
      end if;
    end if;
    n.aval_1 := RB_MREQ.aval;

    -- rbus data  monitor
    if (RB_MREQ.aval='1' and irbena='1') or RB_MREQ.init='1' then
      if RB_MREQ.init='1' or RB_MREQ.we='1' then  -- for write/init of din
        n.rbdata := RB_MREQ.din;
      else                                        -- for read of dout
        n.rbdata := RB_SRES_SUM.dout;
      end if;
    end if;

    -- track state and decide on storage
    rbtake := '0';
    if RB_MREQ.aval='1' and irbena='1' then   -- aval and (re or we)
      if r.addrwind='1' and r.rbsel='0' then     -- and in window and not self
        rbtake := '1';
      end if;
    end if;
    if RB_MREQ.init = '1' then                           -- also take init's
      rbtake := '1';
    end if;

    if rbtake = '1' then                -- if capture active
      n.rbinit := RB_MREQ.init;           -- keep track of some state
      n.rbwe   := RB_MREQ.we;
      
      if r.rbtake_1 = '0' then            -- if initial cycle of a transaction
        n.rback  := RB_SRES_SUM.ack;
        n.rbbusy := RB_SRES_SUM.busy;
        n.rberr  := RB_SRES_SUM.err;
        n.rbnbusy := (others=>'0');
      else                                -- if non-initial cycles
        n.rback := r.rback or RB_SRES_SUM.ack; -- keep track of ack
        n.rberr := r.rberr or RB_SRES_SUM.err; -- keep track of err
        if r.rbnbusy /= rbnbusylast then      -- and count  
          n.rbnbusy := slv(unsigned(r.rbnbusy) + 1);
        end if;
      end if;
      n.rbnak  := not RB_SRES_SUM.ack;
      n.rbtout := RB_SRES_SUM.busy;

      if RB_SRES_SUM.busy = '0' then    -- if last cycle of a transaction
        n.addrsame := '1';                -- in case of burst
        n.arm1r := r.rcolr and RB_MREQ.re;
        n.arm1w := r.rcolw and RB_MREQ.we;
        n.arm2r := r.arm1r and r.addrsame and RB_MREQ.re;
        n.arm2w := r.arm1w and r.addrsame and RB_MREQ.we;
        n.rcol  := ((r.arm2r and RB_MREQ.re) or
                    (r.arm2w and RB_MREQ.we)) and r.addrsame;
      end if;
      
    else                                -- if capture not active
      if r.go='1' and r.rbtake_1='1' then -- active and transaction just ended
        ibramen := '1';
        ibramwe := '1';
        laddr_inc := '1';
        n.rbburst := '1';                   -- assume burst
      end if;
      if r.rbtake_1 = '1' then            -- rbus transaction just ended
        n.rbndly := (others=>'0');          -- clear delay counter
      else                                -- just idle
        if r.rbndly /= rbndlylast then      -- count cycles
          n.rbndly := slv(unsigned(r.rbndly) + 1);
        end if;
      end if;
    end if;

    if RB_MREQ.aval = '0' then          -- if aval gone
      n.rbburst := '0';                   -- clear burst flag
    end if;
    
    iaddrinc := (others=>'0');
    iaddroff := (others=>'0');
    iaddrinc(0) := not (r.rcol and r.go);
    iaddroff(0) :=     (r.rcol and r.go);
    
    if laddr_inc = '1' then
      n.laddr := slv(unsigned(r.laddr) + unsigned(iaddrinc));
      if r.go='1' and r.laddr=laddrlast then
        n.wrap := '1';
        if r.wstop = '1' then
          n.go   := '0';
        end if;
      end if;
    end if;
    
    idat3 := (others=>'0');
    idat3(dat3_rbf_burst)  := r.rbburst;
    idat3(dat3_rbf_tout)   := r.rbtout;
    idat3(dat3_rbf_nak)    := r.rbnak;
    idat3(dat3_rbf_ack)    := r.rback;
    idat3(dat3_rbf_busy)   := r.rbbusy;
    idat3(dat3_rbf_err)    := r.rberr;
    idat3(dat3_rbf_we)     := r.rbwe;
    idat3(dat3_rbf_init)   := r.rbinit;
    idat3(dat3_rbf_ndlymsb):= r.rbndly(13 downto 6);
    idat2(dat2_rbf_ndlylsb):= r.rbndly( 5 downto 0);
    idat2(dat2_rbf_nbusy)  := r.rbnbusy;
    idat1 := r.rbdata;
    idat0 := r.rbaddr;
    
    n.rbtake_1 := rbtake;
    
    N_REGS <= n;

    BRAM_EN   <= ibramen;
    BRAM_WE   <= ibramwe;
    BRAM_ADDR <= slv(unsigned(R_REGS.laddr) - unsigned(iaddroff));

    BRAM1_DI  <= idat3 & idat2;
    BRAM0_DI  <= idat1 & idat0;
      
    RB_SRES.dout <= irb_dout;
    RB_SRES.ack  <= irb_ack;
    RB_SRES.err  <= irb_err;
    RB_SRES.busy <= irb_busy;

  end process proc_next;

end syn;
