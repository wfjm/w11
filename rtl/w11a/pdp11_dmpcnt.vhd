-- $Id: pdp11_dmpcnt.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_dmpcnt - syn
-- Description:    pdp11: debug&moni: performance counters
--
-- Dependencies:   -
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2017.2-2019.1; ghdl 0.34-0.35
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2018-09-23  1050 14.7  131013 xc6slx16-2   250  337   20  121 s  6.5
--
-- Revision History: -
-- Date         Rev Version  Comment
-- 2019-06-02  1159   1.0.1  use rbaddr_ constants
-- 2018-09-29  1051   1.0    Initial version
-- 2018-09-23  1050   0.1    First draft
------------------------------------------------------------------------------
--
-- rbus registers:
--
--  Addr    Bits  Name      r/w/f  Function
--   00         cntl        -/w/f  Control register
--          15    ainc      -/w/-    enable address autoinc
--       13:09    caddr     -/w/-    counter address
--       07:00    vers      r/-/-    counter layout version
--       02:00    func      0/-/f    change run status if != noop
--                                     0xx   noop
--                                     100   sto  stop
--                                     101   sta  start 
--                                     110   clr  clear
--                                     111   loa  load caddr
--   01         stat        r/-/-  Status register
--          15    ainc      r/-/-    enable address autoinc
--       13:09    caddr     r/-/-    counter address
--          08    waddr     r/-/-    word address
--          00    run       r/-/-    running
--   10         data        r/-/-  Data register
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.rblib.all;

-- ----------------------------------------------------------------------------

entity pdp11_dmpcnt_precnt is           -- pre-counter
  port (
    CLK : in slbit;                     -- clock
    CLR : in slbit;                     -- clear
    ENA : in slbit;                     -- count
    DOUT : out slv5                     -- data
  );
end pdp11_dmpcnt_precnt;

architecture syn of pdp11_dmpcnt_precnt is
  signal R_CNT : slv5 := (others=>'0');
begin
  proc_cnt: process (CLK)
  begin

    if rising_edge(CLK) then
      if CLR = '1' then
        R_CNT <= (others=>'0');
      else
        if ENA = '1' then
          R_CNT <= slv(unsigned(R_CNT) + 1);
        end if;
      end if;
    end if;

  end process proc_cnt;

  DOUT <= R_CNT;
  
end syn;

-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.rblib.all;
use work.pdp11.all;

entity pdp11_dmpcnt is                  -- debug&moni: performance counters
  generic (
    RB_ADDR : slv16 := rbaddr_dmpcnt_off;       -- rbus address
    VERS    : slv8  := slv(to_unsigned(1, 8));  -- counter layout version
    CENA    : slv32 := (others=>'1'));          -- counter enables
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    PERFSIG : in slv32                  -- signals to count
  );
end pdp11_dmpcnt;


architecture syn of pdp11_dmpcnt is

  constant rbaddr_cntl  : slv2 := "00";  -- cntl  address offset
  constant rbaddr_stat  : slv2 := "01";  -- stat  address offset
  constant rbaddr_data  : slv2 := "10";  -- data  address offset
  
  constant cntl_rbf_ainc     : integer :=    15;
  subtype  cntl_rbf_caddr   is integer range 13 downto  9;
  subtype  cntl_rbf_vers    is integer range  7 downto  0;
  subtype  cntl_rbf_func    is integer range  2 downto  0;

  constant stat_rbf_ainc     : integer :=    15;
  subtype  stat_rbf_caddr   is integer range 13 downto  9;
  constant stat_rbf_waddr    : integer :=     8;
  constant stat_rbf_run      : integer :=     0;
  
  constant func_sto : slv3 := "100";    -- func: stop
  constant func_sta : slv3 := "101";    -- func: start
  constant func_clr : slv3 := "110";    -- func: clear
  constant func_loa : slv3 := "111";    -- func: load

  type regs_type is record
    rbsel : slbit;                      -- rbus select
    run   : slbit;                      -- run flag
    saddr : slv5;                       -- scan address
    raddr : slv5;                       -- read address (counter)
    waddr : slbit;                      -- read address (word)
    ainc  : slbit;                      -- enable ddress autoinc
    zbusy : slbit;                      -- clear in progress
    dval  : slbit;                      -- data valid
    dout : slv32;                       -- read data (valid if dval=1)
    psig : slv32;                       -- signals, floped
  end record regs_type;

  constant regs_init : regs_type := (
    '0','0',                            -- rbsel,run
    (others=>'0'),                      -- saddr
    (others=>'0'),                      -- raddr
    '0','0','0','0',                    -- waddr,ainc,zbusy,dval
    (others=>'0'),                      -- dout
    (others=>'0')                       -- psig
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type;            -- don't init (vivado fix for fsm infer)

  type pre_do_type is array (31 downto 0) of slv5;

  signal PRE_CLR : slv32 := (others=>'0');
  signal PRE_DO  : pre_do_type := (others=> (others => '0'));
  signal MEM_DI  : slv32 := (others=>'0');
  signal MEM_DO  : slv32 := (others=>'0');
  
  begin

  MEM : ram_1swar_gen
    generic map (
      AWIDTH =>  5,
      DWIDTH => 32)
    port map (
      CLK  => CLK,
      WE   => '1',
      ADDR => R_REGS.saddr,
      DI   => MEM_DI,
      DO   => MEM_DO
    );

  PRE: for i in 31 downto 0 generate
    ENA: if CENA(i)='1' generate
      CNT : entity work.pdp11_dmpcnt_precnt
        port map (
          CLK  => CLK,
          CLR  => PRE_CLR(i),
          ENA  => R_REGS.psig(i),
          DOUT => PRE_DO(i)
        );
    end generate ENA;
  end generate PRE;

  proc_cnt: process (R_REGS, PRE_DO, MEM_DO)
    variable iclr : slv32 := (others=>'0');
    variable ipdo : slv32 := (others=>'0');
    variable icnt : slv32 := (others=>'0');
    variable imdi : slv32 := (others=>'0');
    constant ipdo_pad : slv(31 downto 5) := (others=>'0');
    constant icnt_pad : slv(31 downto 1) := (others=>'0');
  begin
    iclr := (others=>'0');
    iclr(to_integer(unsigned(R_REGS.saddr))) := '1';

    ipdo := ipdo_pad & PRE_DO(to_integer(unsigned(R_REGS.saddr)));
    icnt := icnt_pad & R_REGS.psig(to_integer(unsigned(R_REGS.saddr)));
    PRE_CLR <= iclr;
    if R_REGS.zbusy = '0' then
      imdi := slv(unsigned(MEM_DO) + unsigned(ipdo) + unsigned(icnt));
    else
      imdi := (others=>'0');
    end if;
    MEM_DI  <= imdi;
    
  end process proc_cnt;

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

  proc_next: process (R_REGS, RB_MREQ, PERFSIG, MEM_DO)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_err  : slbit := '0';
    variable irb_dout : slv16 := (others=>'0');
    variable irbena   : slbit := '0';

  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_busy := '0';
    irb_err  := '0';
    irb_dout := (others=>'0');
    irbena   := RB_MREQ.re or RB_MREQ.we;
    
    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' then
      if RB_MREQ.addr(15 downto 2)=RB_ADDR(15 downto 2) then
        n.rbsel := '1';
      end if;
    end if;
    
    if r.run = '1' then                     -- if running
      n.psig := PERFSIG;                      -- capture performance signals
    else
      n.psig := (others=>'0');                -- otherwise ignore them
    end if;
    
    n.saddr := slv(unsigned(r.saddr) + 1);  -- scan counter (always running)

    -- capture data in dout buffer if scan=read address and looking at lsb and
    --   if either data not valid or no rbus cycle active. this ensures that
    --   dval waits end, and also that data isn't changing during rbus active.
    if r.saddr = r.raddr and r.waddr = '0' and
       (r.dval='0' or r.rbsel='0') then
      n.dout := MEM_DO;                       -- capture data
      n.dval := '1';
    end if;

    -- rbus transactions
    if r.rbsel = '1' then
      irb_ack := irbena;                -- ack all accesses
      case RB_MREQ.addr(1 downto 0) is
        
        when rbaddr_cntl =>                 -- cntl ------------------
         if RB_MREQ.we = '1' then 
           case RB_MREQ.din(cntl_rbf_func) is
             when func_sto =>               -- func: stop ------------
               n.run   := '0';
               
             when func_sta =>               -- func: start -----------
               n.run   := '1';
               
             when func_clr =>               -- func: clear -----------
               n.run   := '0';
               if r.zbusy = '0' then
                 n.zbusy := '1';
                 n.saddr := (others=>'0');
                 n.raddr := (others=>'0');
                 n.waddr := '0';
                 n.ainc  := '0';
                 irb_busy := '1';
               else
                 if r.saddr = "11111" then
                   n.zbusy := '0';
                   n.dval  := '0';
                 else
                   irb_busy := '1';
                 end if;
               end if;
               
             when func_loa =>               -- func: load ------------
               n.ainc  := RB_MREQ.din(cntl_rbf_ainc);
               n.raddr := RB_MREQ.din(cntl_rbf_caddr);
               n.waddr := '0';
               n.dval  := '0';
               
             when others => null;           -- <> --------------------
           end case;             
         end if;

        when rbaddr_stat =>                 -- stat ------------------
          irb_err  := RB_MREQ.we;

        when rbaddr_data =>                 -- data ------------------
          -- write to data is an error
          if RB_MREQ.we='1' then
            irb_err := '1';                   -- error
          end if;
          if RB_MREQ.re = '1' then
            if r.dval = '0' then
              irb_busy := '1';
            else
              n.waddr := not r.waddr;
              if r.ainc='1' and r.waddr = '1' then   -- autoinc and wrap ?
                n.raddr := slv(unsigned(r.raddr) + 1);
                n.dval  := '0';
              end if;
            end if;
          end if;
            
        when others => irb_err := '1';      -- <> --------------------
      end case;
    end if;
    
    -- rbus output driver
    if r.rbsel = '1' then
      case RB_MREQ.addr(1 downto 0) is
        
        when rbaddr_cntl => null;           -- cntl ------------------
          irb_dout(cntl_rbf_vers)   := VERS;
                            
        when rbaddr_stat =>                 -- stat ------------------
          irb_dout(stat_rbf_ainc)   := r.ainc;
          irb_dout(stat_rbf_caddr)  := r.raddr;
          irb_dout(stat_rbf_waddr)  := r.waddr;
          irb_dout(stat_rbf_run)    := r.run;

        when rbaddr_data =>                 -- data ------------------
          if r.waddr = '0' then
            irb_dout := r.dout(15 downto  0);
          else
            irb_dout := r.dout(31 downto 16);
          end if;
          
        when others => null;
      end case;
    end if;
    
    N_REGS <= n;

    RB_SRES.ack  <= irb_ack;
    RB_SRES.err  <= irb_err;
    RB_SRES.busy <= irb_busy;
    RB_SRES.dout <= irb_dout;    
    
  end process proc_next;

end syn;
